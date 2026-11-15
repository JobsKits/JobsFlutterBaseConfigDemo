//
//  JobsPlayerLab.swift
//  JobsPlatformLabByPub
//
//  Created by Jobs on 2026年11月14日，星期六.
//

import AVFoundation
import AVKit
import UIKit
import Flutter

final class JobsPlayerViewFactory: NSObject, FlutterPlatformViewFactory {
    private weak var owner: JobsPlatformLabPlugin?

    init(owner: JobsPlatformLabPlugin) {
        self.owner = owner
    }

    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        let view = JobsPlayerPlatformView(frame: frame, id: viewId, owner: owner)
        owner?.registerPlayer(view, id: viewId)
        return view
    }
}

private final class JobsPlayerSurface: UIView {
    override class var layerClass: AnyClass {
        AVPlayerLayer.self
    }

    var playerLayer: AVPlayerLayer {
        layer as! AVPlayerLayer
    }
}

private final class JobsPlayerFullScreenController: AVPlayerViewController {
    var returned: (() -> Void)?

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isBeingDismissed || presentingViewController == nil {
            returned?()
        }
    }
}

final class JobsPlayerPlatformView: NSObject, FlutterPlatformView, AVPictureInPictureControllerDelegate,
    UIAdaptivePresentationControllerDelegate
{
    private weak var owner: JobsPlatformLabPlugin?
    private let identifier: Int64
    private let surface: JobsPlayerSurface
    private let player = AVPlayer()
    private var pip: AVPictureInPictureController?
    private var periodic: Any?
    private var status: NSKeyValueObservation?
    private var accessLog: NSObjectProtocol?
    private var localFile: URL?
    private var fullScreen: AVPlayerViewController?

    init(frame: CGRect, id: Int64, owner: JobsPlatformLabPlugin?) {
        identifier = id
        self.owner = owner
        surface = JobsPlayerSurface(frame: frame)
        super.init()
        surface.backgroundColor = .black
        surface.playerLayer.player = player
        surface.playerLayer.videoGravity = .resizeAspect
        if AVPictureInPictureController.isPictureInPictureSupported() {
            pip = AVPictureInPictureController(playerLayer: surface.playerLayer)
            pip?.delegate = self
            pip?.canStartPictureInPictureAutomaticallyFromInline = true
        }
        periodic = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 10), queue: .main)
        { [weak self] _ in
            self?.publish("progress")
        }
    }

    func view() -> UIView {
        surface
    }

    func command(_ args: [String: Any], result: @escaping FlutterResult) {
        do {
            switch args["action"] as? String ?? "" {
                /// Replace the native item, then observe readiness and decoding failures.
                case "load":
                    try load(args)
                    result(["loading": true, "pipSupported": AVPictureInPictureController.isPictureInPictureSupported()]
                    )
                /// Resume the same item used by inline, floating and picture-in-picture playback.
                case "play":
                    guard player.currentItem != nil else {
                        throw JobsLabError("Load a video first")
                    }
                    player.play()
                    result(true)
                /// Pause without recreating the decoder or losing the current position.
                case "pause":
                    player.pause()
                    result(true)
                /// Seek results come from AVPlayer completion, rather than a local slider guess.
                case "seek":
                    guard let seconds = args["seconds"] as? Double, seconds.isFinite, seconds >= 0 else {
                        throw JobsLabError("Seek seconds must be finite and non-negative")
                    }
                    player.seek(to: CMTime(seconds: seconds, preferredTimescale: 600)) { finished in
                        DispatchQueue.main.async {
                            result(finished)
                        }
                    }
                /// PiP is a system AVKit session and reports unsupported hardware explicitly.
                case "pip":
                    guard let pip, pip.isPictureInPicturePossible else {
                        throw JobsLabError("System picture-in-picture is unavailable until a supported video is ready")
                    }
                    pip.startPictureInPicture()
                    result(true)
                /// System full screen uses the same AVPlayer, preserving playback position.
                case "fullScreen":
                    try presentFullScreen()
                    result(true)
                /// Access-log byte and bitrate values are the actual AVPlayerItem values.
                case "traffic":
                    result(traffic())
                /// Unmatched controls must fail visibly.
                default:
                    result(FlutterMethodNotImplemented)
            }
        } catch {
            result(FlutterError(code: "player", message: error.localizedDescription, details: nil))
        }
    }

    private func load(_ args: [String: Any]) throws {
        let url: URL
        if let bytes = args["bytes"] as? FlutterStandardTypedData, !bytes.data.isEmpty {
            let directory = FileManager.default.temporaryDirectory.appendingPathComponent(
                "JobsPlayerLab", isDirectory: true)
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            url = directory.appendingPathComponent(UUID().uuidString + ".mp4")
            try bytes.data.write(to: url, options: .atomic)
            removeLocalFile()
            localFile = url
        } else if let path = args["path"] as? String, !path.isEmpty {
            let candidate = URL(fileURLWithPath: path).standardizedFileURL.resolvingSymlinksInPath()
            let home = URL(fileURLWithPath: NSHomeDirectory()).standardizedFileURL.resolvingSymlinksInPath().path
            guard candidate.path.hasPrefix(home + "/"),
                ["mp4", "mov"].contains(candidate.pathExtension.lowercased()),
                try candidate.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile == true
            else {
                throw JobsLabError("Local player paths must point to a video inside this app sandbox")
            }
            url = candidate
            removeLocalFile()
        } else if let raw = args["url"] as? String, let remote = URL(string: raw),
            ["http", "https"].contains(remote.scheme?.lowercased() ?? ""), remote.host?.isEmpty == false
        {
            url = remote
            removeLocalFile()
        } else {
            throw JobsLabError("Provide local video bytes or a valid HTTP(S) video URL")
        }
        status = nil
        if let accessLog {
            NotificationCenter.default.removeObserver(accessLog)
        }
        let item = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: item)
        status = item.observe(\.status, options: [.initial, .new]) { [weak self] item, _ in
            DispatchQueue.main.async {
                if item.status == .readyToPlay {
                    self?.publish("ready")
                } else if item.status == .failed {
                    self?.publish(
                        "error", extra: ["error": item.error?.localizedDescription ?? "Video could not be decoded"])
                }
            }
        }
        accessLog = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemNewAccessLogEntry, object: item, queue: .main
        ) { [weak self] _ in
            guard let self else {
                return
            }
            self.publish("traffic", extra: self.traffic())
        }
        let audio = AVAudioSession.sharedInstance()
        try audio.setCategory(.playback, mode: .moviePlayback)
        try audio.setActive(true)
        if args["autoplay"] as? Bool != false {
            player.play()
        }
    }

    private func traffic() -> [String: Any] {
        let events = player.currentItem?.accessLog()?.events ?? []
        return [
            "bytesTransferred": events.reduce(Int64(0)) {
                $0 + $1.numberOfBytesTransferred
            },
            "observedBitrate": events.last?.observedBitrate ?? 0,
            "indicatedBitrate": events.last?.indicatedBitrate ?? 0,
            "scope": "player"
        ]
    }

    private func presentFullScreen() throws {
        guard player.currentItem != nil,
            var presenter = surface.window?.rootViewController
        else {
            throw JobsLabError("Load a video in an active window first")
        }
        while let presented = presenter.presentedViewController {
            presenter = presented
        }
        let controller = JobsPlayerFullScreenController()
        controller.player = player
        controller.allowsPictureInPicturePlayback = true
        controller.modalPresentationStyle = .fullScreen
        controller.presentationController?.delegate = self
        controller.returned = { [weak self] in
            self?.restoreInline()
        }
        fullScreen = controller
        presenter.present(controller, animated: true)
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        restoreInline()
    }

    private func restoreInline() {
        fullScreen = nil
        surface.playerLayer.player = nil
        surface.playerLayer.player = player
    }

    private func publish(_ event: String, extra: [String: Any] = [:]) {
        let duration = player.currentItem?.duration.seconds ?? 0
        let position = player.currentTime().seconds
        var value: [String: Any] = [
            "viewId": identifier, "event": event,
            "position": position.isFinite ? position : 0,
            "duration": duration.isFinite ? duration : 0,
            "isPlaying": player.rate != 0
        ]
        value.merge(extra) {
            _, new in new
        }
        owner?.publish("player", value)
    }

    func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController)
    {
        publish("pipStarted")
    }

    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        publish("pipStopped")
    }

    func pictureInPictureController(
        _ pictureInPictureController: AVPictureInPictureController,
        restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void
    ) {
        surface.window?.makeKeyAndVisible()
        completionHandler(surface.window != nil)
    }

    func pictureInPictureController(
        _ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error
    ) {
        publish("error", extra: ["error": error.localizedDescription])
    }

    private func removeLocalFile() {
        if let localFile {
            try? FileManager.default.removeItem(at: localFile)
        }
        localFile = nil
    }

    deinit {
        player.pause()
        if let periodic {
            player.removeTimeObserver(periodic)
        }
        if let accessLog {
            NotificationCenter.default.removeObserver(accessLog)
        }
        pip?.stopPictureInPicture()
        removeLocalFile()
        owner?.removePlayer(id: identifier)
    }
}
