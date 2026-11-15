//
//  JobsFlutterInterop.swift
//  JobsPlatformLabByPub
//
//  Created by Jobs on 2026年11月14日，星期六.
//

import Flutter
import UIKit

/// 持有原生宿主会话；其内部引擎与 App 首引擎完全独立。
final class JobsFlutterInterop {
    private static var activeHost: JobsNativeFlutterHostController?

    static func present(args: [String: Any], result: @escaping FlutterResult) {
        guard activeHost == nil else {
            result(FlutterError(code: "bridge_busy", message: "A native host is already open", details: nil))
            return
        }
        guard JobsPlatformLabPlugin.registerSecondaryEngine != nil else {
            result(
                FlutterError(
                    code: "bridge_registration", message: "Secondary engine registration is not configured",
                    details: nil))
            return
        }
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        guard
            let window = scenes.filter({ $0.activationState == .foregroundActive }).flatMap(\.windows).first(
                where: \.isKeyWindow),
            var presenter = window.rootViewController
        else {
            result(FlutterError(code: "bridge_window", message: "No active window", details: nil))
            return
        }
        while let presented = presenter.presentedViewController {
            presenter = presented
        }
        let host = JobsNativeFlutterHostController(parameters: args) { payload in
            activeHost = nil
            result(payload)
        }
        activeHost = host
        presenter.present(host, animated: true)
    }
}

private final class JobsNativeFlutterHostController: UIViewController {
    private let parameters: [String: Any]
    private var completion: FlutterResult?
    private var engine: FlutterEngine?
    private var channel: FlutterMethodChannel?
    private var flutterController: FlutterViewController?
    private var lastPayload: [String: Any]?
    private var secondaryLaunchCount = 0
    private var ending = false
    private lazy var output = UITextView.makeInterop { textView in
        textView.isEditable = false
        textView.font = .preferredFont(forTextStyle: .body)
        textView.adjustsFontForContentSizeCategory = true
        textView.backgroundColor = .secondarySystemBackground
        textView.textColor = .label
        textView.layer.cornerRadius = 12
        textView.text = label("等待Flutter回传")
        textView.accessibilityIdentifier = "jobs.interop.native.result"
    }
    private lazy var openButton = UIButton.makeInterop(title: label("原生按钮打开独立Flutter引擎")) { [weak self] in
        self?.openFlutter()
    }

    init(parameters: [String: Any], completion: @escaping FlutterResult) {
        self.parameters = parameters
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        isModalInPresentation = true
        if parameters["theme"] as? String == "dark" {
            overrideUserInterfaceStyle = .dark
        } else if parameters["theme"] as? String == "light" {
            overrideUserInterfaceStyle = .light
        }
    }

