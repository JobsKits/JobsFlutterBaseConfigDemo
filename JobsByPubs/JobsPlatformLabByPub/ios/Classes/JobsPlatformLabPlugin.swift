//
//  JobsPlatformLabPlugin.swift
//  JobsPlatformLabByPub
//
//  Created by Jobs on 2026年11月14日，星期六.
//

import UIKit
import CoreMotion
import AVFoundation
import WidgetKit
import Flutter

public final class JobsPlatformLabPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    /// 宿主为独立 FlutterEngine 注册完整插件；避免只注册此插件导致其它 Pub 通道缺失。
    public static var registerSecondaryEngine: ((FlutterEngine) -> Void)?

    private var sink: FlutterEventSink?
    private var observers: [NSObjectProtocol] = []
    private let motion = CMMotionManager()
    private var cover: UIView?
    private var shieldEnabled = false
    private var shieldMessage = "Content hidden while recording"
    private var arViews: [Int64: WeakARView] = [:]
    private var playerViews: [Int64: WeakPlayerView] = [:]
    private lazy var ble = JobsBLELab(publish: publish)
    private lazy var media = JobsMediaLab(publish: publish)
    private lazy var rtmp = JobsRTMPLab(publish: publish)
    private let documents = JobsDocumentUnityLab()
    private let runtime = JobsRuntimeLab()

    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = JobsPlatformLabPlugin()
        let methods = FlutterMethodChannel(name: "jobs_platform_lab/methods", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: methods)
        FlutterEventChannel(name: "jobs_platform_lab/events", binaryMessenger: registrar.messenger()).setStreamHandler(
            instance)
        registrar.register(JobsARViewFactory(owner: instance), withId: "jobs_platform_lab/ar")
        registrar.register(JobsPlayerViewFactory(owner: instance), withId: "jobs_platform_lab/player")
        instance.observeCapture()
    }

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        sink = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        sink = nil
        return nil
    }

    func registerAR(_ view: JobsARPlatformView, id: Int64) {
        arViews[id] = WeakARView(view)
    }

    func removeAR(id: Int64) {
        arViews.removeValue(forKey: id)
    }

    func registerPlayer(_ view: JobsPlayerPlatformView, id: Int64) {
        playerViews[id] = WeakPlayerView(view)
    }

    func removePlayer(id: Int64) {
        playerViews.removeValue(forKey: id)
    }

    func publish(_ topic: String, _ payload: [String: Any]) {
        DispatchQueue.main.async { [weak self] in
            self?.sink?(["topic": topic, "time": Date().timeIntervalSince1970, "data": payload])
        }
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? [String: Any] ?? [:]
        if call.method.hasPrefix("runtime.") {
            runtime.handle(call.method, args: args, result: result)
            return
        }
        if call.method.hasPrefix("ble.") {
            ble.handle(String(call.method.dropFirst(4)), args: args, result: result)
            return
        }
        if call.method.hasPrefix("rtmp.") {
            rtmp.handle(String(call.method.dropFirst(5)), args: args, result: result)
            return
        }
        if call.method.hasPrefix("pdf.") || call.method.hasPrefix("unity.") {
            documents.handle(call.method, args: args, result: result)
            return
        }
        if call.method.hasPrefix("audio.") || call.method.hasPrefix("video.") {
            media.handle(call.method, args: args, result: result)
            return
        }
        do {
            switch call.method {
            case "bridge.presentHost":
                JobsFlutterInterop.present(args: args, result: result)

            /// 执行 player.command 原生操作。
            case "player.command":
                guard let id = args["viewId"] as? NSNumber, let view = playerViews[id.int64Value]?.value else {
                    throw JobsLabError("Player view is not attached")
                }
                view.command(args, result: result)
            /// 执行 capabilities 原生操作。
            case "capabilities":
                result([
                    "platform": "ios", "arkit": JobsARPlatformView.isSupported, "ble": true,
                    "motion": motion.isDeviceMotionAvailable, "accelerometer": motion.isAccelerometerAvailable,
                    "gyroscope": motion.isGyroAvailable, "magnetometer": motion.isMagnetometerAvailable,
                    "recording": true, "multipleScenes": UIApplication.shared.supportsMultipleScenes,
                    "alternateIcons": UIApplication.shared.supportsAlternateIcons
                ])
            /// 执行 motion.start 原生操作。
            case "motion.start":
                try startMotion(args)
                result(true)
            /// 执行 motion.stop 原生操作。
            case "motion.stop":
                stopMotion()
                result(true)
            /// 执行 ar.command 原生操作。
            case "ar.command":
                guard let id = args["viewId"] as? NSNumber, let view = arViews[id.int64Value]?.value else {
                    throw JobsLabError("AR view is not attached")
                }
                try view.command(args)
                result(true)
            /// 执行 screen.protect 原生操作。
            case "screen.protect":
                shieldEnabled = args["enabled"] as? Bool ?? false
                shieldMessage = args["message"] as? String ?? shieldMessage
                refreshCover()
                result(["recording": captured, "screenshotBlocking": false])
            /// 执行 screen.status 原生操作。
            case "screen.status":
                result(["recording": captured, "screenshotBlocking": false])
            /// 执行 clipboard.write 原生操作。
            case "clipboard.write":
                UIPasteboard.general.string = args["text"] as? String ?? ""
                result(true)
            /// 执行 clipboard.read 原生操作。
            case "clipboard.read":
                result(UIPasteboard.general.string ?? "")
            /// 执行 system.share 原生操作。
            case "system.share":
                guard
                    let window = UIApplication.shared.connectedScenes.compactMap({
                        $0 as? UIWindowScene
                    }).flatMap(\.windows).first(where: \.isKeyWindow),
                    var presenter = window.rootViewController
                else {
                    throw JobsLabError("No active window for sharing")
                }
                while let presented = presenter.presentedViewController {
                    presenter = presented
                }
                var items: [Any] = []
                if let text = args["text"] as? String, !text.isEmpty {
                    items.append(text)
                }
                if let raw = args["url"] as? String, !raw.isEmpty {
                    guard let url = URL(string: raw), ["http", "https"].contains(url.scheme?.lowercased() ?? ""),
                        url.host?.isEmpty == false
                    else {
                        throw JobsLabError("Sharing requires a valid HTTP(S) URL")
                    }
                    items.append(url)
                }
                guard !items.isEmpty else {
                    throw JobsLabError("Share text or URL is required")
                }
                let sheet = UIActivityViewController(activityItems: items, applicationActivities: nil)
                sheet.completionWithItemsHandler = { [weak self] _, completed, _, error in
                    self?.publish(
                        "system",
                        ["event": "shared", "completed": completed, "error": error?.localizedDescription ?? ""])
                }
                sheet.popoverPresentationController?.sourceView = presenter.view
                sheet.popoverPresentationController?.sourceRect = CGRect(
                    x: presenter.view.bounds.midX, y: presenter.view.bounds.midY, width: 1, height: 1)
                presenter.present(sheet, animated: true) {
                    result(["presented": true])
                }
            /// 执行 url.open 原生操作。
            case "url.open":
                guard let raw = args["url"] as? String, let url = URL(string: raw),
                    ["https", "http", "mailto", "tel", "sms"].contains(url.scheme?.lowercased() ?? "")
                else {
                    throw JobsLabError("URL scheme is not allowed")
                }
                UIApplication.shared.open(url, options: [:]) {
                    opened in result(opened)
                }
            /// 执行 icon.set 原生操作。
            case "icon.set":
                let name = args["name"] as? String
                UIApplication.shared.setAlternateIconName(name?.isEmpty == true ? nil : name) { error in
                    result(
                        error.map {
                            FlutterError(code: "icon", message: $0.localizedDescription, details: nil)
                        } ?? true)
                }
            /// 执行 icon.status 原生操作。
            case "icon.status":
                let info = Bundle.main.object(forInfoDictionaryKey: "CFBundleIcons") as? [String: Any] ?? [:]
                let alternatives = info["CFBundleAlternateIcons"] as? [String: Any] ?? [:]
                result([
                    "current": UIApplication.shared.alternateIconName ?? "", "names": alternatives.keys.sorted()
                ])
            /// 执行 device.risk 原生操作。
            case "device.risk":
                result(deviceRisk())
            /// 执行 scenes.list 原生操作。
            case "scenes.list":
                result(
                    UIApplication.shared.connectedScenes.map { scene in
                        [
                            "id": scene.session.persistentIdentifier,
                            "role": scene.session.role.rawValue,
                            "state": scene.activationState.rawValue
                        ] as [String: Any]
                    })
            /// 执行 scenes.open 原生操作。
            case "scenes.open":
                guard UIApplication.shared.supportsMultipleScenes else {
                    throw JobsLabError("Host does not support multiple scenes")
                }
                let activity = NSUserActivity(activityType: "com.jobs.platformlab.scene")
                activity.title = args["title"] as? String ?? "Jobs Platform Lab"
                if #available(iOS 17.0, *) {
                    let request = UISceneSessionActivationRequest(userActivity: activity)
                    UIApplication.shared.activateSceneSession(for: request) { error in
                        self.publish("scenes", ["error": error.localizedDescription])
                    }
                } else {
                    UIApplication.shared.requestSceneSessionActivation(nil, userActivity: activity, options: nil) {
                        error in
                        self.publish("scenes", ["error": error.localizedDescription])
                    }
                }
                result(true)
            /// 执行 widget.write 原生操作。
            case "widget.write":
                guard let group = Bundle.main.object(forInfoDictionaryKey: "JobsWidgetAppGroup") as? String,
                    FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: group) != nil,
                    let store = UserDefaults(suiteName: group)
                else {
                    throw JobsLabError("Widget app group entitlement is missing")
                }
                let text = args["text"] as? String ?? "Jobs Flutter"
                store.set(text, forKey: "jobs.widget.text")
                store.set(Date().timeIntervalSince1970, forKey: "jobs.widget.updated")
                WidgetCenter.shared.reloadAllTimelines()
                result(["text": text, "group": group])
            /// 执行 widget.read 原生操作。
            case "widget.read":
                let group = Bundle.main.object(forInfoDictionaryKey: "JobsWidgetAppGroup") as? String ?? ""
                result([
                    "text": UserDefaults(suiteName: group)?.string(forKey: "jobs.widget.text") ?? "", "group": group
                ])
            /// 未匹配的操作返回未实现。
            default:
                result(FlutterMethodNotImplemented)
            }
        } catch {
            result(FlutterError(code: "platform_lab", message: error.localizedDescription, details: nil))
        }
    }

    private func startMotion(_ args: [String: Any]) throws {
        stopMotion()
        let interval = min(max((args["intervalMs"] as? Double ?? 100) / 1000, 0.02), 1)
        let kind = args["kind"] as? String ?? "device"
        if kind == "device", motion.isDeviceMotionAvailable {
            motion.deviceMotionUpdateInterval = interval
            motion.startDeviceMotionUpdates(to: .main) { [weak self] value, error in
                guard let value else {
                    self?.publish("motion", ["error": error?.localizedDescription ?? "Unavailable"])
                    return
                }
                self?.publish(
                    "motion",
                    [
                        "kind": kind, "roll": value.attitude.roll, "pitch": value.attitude.pitch,
                        "yaw": value.attitude.yaw, "x": value.userAcceleration.x,
                        "y": value.userAcceleration.y, "z": value.userAcceleration.z
                    ])
            }
        } else if kind == "accelerometer", motion.isAccelerometerAvailable {
            motion.accelerometerUpdateInterval = interval
            motion.startAccelerometerUpdates(to: .main) { [weak self] value, _ in
                guard let value else {
                    return
                }
                self?.publish(
                    "motion",
                    ["kind": kind, "x": value.acceleration.x, "y": value.acceleration.y, "z": value.acceleration.z])
            }
        } else if kind == "gyroscope", motion.isGyroAvailable {
            motion.gyroUpdateInterval = interval
            motion.startGyroUpdates(to: .main) { [weak self] value, _ in
                guard let value else {
                    return
                }
                self?.publish(
                    "motion",
                    ["kind": kind, "x": value.rotationRate.x, "y": value.rotationRate.y, "z": value.rotationRate.z])
            }
        } else if kind == "magnetometer", motion.isMagnetometerAvailable {
            motion.magnetometerUpdateInterval = interval
            motion.startMagnetometerUpdates(to: .main) { [weak self] value, _ in
                guard let value else {
                    return
                }
                self?.publish(
                    "motion",
                    ["kind": kind, "x": value.magneticField.x, "y": value.magneticField.y, "z": value.magneticField.z])
            }
        } else {
            throw JobsLabError("Sensor unavailable: \(kind)")
        }
    }

    private func stopMotion() {
        motion.stopDeviceMotionUpdates()
        motion.stopAccelerometerUpdates()
        motion.stopGyroUpdates()
        motion.stopMagnetometerUpdates()
    }

    private var captured: Bool {
        UIApplication.shared.connectedScenes.compactMap {
            $0 as? UIWindowScene
        }.contains {
            $0.screen.isCaptured
        }
    }

    private func observeCapture() {
        for name in [UIApplication.userDidTakeScreenshotNotification, UIScreen.capturedDidChangeNotification] {
            observers.append(
                NotificationCenter.default.addObserver(forName: name, object: nil, queue: .main) { [weak self] note in
                    guard let self else {
                        return
                    }
                    self.publish(
                        "screen",
                        [
                            "event": note.name == UIApplication.userDidTakeScreenshotNotification
                                ? "screenshot" : "captureChanged", "recording": self.captured
                        ])
                    self.refreshCover()
                })
        }
    }

    private func refreshCover() {
        cover?.removeFromSuperview()
        cover = nil
        guard shieldEnabled && captured,
            let window = UIApplication.shared.connectedScenes.compactMap({
                $0 as? UIWindowScene
            })
            .flatMap(\.windows).first(where: \.isKeyWindow)
        else {
            return
        }
        let view = UIView(frame: window.bounds)
        view.backgroundColor = .systemBackground
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let label = UILabel(frame: view.bounds.insetBy(dx: 24, dy: 24))
        label.text = shieldMessage
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .label
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(label)
        window.addSubview(view)
        cover = view
    }

    private func deviceRisk() -> [String: Any] {
        #if targetEnvironment(simulator)
            return ["simulator": true, "indicators": [], "riskDetected": false]
        #else
            let paths = [
                "/Applications/Cydia.app", "/Library/MobileSubstrate/MobileSubstrate.dylib", "/bin/bash",
                "/usr/sbin/sshd", "/etc/apt"
            ]
            let found = paths.filter {
                FileManager.default.fileExists(atPath: $0)
            }
            return ["simulator": false, "indicators": found, "riskDetected": !found.isEmpty]
        #endif
    }

    deinit {
        observers.forEach(NotificationCenter.default.removeObserver)
        stopMotion()
        cover?.removeFromSuperview()
    }
}

struct JobsLabError: LocalizedError {
    let message: String
    init(_ message: String) {
        self.message = message
    }
    var errorDescription: String? {
        message
    }
}

private final class WeakARView {
    weak var value: JobsARPlatformView?
    init(_ value: JobsARPlatformView) {
        self.value = value
    }
}

private final class WeakPlayerView {
    weak var value: JobsPlayerPlatformView?
    init(_ value: JobsPlayerPlatformView) {
        self.value = value
    }
}
