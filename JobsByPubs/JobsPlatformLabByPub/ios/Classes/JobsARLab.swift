//
//  JobsARLab.swift
//  JobsPlatformLabByPub
//
//  Created by Jobs on 2026年11月14日，星期六.
//

import ARKit
import SceneKit
import Flutter

final class JobsARViewFactory: NSObject, FlutterPlatformViewFactory {
    private weak var owner: JobsPlatformLabPlugin?
    init(owner: JobsPlatformLabPlugin) {
        self.owner = owner
    }
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        FlutterStandardMessageCodec.sharedInstance()
    }
    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        let value = JobsARPlatformView(frame: frame, id: viewId, owner: owner)
        owner?.registerAR(value, id: viewId)
        return value
    }
}

final class JobsARPlatformView: NSObject, FlutterPlatformView, ARSCNViewDelegate {
    static var isSupported: Bool {
        ARWorldTrackingConfiguration.isSupported
    }
    private weak var owner: JobsPlatformLabPlugin?
    private let identifier: Int64
    private let sceneView: ARSCNView
    private var models: [SCNNode] = []
    private var modelAnchors: [ARAnchor] = []
    private var preview = true
    private var selected = "cube"
    private var planeCount = 0

    init(frame: CGRect, id: Int64, owner: JobsPlatformLabPlugin?) {
        identifier = id
        self.owner = owner
        sceneView = ARSCNView(frame: frame)
        super.init()
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
        sceneView.allowsCameraControl = true
        sceneView.scene = SCNScene()
        sceneView.backgroundColor = .secondarySystemBackground
        let camera = SCNNode()
        camera.camera = SCNCamera()
        camera.position = SCNVector3(0, 0.1, 0.6)
        sceneView.scene.rootNode.addChildNode(camera)
        sceneView.pointOfView = camera
    }

    func view() -> UIView {
        sceneView
    }

    func command(_ args: [String: Any]) throws {
        switch args["action"] as? String ?? "" {
        /// 执行 start 原生操作。
        case "start":
            guard Self.isSupported else {
                throw JobsLabError("AR world tracking requires supported physical iOS hardware")
            }
            preview = false
            sceneView.allowsCameraControl = false
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = [.horizontal, .vertical]
            sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
            publish("started")
        /// 执行 preview 原生操作。
        case "preview":
            preview = true
            sceneView.session.pause()
            sceneView.allowsCameraControl = true
            publish("preview")
        /// 执行 select 原生操作。
        case "select":
            selected = args["model"] as? String ?? "cube"
            publish("selected")
        /// 执行 place 原生操作。
        case "place":
            let node = makeModel(selected)
            if preview {
                node.position = SCNVector3(Float(models.count % 3 - 1) * 0.1, 0, 0)
                sceneView.scene.rootNode.addChildNode(node)
            } else {
                let center = CGPoint(x: sceneView.bounds.midX, y: sceneView.bounds.midY)
                guard let query = sceneView.raycastQuery(from: center, allowing: .estimatedPlane, alignment: .any),
                    let hit = sceneView.session.raycast(query).first
                else {
                    throw JobsLabError("No surface found. Move the camera slowly and retry")
                }
                let anchor = ARAnchor(transform: hit.worldTransform)
                sceneView.session.add(anchor: anchor)
                modelAnchors.append(anchor)
                node.simdTransform = hit.worldTransform
                sceneView.scene.rootNode.addChildNode(node)
            }
            models.append(node)
            publish("placed")
        /// 执行 smaller 原生操作。
        case "smaller":
            if let node = models.last {
                node.simdScale *= SIMD3<Float>(repeating: 0.8)
            }
        /// 执行 larger 原生操作。
        case "larger":
            if let node = models.last {
                node.simdScale *= SIMD3<Float>(repeating: 1.25)
            }
        /// 执行 rotate 原生操作。
        case "rotate":
            models.last?.eulerAngles.y += Float.pi / 8
        /// 执行 clear 原生操作。
        case "clear":
            models.forEach {
                $0.removeFromParentNode()
            }
            models.removeAll()
            for anchor in modelAnchors {
                sceneView.session.remove(anchor: anchor)
            }
            modelAnchors.removeAll()
            publish("cleared")
        /// 执行 pause 原生操作。
        case "pause":
            sceneView.session.pause()
        /// 未匹配的操作返回未实现。
        default:
            throw JobsLabError("Unknown AR action")
        }
    }

    private func makeModel(_ name: String) -> SCNNode {
        let geometry: SCNGeometry
        if name == "sphere" {
            geometry = SCNSphere(radius: 0.04)
        } else if name == "robot" {
            let robot = SCNNode()
            let parts: [(SCNGeometry, SCNVector3)] = [
                (SCNBox(width: 0.055, height: 0.065, length: 0.035, chamferRadius: 0.005), SCNVector3(0, 0, 0)),
                (SCNSphere(radius: 0.025), SCNVector3(0, 0.065, 0)),
                (SCNCapsule(capRadius: 0.008, height: 0.06), SCNVector3(-0.045, 0, 0)),
                (SCNCapsule(capRadius: 0.008, height: 0.06), SCNVector3(0.045, 0, 0)),
                (SCNCapsule(capRadius: 0.01, height: 0.04), SCNVector3(-0.016, -0.05, 0)),
                (SCNCapsule(capRadius: 0.01, height: 0.04), SCNVector3(0.016, -0.05, 0))
            ]
            for (shape, position) in parts {
                shape.firstMaterial?.diffuse.contents = UIColor.systemTeal
                let part = SCNNode(geometry: shape)
                part.position = position
                robot.addChildNode(part)
            }
            return robot
        } else {
            geometry = SCNBox(width: 0.08, height: 0.08, length: 0.08, chamferRadius: 0.005)
        }
        geometry.firstMaterial?.diffuse.contents = UIColor.systemTeal
        return SCNNode(geometry: geometry)
    }

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else {
            return
        }
        DispatchQueue.main.async { [weak self] in
            self?.planeCount += 1
            self?.publish("plane")
        }
    }

    func session(_ session: ARSession, didFailWithError error: Error) {
        owner?.publish("ar", ["viewId": identifier, "error": error.localizedDescription])
    }

    private func publish(_ event: String) {
        owner?.publish(
            "ar",
            ["viewId": identifier, "event": event, "planes": planeCount, "models": models.count, "preview": preview])
    }

    deinit {
        sceneView.session.pause()
        owner?.removeAR(id: identifier)
    }
}