    required init?(coder: NSCoder) {
        fatalError("Use init(parameters:completion:)")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.accessibilityIdentifier = "jobs.interop.native.host"
        let title = UILabel.makeInterop { label in
            label.text = self.label("原生宿主页面")
            label.font = .preferredFont(forTextStyle: .title1)
            label.adjustsFontForContentSizeCategory = true
            label.textColor = .label
            label.numberOfLines = 0
        }
        let input = UILabel.makeInterop { label in
            label.text =
                "UIViewController\nrequestId: \(parameters["requestId"] ?? "")\nprefill: \(parameters["prefill"] ?? "")"
            label.font = .preferredFont(forTextStyle: .body)
            label.adjustsFontForContentSizeCategory = true
            label.textColor = .secondaryLabel
            label.numberOfLines = 0
        }
        openButton.accessibilityIdentifier = "jobs.interop.native.open"
        let closeButton = UIButton.makeInterop(title: label("关闭宿主返回首页")) { [weak self] in
            self?.closeHost()
        }
        closeButton.accessibilityIdentifier = "jobs.interop.native.close"
        let stack = UIStackView.makeInterop(views: [title, input, openButton, output, closeButton])
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            output.heightAnchor.constraint(greaterThanOrEqualToConstant: 100)
        ])
    }

    private func label(_ key: String) -> String {
        (parameters["labels"] as? [String: String])?[key] ?? key
    }

    private func openFlutter() {
        guard engine == nil, !ending else {
            return
        }
        let nextEngine = FlutterEngine(
            name: "jobs-roundtrip-\(UUID().uuidString)", project: nil, allowHeadlessExecution: false)
        engine = nextEngine
        guard nextEngine.run(withEntrypoint: "jobsNativeBridgeEntry") else {
            output.text = label("失败") + ": jobsNativeBridgeEntry"
            releaseEngine()
            return
        }
        secondaryLaunchCount += 1
        let nextChannel = FlutterMethodChannel(
            name: "jobs_platform_lab/native_round_trip", binaryMessenger: nextEngine.binaryMessenger)
        nextChannel.setMethodCallHandler { [weak self] call, result in
            guard let self else {
                result(FlutterError(code: "bridge_closed", message: "Native host closed", details: nil))
                return
            }
            switch call.method {
                case "load":
                    result(parameters)
                case "finish":
                    guard let payload = call.arguments as? [String: Any],
                        (payload["cancelled"] as? Bool == true || payload["requestId"] as? String == parameters["requestId"] as? String)
                    else {
                        result(
                            FlutterError(
                                code: "bridge_request", message: "requestId does not match native session", details: nil
                            ))
                        return
                    }
                    guard !ending else {
                        result(
                            FlutterError(code: "bridge_closed", message: "Flutter page already closing", details: nil))
                        return
                    }
                    ending = true
                    lastPayload = payload
                    if let data = try? JSONSerialization.data(
                        withJSONObject: payload, options: [.prettyPrinted, .sortedKeys]),
                        let text = String(data: data, encoding: .utf8)
                    {
                        output.text = text
                    }
                    // 先回复通道，再退出与销毁引擎，避免丢失 Flutter 的 pending reply。
                    result(nil)
                    flutterController?.dismiss(animated: true) { [weak self] in
                        self?.releaseEngine()
                    }
                default:
                    result(FlutterMethodNotImplemented)
            }
        }
        channel = nextChannel
        JobsPlatformLabPlugin.registerSecondaryEngine?(nextEngine)
        let controller = FlutterViewController(engine: nextEngine, nibName: nil, bundle: nil)
        controller.modalPresentationStyle = .fullScreen
        controller.isModalInPresentation = true
        flutterController = controller
        openButton.isEnabled = false
        present(controller, animated: true)
    }

    private func releaseEngine() {
        channel?.setMethodCallHandler(nil)
        channel = nil
        flutterController = nil
        engine?.destroyContext()
        engine = nil
        ending = false
        openButton.isEnabled = true
    }

    private func closeHost() {
        guard engine == nil, !ending else {
            return
        }
        ending = true
        let callback = completion
        completion = nil
        let value: [String: Any] = [
            "requestId": parameters["requestId"] ?? "",
            "cancelled": lastPayload == nil || lastPayload?["cancelled"] as? Bool == true,
            "payload": lastPayload ?? [:],
            "host": "UIViewController",
            "secondaryEngineLaunches": secondaryLaunchCount,
            "maxConcurrentEngines": secondaryLaunchCount > 0 ? 2 : 1
        ]
        dismiss(animated: true) {
            callback?(value)
        }
    }

    deinit {
        channel?.setMethodCallHandler(nil)
        engine?.destroyContext()
        completion?(FlutterError(code: "bridge_closed", message: "Native host was released", details: nil))
    }
}

/// 平台适配层的类型工厂，集中承接 UIKit 构造及原生配置。
private extension UILabel {
    static func makeInterop(configure: (UILabel) -> Void) -> UILabel {
        let value = UILabel()
        configure(value)
        return value
    }
}

private extension UITextView {
    static func makeInterop(configure: (UITextView) -> Void) -> UITextView {
        let value = UITextView()
        configure(value)
        return value
    }
}

private extension UIButton {
    static func makeInterop(title: String, action: @escaping () -> Void) -> UIButton {
        let value = UIButton(type: .system)
        value.setTitle(title, for: .normal)
        value.titleLabel?.numberOfLines = 0
        value.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        value.titleLabel?.adjustsFontForContentSizeCategory = true
        value.contentHorizontalAlignment = .leading
        value.addAction(UIAction { _ in action() }, for: .touchUpInside)
        value.heightAnchor.constraint(greaterThanOrEqualToConstant: 48).isActive = true
        return value
    }
}

private extension UIStackView {
    static func makeInterop(views: [UIView]) -> UIStackView {
        let value = UIStackView(arrangedSubviews: views)
        value.axis = .vertical
        value.spacing = 16
        value.translatesAutoresizingMaskIntoConstraints = false
        return value
    }
}
