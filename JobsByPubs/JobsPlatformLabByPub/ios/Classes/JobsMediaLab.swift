//
//  JobsMediaLab.swift
//  JobsPlatformLabByPub
//
//  Created by Jobs on 2026年11月14日，星期六.
//

import AVFoundation
import Photos
import UniformTypeIdentifiers
import UIKit
import CoreImage
import Flutter

final class JobsMediaLab: NSObject, AVAudioRecorderDelegate, UIImagePickerControllerDelegate,
    UINavigationControllerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate
{
    private let publish: (String, [String: Any]) -> Void
    private var recorder: AVAudioRecorder?
    private var recordGeneration = 0
    private var player: AVAudioPlayer?
    private var meter: Timer?
    private var videoResult: FlutterResult?
    private var streamSession: AVCaptureSession?
    private var socket: URLSessionWebSocketTask?
    private let captureQueue = DispatchQueue(label: "jobs.platformlab.capture")
    private var sendingFrame = false
    private var lastFrame: TimeInterval = 0
    private var frames = 0
    private let imageContext = CIContext()
    private var directory: URL {
        let base = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("JobsPlatformLabRecordings", isDirectory: true)
        try? FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
        return base
    }

    init(publish: @escaping (String, [String: Any]) -> Void) {
        self.publish = publish
        super.init()
    }

    func handle(_ method: String, args: [String: Any], result: @escaping FlutterResult) {
        do {
            switch method {
                /// 执行 audio.status 原生操作。
                case "audio.status":
                    result([
                        "recording": recorder?.isRecording ?? false, "name": recorder?.url.lastPathComponent ?? "",
                        "seconds": recorder?.currentTime ?? 0
                    ])
                /// 执行 audio.permission 原生操作。
                case "audio.permission":
                    requestAudioPermission {
                        result($0)
                    }
                /// 执行 audio.start 原生操作。
                case "audio.start":
                    guard recorder?.isRecording != true else {
                        throw JobsLabError("Recording already active")
                    }
                    recordGeneration += 1
                    let token = recordGeneration
                    requestAudioPermission { [weak self] granted in
                        guard let self else {
                            return
                        }
                        guard token == self.recordGeneration else {
                            result(
                                FlutterError(code: "cancelled", message: "Recording request cancelled", details: nil))
                            return
                        }
                        guard granted else {
                            result(
                                FlutterError(code: "permission", message: "Microphone permission denied", details: nil))
                            return
                        }
                        do {
                            let session = AVAudioSession.sharedInstance()
                            try session.setCategory(
                                .playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetoothHFP])
                            try session.setActive(true)
                            let url = self.directory.appendingPathComponent(UUID().uuidString + ".m4a")
                            let value = try AVAudioRecorder(
                                url: url,
                                settings: [
                                    AVFormatIDKey: kAudioFormatMPEG4AAC,
                                    AVSampleRateKey: 44100, AVNumberOfChannelsKey: 1,
                                    AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                                ])
                            value.isMeteringEnabled = true
                            value.delegate = self
                            value.prepareToRecord()
                            let duration = args["maxSeconds"] as? Double ?? 0
                            let started = duration > 0 ? value.record(forDuration: min(duration, 3600)) : value.record()
                            guard started else {
                                throw JobsLabError("Recorder could not start")
                            }
                            self.recorder = value
                            self.meter?.invalidate()
                            self.meter = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
                                guard let self, let recorder = self.recorder else {
                                    return
                                }
                                recorder.updateMeters()
                                self.publish(
                                    "audio",
                                    [
                                        "event": "meter", "seconds": recorder.currentTime,
                                        "power": recorder.averagePower(forChannel: 0), "recording": recorder.isRecording
                                    ])
                            }
                            result(["name": url.lastPathComponent])
                        } catch {
                            result(FlutterError(code: "record", message: error.localizedDescription, details: nil))
                        }
                    }
                /// 执行 audio.stop 原生操作。
                case "audio.stop":
                    recordGeneration += 1
                    let name = recorder?.url.lastPathComponent ?? ""
                    recorder?.stop()
                    meter?.invalidate()
                    result(["name": name])
                /// 执行 audio.cancel 原生操作。
                case "audio.cancel":
                    recordGeneration += 1
                    recorder?.stop()
                    recorder?.deleteRecording()
                    recorder = nil
                    meter?.invalidate()
                    result(true)
                /// 执行 audio.pause 原生操作。
                case "audio.pause":
                    recorder?.pause()
                    result(true)
                /// 执行 audio.resume 原生操作。
                case "audio.resume":
                    result(recorder?.record() ?? false)
                /// 执行 audio.list, video.list 原生操作。
                case "audio.list", "video.list":
                    result(
                        try FileManager.default.contentsOfDirectory(
                            at: directory, includingPropertiesForKeys: [.fileSizeKey, .creationDateKey]
                        )
                        .filter {
                            method == "audio.list"
                                ? $0.pathExtension == "m4a" : ["mov", "mp4"].contains($0.pathExtension)
                        }
                        .map { url -> [String: Any] in
                            let attrs = try url.resourceValues(forKeys: [.fileSizeKey, .creationDateKey])
                            return [
                                "name": url.lastPathComponent, "bytes": attrs.fileSize ?? 0,
                                "created": attrs.creationDate?.timeIntervalSince1970 ?? 0
                            ]
                        }.sorted {
                            ($0["created"] as? Double ?? 0) > ($1["created"] as? Double ?? 0)
                        })
                /// 执行 audio.play 原生操作。
                case "audio.play":
                    let url = try file(args)
                    let session = AVAudioSession.sharedInstance()
                    try session.setCategory(.playback, mode: .default)
                    try session.setActive(true)
                    let value = try AVAudioPlayer(contentsOf: url)
                    player = value
                    result(value.play())
                /// 执行 audio.stopPlayback 原生操作。
                case "audio.stopPlayback":
                    player?.stop()
                    player = nil
                    result(true)
                /// 执行 audio.delete, video.delete 原生操作。
                case "audio.delete", "video.delete":
                    let url = try file(args)
                    guard recorder?.url != url || recorder?.isRecording != true else {
                        throw JobsLabError("Cannot delete active recording")
                    }
                    try FileManager.default.removeItem(at: url)
                    result(true)
                /// 取消和重拍只删除相机产生的临时视频，不接受文档目录路径。
                case "video.discard":
                    guard let path = args["path"] as? String, !path.isEmpty else {
                        throw JobsLabError("Camera temporary file path is required")
                    }
                    let temporary = URL(fileURLWithPath: path).standardizedFileURL.resolvingSymlinksInPath()
                    let roots =
                        [URL(fileURLWithPath: NSTemporaryDirectory())]
                        + FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
                    guard ["mov", "mp4"].contains(temporary.pathExtension.lowercased()),
                        roots.contains(where: { root in
                            let base = root.standardizedFileURL.resolvingSymlinksInPath().path
                            return temporary.path.hasPrefix(base + (base.hasSuffix("/") ? "" : "/"))
                        }),
                        try temporary.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile == true
                    else {
                        throw JobsLabError("Only camera video files in this app temporary directories can be discarded")
                    }
                    try FileManager.default.removeItem(at: temporary)
                    result(true)
                /// 接收自有相机录制文件，验证视频轨后归入统一录制目录。
                case "video.import":
                    Task { @MainActor in
                        var destination: URL?
                        do {
                            let imported = try importVideo(args)
                            destination = imported
                            let asset = AVURLAsset(url: imported)
                            let tracks = try await asset.loadTracks(withMediaType: .video)
                            guard !tracks.isEmpty else {
                                throw JobsLabError("Imported file has no video track")
                            }
                            let duration = try await asset.load(.duration).seconds
                            guard duration.isFinite && duration > 0 else {
                                throw JobsLabError("Imported video duration is invalid")
                            }
                            let filter = args["filter"] as? String ?? "normal"
                            let rendered = try await renderVideo(imported, filter: filter)
                            destination = rendered
                            if rendered != imported {
                                try? FileManager.default.removeItem(at: imported)
                            }
                            let output = AVURLAsset(url: rendered)
                            let audio = try await output.loadTracks(withMediaType: .audio)
                            let attributes = try rendered.resourceValues(forKeys: [.fileSizeKey])
                            result([
                                "name": rendered.lastPathComponent, "path": rendered.path,
                                "duration": duration, "bytes": attributes.fileSize ?? 0,
                                "filter": filter, "audioTracks": audio.count
                            ])
                        } catch {
                            if let destination {
                                try? FileManager.default.removeItem(at: destination)
                            }
                            result(
                                FlutterError(code: "video_import", message: error.localizedDescription, details: nil))
                        }
                    }
                /// 执行 video.record 原生操作。
                case "video.record":
                    guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                        throw JobsLabError("Camera unavailable on this device")
                    }
                    guard videoResult == nil, let presenter = Self.presenter else {
                        throw JobsLabError("Video capture already open")
                    }
                    let controller = UIImagePickerController()
                    controller.sourceType = .camera
                    controller.mediaTypes = [UTType.movie.identifier]
                    controller.videoQuality = .typeHigh
                    controller.videoMaximumDuration = min(max(args["maxSeconds"] as? Double ?? 60, 1), 600)
                    controller.delegate = self
                    videoResult = result
                    presenter.present(controller, animated: true)
                /// 执行 video.saveToPhotos 原生操作。
                case "video.saveToPhotos":
                    let url = try file(args)
                    PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                        guard status == .authorized || status == .limited else {
                            DispatchQueue.main.async {
                                result(
                                    FlutterError(
                                        code: "permission", message: "Photo library permission denied", details: nil))
                            }
                            return
                        }
                        PHPhotoLibrary.shared().performChanges({
                            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
                        }) { saved, error in
                            DispatchQueue.main.async {
                                result(
                                    error.map {
                                        FlutterError(code: "photos", message: $0.localizedDescription, details: nil)
                                    } ?? saved)
                            }
                        }
                    }
                /// 执行 video.streamStart 原生操作。
                case "video.streamStart":
                    guard let raw = args["url"] as? String, let url = URL(string: raw),
                        ["ws", "wss"].contains(url.scheme?.lowercased() ?? "")
                    else {
                        throw JobsLabError("Use a ws:// or wss:// JPEG frame receiver")
                    }
                    AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                        guard let self else {
                            return
                        }
                        guard granted else {
                            DispatchQueue.main.async {
                                result(
                                    FlutterError(code: "permission", message: "Camera permission denied", details: nil))
                            }
                            return
                        }
                        self.captureQueue.async {
                            do {
                                self.stopStream()
                                let session = AVCaptureSession()
                                session.sessionPreset = .vga640x480
                                guard let device = AVCaptureDevice.default(for: .video) else {
                                    throw JobsLabError("Camera unavailable")
                                }
                                let input = try AVCaptureDeviceInput(device: device)
                                guard session.canAddInput(input) else {
                                    throw JobsLabError("Camera input unavailable")
                                }
                                session.addInput(input)
                                let output = AVCaptureVideoDataOutput()
                                output.alwaysDiscardsLateVideoFrames = true
                                output.setSampleBufferDelegate(self, queue: self.captureQueue)
                                guard session.canAddOutput(output) else {
                                    throw JobsLabError("Video output unavailable")
                                }
                                session.addOutput(output)
                                let socket = URLSession.shared.webSocketTask(with: url)
                                socket.resume()
                                self.socket = socket
                                self.frames = 0
                                self.streamSession = session
                                session.startRunning()
                                self.publish(
                                    "video", ["event": "streamStarted", "protocol": "websocket-jpeg", "audio": false])
                                DispatchQueue.main.async {
                                    result(true)
                                }
                            } catch {
                                DispatchQueue.main.async {
                                    result(
                                        FlutterError(code: "stream", message: error.localizedDescription, details: nil))
                                }
                            }
                        }
                    }
                /// 执行 video.streamStop 原生操作。
                case "video.streamStop":
                    captureQueue.async {
                        self.stopStream()
                    }
                    result(true)
                /// 未匹配的操作返回未实现。
                default:
                    result(FlutterMethodNotImplemented)
            }
        } catch {
            result(FlutterError(code: "media", message: error.localizedDescription, details: nil))
        }
    }

    private func requestAudioPermission(_ callback: @escaping (Bool) -> Void) {
        let completion: (Bool) -> Void = { granted in
            DispatchQueue.main.async {
                callback(granted)
            }
        }
        if #available(iOS 17.0, *) {
            AVAudioApplication.requestRecordPermission(completionHandler: completion)
        } else {
            AVAudioSession.sharedInstance().requestRecordPermission(completion)
        }
    }

    private func renderVideo(_ source: URL, filter: String) async throws -> URL {
        guard filter != "normal" else {
            return source
        }
        let names = [
            "mono": "CIPhotoEffectMono", "noir": "CIPhotoEffectNoir", "sepia": "CISepiaTone",
            "chrome": "CIPhotoEffectChrome", "instant": "CIPhotoEffectInstant", "fade": "CIPhotoEffectFade"
        ]
        guard let name = names[filter], CIFilter(name: name) != nil else {
            throw JobsLabError("Unknown or unavailable video filter")
        }
        let asset = AVURLAsset(url: source)
        guard let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {
            throw JobsLabError("Video export session is unavailable")
        }
        let context = CIContext(options: [.cacheIntermediates: false])
        exporter.videoComposition = AVVideoComposition(
            asset: asset,
            applyingCIFiltersWithHandler: { request in
                // Create a filter per frame: AVFoundation may request frames concurrently.
                guard let effect = CIFilter(name: name) else {
                    request.finish(with: JobsLabError("Video filter is unavailable"))
                    return
                }
                effect.setDefaults()
                effect.setValue(request.sourceImage.clampedToExtent(), forKey: kCIInputImageKey)
                if filter == "sepia" {
                    effect.setValue(0.82, forKey: kCIInputIntensityKey)
                }
                guard let image = effect.outputImage else {
                    request.finish(with: JobsLabError("Video filter did not produce a frame"))
                    return
                }
                request.finish(with: image.cropped(to: request.sourceImage.extent), context: context)
            })
        exporter.shouldOptimizeForNetworkUse = true
        let destination = directory.appendingPathComponent(UUID().uuidString + ".mp4")
        publish("video", ["event": "filterExportStarted", "filter": filter])
        do {
            if #available(iOS 18.0, *) {
                try await exporter.export(to: destination, as: .mp4)
            } else {
                exporter.outputURL = destination
                exporter.outputFileType = .mp4
                // Legacy completion is Sendable in new SDKs; keep the session in this task.
                exporter.exportAsynchronously(completionHandler: {})
                while [.unknown, .waiting, .exporting].contains(exporter.status) {
                    try await Task.sleep(nanoseconds: 50_000_000)
                }
                guard exporter.status == .completed else {
                    throw exporter.error ?? JobsLabError("Video filter export failed")
                }
            }
            publish("video", ["event": "filterExportFinished", "filter": filter])
            return destination
        } catch {
            exporter.cancelExport()
            try? FileManager.default.removeItem(at: destination)
            throw error
        }
    }

    private func importVideo(_ args: [String: Any]) throws -> URL {
        let source: URL?
        if let path = args["path"] as? String, !path.isEmpty {
            let candidate = URL(fileURLWithPath: path).standardizedFileURL.resolvingSymlinksInPath()
            let home = URL(fileURLWithPath: NSHomeDirectory()).standardizedFileURL.resolvingSymlinksInPath().path
            guard candidate.path.hasPrefix(home + "/"),
                try candidate.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile == true
            else {
                throw JobsLabError("Import source must be a file inside this app sandbox")
            }
            source = candidate
        } else {
            source = nil
        }
        let requestedExtension = (args["extension"] as? String ?? source?.pathExtension ?? "mp4").lowercased()
        guard ["mp4", "mov"].contains(requestedExtension) else {
            throw JobsLabError("Import requires an MP4 or MOV video")
        }
        let destination = directory.appendingPathComponent(UUID().uuidString + "." + requestedExtension)
        do {
            if let source {
                try FileManager.default.copyItem(at: source, to: destination)
            } else if let bytes = args["bytes"] as? FlutterStandardTypedData, !bytes.data.isEmpty {
                try bytes.data.write(to: destination, options: .atomic)
            } else {
                throw JobsLabError("Video bytes or a camera file path are required")
            }
        } catch {
            try? FileManager.default.removeItem(at: destination)
            throw error
        }
        return destination
    }

    private func file(_ args: [String: Any]) throws -> URL {
        guard let name = args["name"] as? String, !name.isEmpty, name == URL(fileURLWithPath: name).lastPathComponent,
            !name.contains(".."), ["m4a", "mov", "mp4"].contains(URL(fileURLWithPath: name).pathExtension)
        else {
            throw JobsLabError("Invalid recording name")
        }
        let url = directory.appendingPathComponent(name)
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw JobsLabError("Recording no longer exists")
        }
        return url
    }

    private static var presenter: UIViewController? {
        var value = UIApplication.shared.connectedScenes.compactMap {
            $0 as? UIWindowScene
        }
        .flatMap(\.windows).first(where: \.isKeyWindow)?.rootViewController
        while let presented = value?.presentedViewController {
            value = presented
        }
        return value
    }

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        meter?.invalidate()
        publish("audio", ["event": "finished", "name": recorder.url.lastPathComponent, "saved": flag])
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        videoResult?(nil)
        videoResult = nil
    }

    func imagePickerController(
        _ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        picker.dismiss(animated: true)
        do {
            guard let source = info[.mediaURL] as? URL else {
                throw JobsLabError("No captured video")
            }
            let destination = directory.appendingPathComponent(UUID().uuidString + ".mov")
            try FileManager.default.copyItem(at: source, to: destination)
            videoResult?(["name": destination.lastPathComponent])
        } catch {
            videoResult?(FlutterError(code: "video", message: error.localizedDescription, details: nil))
        }
        videoResult = nil
    }

    private func stopStream() {
        streamSession?.stopRunning()
        streamSession = nil
        socket?.cancel(with: .normalClosure, reason: nil)
        socket = nil
        sendingFrame = false
    }

    func captureOutput(
        _ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection
    ) {
        let now = ProcessInfo.processInfo.systemUptime
        guard !sendingFrame, now - lastFrame >= 0.2, let socket,
            let buffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        else {
            return
        }
        lastFrame = now
        let image = CIImage(cvPixelBuffer: buffer)
        guard let cgImage = imageContext.createCGImage(image, from: image.extent),
            let jpeg = UIImage(cgImage: cgImage).jpegData(compressionQuality: 0.55)
        else {
            return
        }
        sendingFrame = true
        socket.send(.data(jpeg)) { [weak self] error in
            self?.captureQueue.async {
                guard let self else {
                    return
                }
                self.sendingFrame = false
                if let error {
                    self.publish("video", ["event": "streamError", "error": error.localizedDescription])
                    self.stopStream()
                } else {
                    self.frames += 1
                    self.publish("video", ["event": "frameSent", "frames": self.frames, "bytes": jpeg.count])
                }
            }
        }
    }
}
