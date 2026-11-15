//
//  JobsRuntimeLab.swift
//  JobsPlatformLabByPub
//
//  Created by Jobs on 2026年11月14日，星期六.
//

import Foundation
import ObjectiveC.runtime
import Flutter

final class JobsRuntimeLab {
    private var instances: [String: NSObject] = [:]
    private var originals: [String: IMP] = [:]
    private var patches: [String: IMP] = [:]

    func handle(_ method: String, args: [String: Any], result: @escaping FlutterResult) {
        do {
            let name = args["name"] as? String ?? "NSObject"
            if method == "runtime.define" {
                try define(name, title: args["title"] as? String ?? "Created by Jobs")
            } else if method == "runtime.patch" {
                try patch(name, title: args["title"] as? String ?? "Patched by Jobs")
            } else if method == "runtime.rollback" {
                try rollback(name)
            } else if method != "runtime.inspect" {
                result(FlutterMethodNotImplemented)
                return
            }
            guard let type = objc_lookUpClass(name) else {
                throw JobsLabError("Objective-C class was not found: \(name)")
            }
            var snapshot = inspect(type)
            if let instance = instances[name] {
                snapshot["value"] =
                    instance.perform(NSSelectorFromString("jobsRuntimeTitle"))?.takeUnretainedValue() as? String ?? ""
                snapshot["patched"] = patches[name] != nil
            }
            result(snapshot)
        } catch {
            result(FlutterError(code: "runtime", message: error.localizedDescription, details: nil))
        }
    }

    private func define(_ name: String, title: String) throws {
        guard name.range(of: "^JobsLabRuntime[A-Za-z0-9_]{1,80}$", options: .regularExpression) != nil else {
            throw JobsLabError("Dynamic class names must begin with JobsLabRuntime")
        }
        guard objc_lookUpClass(name) == nil, let type = objc_allocateClassPair(NSObject.self, name, 0) else {
            throw JobsLabError("Class already exists or cannot be allocated")
        }
        let getter: @convention(block) (AnyObject) -> NSString = { _ in
            title as NSString
        }
        let implementation = imp_implementationWithBlock(getter)
        guard class_addMethod(type, NSSelectorFromString("jobsRuntimeTitle"), implementation, "@@:") else {
            imp_removeBlock(implementation)
            objc_disposeClassPair(type)
            throw JobsLabError("Dynamic method registration failed")
        }
        let added = "T".withCString { typeName in
            "@\"NSString\"".withCString { encoding in
                "R".withCString { readOnly in
                    "".withCString { empty in
                        var attributes = [
                            objc_property_attribute_t(name: typeName, value: encoding),
                            objc_property_attribute_t(name: readOnly, value: empty)
                        ]
                        return class_addProperty(type, "jobsRuntimeTitle", &attributes, 2)
                    }
                }
            }
        }
        guard added else {
            imp_removeBlock(implementation)
            objc_disposeClassPair(type)
            throw JobsLabError("Dynamic property registration failed")
        }
        objc_registerClassPair(type)
        instances[name] = (type as! NSObject.Type).init()
    }

    private func ownedMethod(_ name: String) throws -> Method {
        guard name.hasPrefix("JobsLabRuntime"), instances[name] != nil,
            let type = objc_lookUpClass(name),
            let method = class_getInstanceMethod(type, NSSelectorFromString("jobsRuntimeTitle"))
        else {
            throw JobsLabError("Only classes created by this lab can be patched")
        }
        return method
    }

    private func patch(_ name: String, title: String) throws {
        let method = try ownedMethod(name)
        let getter: @convention(block) (AnyObject) -> NSString = { _ in
            title as NSString
        }
        let implementation = imp_implementationWithBlock(getter)
        let previous = method_setImplementation(method, implementation)
        if let oldPatch = patches[name] {
            imp_removeBlock(oldPatch)
        } else {
            originals[name] = previous
        }
        patches[name] = implementation
    }

    private func rollback(_ name: String) throws {
        let method = try ownedMethod(name)
        guard let original = originals.removeValue(forKey: name) else {
            return
        }
        method_setImplementation(method, original)
        if let patch = patches.removeValue(forKey: name) {
            imp_removeBlock(patch)
        }
    }

    deinit {
        for name in Array(patches.keys) {
            try? rollback(name)
        }
    }

    private func inspect(_ type: AnyClass) -> [String: Any] {
        var count: UInt32 = 0
        let methods = class_copyMethodList(type, &count)
        let methodRows: [[String: String]] = (0..<Int(count)).map { index in
            let method = methods![index]
            return [
                "name": NSStringFromSelector(method_getName(method)),
                "encoding": method_getTypeEncoding(method).map {
                    String(cString: $0)
                } ?? ""
            ]
        }
        free(methods)
        let properties = class_copyPropertyList(type, &count)
        let propertyRows: [[String: String]] = (0..<Int(count)).map { index in
            let property = properties![index]
            return [
                "name": String(cString: property_getName(property)),
                "attributes": property_getAttributes(property).map {
                    String(cString: $0)
                } ?? ""
            ]
        }
        free(properties)
        return [
            "name": NSStringFromClass(type),
            "superclass": class_getSuperclass(type).map(NSStringFromClass) ?? "",
            "instanceSize": class_getInstanceSize(type),
            "methods": methodRows.sorted {
                $0["name"]! < $1["name"]!
            },
            "properties": propertyRows.sorted {
                $0["name"]! < $1["name"]!
            },
            "runtime": "Objective-C"
        ]
    }
}
