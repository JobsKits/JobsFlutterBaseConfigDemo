//
//  JobsRTMPLab.swift
//  JobsPlatformLabByPub
//
//  Created by Jobs on 2026年11月14日，星期六.
//

import AVFoundation
import Flutter
import HaishinKit

/// HaishinKit 2.0.9 adapter; publishing success is returned only after RTMP acknowledgement.
final class JobsRTMPLab {
    private let mixer = MediaMixer()
    private let connection = RTMPConnection()
    private lazy var stream = RTMPStream(connection: connection)
    private let publish: (String, [String: Any]) -> Void
    private var generation = 0
    private var running = false

    init(publish: @escaping (String, [String: Any]) -> Void) {
        self.publish = publish
    }

    func handle(_ action: String, args: [String: Any], result: @escaping FlutterResult) {
        if action == "stop" {
            generation += 1
            Task { @MainActor in
                do {
                    try await connection.close()
                    await mixer.stopRunning()
                    running = false
                    publish("video", ["event": "rtmpStopped"])
                    await MainActor.run {
                        result(true)
                    }
                } catch {
                    await mixer.stopRunning()
                    running = false
                    await MainActor.run {
                        result(FlutterError(code: "rtmp", message: error.localizedDescription, details: nil))
                    }
                }
            }
            return
        }
        guard action == "start", !running else {
            result(FlutterError(code: "rtmp", message: "Stream already running or invalid action", details: nil))
            return
        }
        guard let raw = args["url"] as? String, let url = URL(string: raw),
            ["rtmp", "rtmps"].contains(url.scheme ?? ""), !url.lastPathComponent.isEmpty,
            url.pathComponents.count >= 3
        else {
            result(FlutterError(code: "rtmp", message: "Enter a full rtmp(s)://host/app/stream-key URL", details: nil))
            return
        }
        let streamName =
            url.lastPathComponent
            + (url.query.map {
                "?" + $0
            } ?? "")
        var components = URLComponents(url: url.deletingLastPathComponent(), resolvingAgainstBaseURL: false)
        components?.query = nil
        guard let server = components?.string, url.host?.isEmpty == false else {
            result(FlutterError(code: "rtmp", message: "RTMP server is missing", details: nil))
            return
        }
        generation += 1
        let token = generation
        running = true
        Task { @MainActor in
            do {
                let cameraGranted = await AVCaptureDevice.requestAccess(for: .video)
                let audioGranted = await AVCaptureDevice.requestAccess(for: .audio)
                guard cameraGranted && audioGranted else {
                    throw JobsLabError("Camera and microphone permission required")
                }
                guard token == generation else {
                    throw CancellationError()
                }
                guard let video = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                    let audio = AVCaptureDevice.default(for: .audio)
                else {
                    throw JobsLabError("Camera or microphone unavailable")
                }
                let audioSession = AVAudioSession.sharedInstance()
                try audioSession.setCategory(
                    .playAndRecord, mode: .videoRecording, options: [.defaultToSpeaker, .allowBluetoothHFP])
                try audioSession.setActive(true)
                try await mixer.attachVideo(video)
                guard token == generation else {
                    throw CancellationError()
                }
                try await mixer.attachAudio(audio)
                guard token == generation else {
                    throw CancellationError()
                }
                await mixer.addOutput(stream)
                guard token == generation else {
                    throw CancellationError()
                }
                await mixer.startRunning()
                guard token == generation else {
                    throw CancellationError()
                }
                _ = try await connection.connect(server)
                guard token == generation else {
                    throw CancellationError()
                }
                _ = try await stream.publish(streamName)
                guard token == generation else {
                    throw CancellationError()
                }
                publish("video", ["event": "rtmpPublishing", "protocol": "rtmp", "audio": true])
                await MainActor.run {
                    result(true)
                }
            } catch {
                // A cancelled permission dialog can complete after a new stream has started.
                if token == generation {
                    try? await connection.close()
                    await mixer.stopRunning()
                    running = false
                }
                let message = error.localizedDescription.replacingOccurrences(of: raw, with: "[RTMP endpoint]")
                publish("video", ["event": "rtmpError", "error": message])
                await MainActor.run {
                    result(FlutterError(code: "rtmp", message: message, details: nil))
                }
            }
        }
    }
}
