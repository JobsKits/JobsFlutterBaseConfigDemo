//
//  JobsDocumentUnityLab.swift
//  JobsPlatformLabByPub
//
//  Created by Jobs on 2026年11月14日，星期六.
//

import PDFKit
import UIKit
import Darwin
import MachO
import Flutter

final class JobsDocumentUnityLab {
    private var document: PDFDocument?
    private var unityObject: NSObject?
    private var unityLibrary: UnsafeMutableRawPointer?
    private weak var flutterWindow: UIWindow?
    private var returnButton: UIButton?

    func handle(_ method: String, args: [String: Any], result: @escaping FlutterResult) {
        do {
            switch method {
            /// 执行 pdf.open 原生操作。
            case "pdf.open":
                guard let bytes = args["bytes"] as? FlutterStandardTypedData,
                    let value = PDFDocument(data: bytes.data),
                    !value.isEncrypted || value.unlock(withPassword: args["password"] as? String ?? "")
                else {
                    throw JobsLabError("Cannot open PDF or password is incorrect")
                }
                document = value
                result(["pages": value.pageCount, "encrypted": value.isEncrypted])
            /// 执行 pdf.page 原生操作。
            case "pdf.page":
                guard let document, let index = args["index"] as? Int, let page = document.page(at: index) else {
                    throw JobsLabError("PDF page unavailable")
                }
                let bounds = page.bounds(for: .mediaBox)
                let width = min(max(args["width"] as? Double ?? 1200, 300), 2400)
                let size = CGSize(width: width, height: width * bounds.height / max(bounds.width, 1))
                guard let png = page.thumbnail(of: size, for: .mediaBox).pngData() else {
                    throw JobsLabError("PDF rasterization failed")
                }
                result(FlutterStandardTypedData(bytes: png))
            /// 执行 pdf.close 原生操作。
            case "pdf.close":
                document = nil
                result(true)
            /// 执行 unity.status 原生操作。
            case "unity.status":
                result([
                    "bundled": Bundle.main.privateFrameworksURL.map {
                        FileManager.default.fileExists(
                            atPath: $0.appendingPathComponent("UnityFramework.framework").path)
                    } ?? false,
                    "loaded": unityObject != nil
                ])
            /// 执行 unity.open 原生操作。
            case "unity.open":
                flutterWindow = UIApplication.shared.connectedScenes.compactMap {
                    $0 as? UIWindowScene
                }.flatMap(\.windows).first(where: \.isKeyWindow)
                try loadUnity()
                let selector = NSSelectorFromString("showUnityWindow")
                guard unityObject?.responds(to: selector) == true else {
                    throw JobsLabError("Unity framework does not expose showUnityWindow")
                }
                unityObject?.perform(selector)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                    self?.addReturnControl(args["returnTitle"] as? String ?? "Flutter")
                }
                result(true)
            /// 执行 unity.close 原生操作。
            case "unity.close":
                returnButton?.removeFromSuperview()
                flutterWindow?.makeKeyAndVisible()
                result(true)
            /// 执行 unity.message 原生操作。
            case "unity.message":
                guard unityObject != nil, let symbol = dlsym(unityLibrary, "UnitySendMessage") else {
                    throw JobsLabError("Unity runtime is not loaded")
                }
                typealias SendMessage =
                    @convention(c) (UnsafePointer<CChar>, UnsafePointer<CChar>, UnsafePointer<CChar>) -> Void
                let send = unsafeBitCast(symbol, to: SendMessage.self)
                let object = args["object"] as? String ?? ""
                let method = args["method"] as? String ?? ""
                let message = args["message"] as? String ?? ""
                guard !object.isEmpty && !method.isEmpty else {
                    throw JobsLabError("Object and method are required")
                }
                object.withCString { o in
                    method.withCString { m in
                        message.withCString {
                            send(o, m, $0)
                        }
                    }
                }
                result(true)
            /// 未匹配的操作返回未实现。
            default:
                result(FlutterMethodNotImplemented)
            }
        } catch {
            result(FlutterError(code: "document_unity", message: error.localizedDescription, details: nil))
        }
    }

    private func addReturnControl(_ title: String) {
        guard
            let window = UIApplication.shared.connectedScenes.compactMap({
                $0 as? UIWindowScene
            }).flatMap(\.windows).first(where: \.isKeyWindow)
        else {
            return
        }
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 16, y: max(window.safeAreaInsets.top, 24) + 8, width: 110, height: 44)
        button.setTitle(title, for: .normal)
        button.backgroundColor = .systemBackground
        button.setTitleColor(.label, for: .normal)
        button.layer.cornerRadius = 10
        button.addAction(
            UIAction { [weak self] _ in
                self?.returnButton?.removeFromSuperview()
                self?.flutterWindow?.makeKeyAndVisible()
            }, for: .touchUpInside)
        window.addSubview(button)
        returnButton = button
    }

    private func loadUnity() throws {
        guard unityObject == nil else {
            return
        }
        guard let frameworks = Bundle.main.privateFrameworksURL,
            let bundle = Bundle(url: frameworks.appendingPathComponent("UnityFramework.framework")), bundle.load(),
            let type = bundle.principalClass as? NSObject.Type
        else {
            throw JobsLabError(
                "Embed the generated UnityFramework.framework and matching Data bundle for this architecture")
        }
        let selector = NSSelectorFromString("getInstance")
        guard type.responds(to: selector), let object = type.perform(selector)?.takeUnretainedValue() as? NSObject
        else {
            throw JobsLabError("Invalid UnityFramework public interface")
        }
        let setHeader = NSSelectorFromString("setExecuteHeader:")
        if object.responds(to: setHeader), let implementation = object.method(for: setHeader) {
            typealias SetHeader = @convention(c) (AnyObject, Selector, UnsafeRawPointer?) -> Void
            let configure = unsafeBitCast(implementation, to: SetHeader.self)
            configure(object, setHeader, _dyld_get_image_header(0).map(UnsafeRawPointer.init))
        }
        let setBundle = NSSelectorFromString("setDataBundleId:")
        if object.responds(to: setBundle) {
            object.perform(setBundle, with: bundle.bundleIdentifier)
        }
        let run = NSSelectorFromString("runEmbeddedWithArgc:argv:appLaunchOpts:")
        guard object.responds(to: run), let implementation = object.method(for: run) else {
            throw JobsLabError("Unity embedded entry point unavailable")
        }
        typealias Run =
            @convention(c) (
                AnyObject, Selector, Int32, UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?, NSDictionary?
            ) -> Void
        let function = unsafeBitCast(implementation, to: Run.self)
        function(object, run, CommandLine.argc, CommandLine.unsafeArgv, nil)
        unityObject = object
        if let path = bundle.executablePath {
            unityLibrary = dlopen(path, RTLD_NOW)
        }
    }
}
