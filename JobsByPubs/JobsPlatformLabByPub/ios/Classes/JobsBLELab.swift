//
//  JobsBLELab.swift
//  JobsPlatformLabByPub
//
//  Created by Jobs on 2026年11月14日，星期六.
//

import CoreBluetooth
import Flutter

final class JobsBLELab: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private let publish: (String, [String: Any]) -> Void
    private var manager: CBCentralManager?
    private var devices: [UUID: CBPeripheral] = [:]
    private var signal: [UUID: Int] = [:]
    private var connectResults: [UUID: FlutterResult] = [:]
    private var timers: [UUID: Timer] = [:]
    private var pending: [String: FlutterResult] = [:]
    private var expiryTokens: [String: UUID] = [:]
    private var reconnect: Set<UUID> = []
    private var scanTimer: Timer?
    private var serviceFilter: [CBUUID]?
    private var nameFilter = ""

    init(publish: @escaping (String, [String: Any]) -> Void) {
        self.publish = publish
        super.init()
    }

    private func ensureManager() -> CBCentralManager {
        if let manager {
            return manager
        }
        let value = CBCentralManager(
            delegate: self, queue: .main,
            options: [CBCentralManagerOptionRestoreIdentifierKey: "jobs.platformlab.ble"])
        manager = value
        return value
    }

    func handle(_ method: String, args: [String: Any], result: @escaping FlutterResult) {
        let central = ensureManager()
        do {
            switch method {
            /// 执行 state 原生操作。
            case "state":
                result([
                    "state": central.state.rawValue, "authorization": CBManager.authorization.rawValue,
                    "scanning": central.isScanning
                ])
            /// 执行 scan 原生操作。
            case "scan":
                guard central.state == .poweredOn else {
                    throw JobsLabError("Bluetooth is not powered on or permission is pending")
                }
                let uuids = args["services"] as? [String] ?? []
                serviceFilter = uuids.isEmpty ? nil : uuids.map(CBUUID.init(string:))
                nameFilter = (args["name"] as? String ?? "").lowercased()
                central.scanForPeripherals(
                    withServices: serviceFilter,
                    options: [CBCentralManagerScanOptionAllowDuplicatesKey: args["duplicates"] as? Bool ?? false])
                scanTimer?.invalidate()
                scanTimer = Timer.scheduledTimer(
                    withTimeInterval: min(max(args["seconds"] as? Double ?? 10, 1), 120), repeats: false
                ) { [weak self] _ in
                    self?.manager?.stopScan()
                    self?.publish("ble", ["event": "scanStopped"])
                }
                result(true)
            /// 执行 stopScan 原生操作。
            case "stopScan":
                central.stopScan()
                scanTimer?.invalidate()
                result(true)
            /// 执行 devices 原生操作。
            case "devices":
                result(devices.values.map(deviceInfo))
            /// 执行 connect 原生操作。
            case "connect":
                let peripheral = try device(args)
                guard connectResults[peripheral.identifier] == nil else {
                    throw JobsLabError("Connection already pending")
                }
                peripheral.delegate = self
                if args["autoReconnect"] as? Bool == true {
                    reconnect.insert(peripheral.identifier)
                } else {
                    reconnect.remove(peripheral.identifier)
                }
                if peripheral.state == .connected {
                    result(deviceInfo(peripheral))
                    return
                }
                connectResults[peripheral.identifier] = result
                central.connect(peripheral)
                timers[peripheral.identifier]?.invalidate()
                timers[peripheral.identifier] = Timer.scheduledTimer(withTimeInterval: 12, repeats: false) {
                    [weak self, weak peripheral] _ in
                    guard let self, let peripheral else {
                        return
                    }
                    self.manager?.cancelPeripheralConnection(peripheral)
                    self.finishConnect(peripheral, error: JobsLabError("Connection timed out"))
                }
            /// 执行 disconnect 原生操作。
            case "disconnect":
                let peripheral = try device(args)
                reconnect.remove(peripheral.identifier)
                central.cancelPeripheralConnection(peripheral)
                result(true)
            /// 执行 discover 原生操作。
            case "discover":
                let peripheral = try connectedDevice(args)
                let key = peripheral.identifier.uuidString + "/discover"
                guard pending[key] == nil else {
                    throw JobsLabError("Discovery already pending")
                }
                pending[key] = result
                expire(key)
                peripheral.discoverServices(nil)
            /// 执行 read, write, notify, descriptorRead, rssi 原生操作。
            case "read", "write", "notify", "descriptorRead", "rssi":
                let peripheral = try connectedDevice(args)
                if method == "rssi" {
                    peripheral.readRSSI()
                    result(true)
                    return
                }
                let characteristic = try characteristic(args, peripheral: peripheral)
                let key = path(peripheral, characteristic)
                if method == "notify" {
                    peripheral.setNotifyValue(args["enabled"] as? Bool ?? true, for: characteristic)
                    result(true)
                } else if method == "descriptorRead" {
                    peripheral.discoverDescriptors(for: characteristic)
                    result(true)
                } else if method == "read" {
                    guard pending[key] == nil else {
                        throw JobsLabError("Operation pending for characteristic")
                    }
                    pending[key] = result
                    peripheral.readValue(for: characteristic)
                    expire(key)
                } else {
                    let bytes = (args["bytes"] as? [UInt8]) ?? []
                    let response = args["response"] as? Bool ?? true
                    let type: CBCharacteristicWriteType = response ? .withResponse : .withoutResponse
                    let maxSize = peripheral.maximumWriteValueLength(for: type)
                    guard !bytes.isEmpty && bytes.count <= maxSize else {
                        throw JobsLabError("Write size must be 1...\(maxSize); split with the Dart command queue")
                    }
                    if response {
                        guard pending[key] == nil else {
                            throw JobsLabError("Operation pending for characteristic")
                        }
                        pending[key] = result
                        expire(key)
                    }
                    peripheral.writeValue(Data(bytes), for: characteristic, type: type)
                    if !response {
                        result(["written": bytes.count, "mtu": maxSize])
                    }
                }
            /// 执行 requestMtu 原生操作。
            case "requestMtu":
                let peripheral = try connectedDevice(args)
                result([
                    "withResponse": peripheral.maximumWriteValueLength(for: .withResponse),
                    "withoutResponse": peripheral.maximumWriteValueLength(for: .withoutResponse), "automatic": true
                ])
            /// 执行 mtu 原生操作。
            case "mtu":
                let peripheral = try connectedDevice(args)
                result([
                    "withResponse": peripheral.maximumWriteValueLength(for: .withResponse),
                    "withoutResponse": peripheral.maximumWriteValueLength(for: .withoutResponse)
                ])
            /// 未匹配的操作返回未实现。
            default:
                result(FlutterMethodNotImplemented)
            }
        } catch {
            result(FlutterError(code: "ble", message: error.localizedDescription, details: nil))
        }
    }

    private func device(_ args: [String: Any]) throws -> CBPeripheral {
        guard let raw = args["id"] as? String, let id = UUID(uuidString: raw) else {
            throw JobsLabError("Invalid peripheral ID")
        }
        if let value = devices[id] {
            return value
        }
        if let value = manager?.retrievePeripherals(withIdentifiers: [id]).first {
            devices[id] = value
            return value
        }
        throw JobsLabError("Peripheral not discovered")
    }

    private func connectedDevice(_ args: [String: Any]) throws -> CBPeripheral {
        let peripheral = try device(args)
        guard peripheral.state == .connected else {
            throw JobsLabError("Peripheral is disconnected")
        }
        return peripheral
    }

    private func characteristic(_ args: [String: Any], peripheral: CBPeripheral) throws -> CBCharacteristic {
        let service = args["service"] as? String ?? ""
        let uuid = args["characteristic"] as? String ?? ""
        guard
            let value = peripheral.services?.first(where: {
                $0.uuid.uuidString == service
            })?
            .characteristics?.first(where: {
                $0.uuid.uuidString == uuid
            })
        else {
            throw JobsLabError("Characteristic not discovered")
        }
        return value
    }

    private func path(_ peripheral: CBPeripheral, _ characteristic: CBCharacteristic) -> String {
        peripheral.identifier.uuidString + "/" + (characteristic.service?.uuid.uuidString ?? "") + "/"
            + characteristic.uuid.uuidString
    }

    private func expire(_ key: String) {
        let token = UUID()
        expiryTokens[key] = token
        DispatchQueue.main.asyncAfter(deadline: .now() + 8) { [weak self] in
            guard let self, self.expiryTokens[key] == token else {
                return
            }
            self.expiryTokens.removeValue(forKey: key)
            if let callback = self.pending.removeValue(forKey: key) {
                callback(FlutterError(code: "timeout", message: "BLE operation timed out", details: nil))
            }
        }
    }

    private func deviceInfo(_ peripheral: CBPeripheral) -> [String: Any] {
        [
            "id": peripheral.identifier.uuidString, "name": peripheral.name ?? "",
            "rssi": signal[peripheral.identifier] ?? 0,
            "state": peripheral.state.rawValue
        ]
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        publish(
            "ble",
            ["event": "state", "state": central.state.rawValue, "authorization": CBManager.authorization.rawValue])
    }

    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String: Any]) {
        for peripheral in dict[CBCentralManagerRestoredStatePeripheralsKey] as? [CBPeripheral] ?? [] {
            devices[peripheral.identifier] = peripheral
            peripheral.delegate = self
        }
        publish("ble", ["event": "restored", "count": devices.count])
    }

    func centralManager(
        _ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
        let name = peripheral.name ?? advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? ""
        guard nameFilter.isEmpty || name.lowercased().contains(nameFilter) else {
            return
        }
        devices[peripheral.identifier] = peripheral
        signal[peripheral.identifier] = RSSI.intValue
        publish("ble", ["event": "discovered", "device": deviceInfo(peripheral)])
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        finishConnect(peripheral, error: nil)
        publish("ble", ["event": "connected", "device": deviceInfo(peripheral)])
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        finishConnect(peripheral, error: error ?? JobsLabError("Connection failed"))
    }

    private func finishConnect(_ peripheral: CBPeripheral, error: Error?) {
        timers.removeValue(forKey: peripheral.identifier)?.invalidate()
        if let callback = connectResults.removeValue(forKey: peripheral.identifier) {
            if let error {
                callback(FlutterError(code: "connect", message: error.localizedDescription, details: nil))
            } else {
                callback(deviceInfo(peripheral))
            }
        }
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        publish(
            "ble",
            [
                "event": "disconnected", "id": peripheral.identifier.uuidString,
                "error": error?.localizedDescription ?? ""
            ])
        for key in pending.keys.filter({
            $0.hasPrefix(peripheral.identifier.uuidString + "/")
        }) {
            pending.removeValue(forKey: key)?(
                FlutterError(code: "disconnected", message: "Peripheral disconnected", details: nil))
        }
        if reconnect.contains(peripheral.identifier), central.state == .poweredOn {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                central.connect(peripheral)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error {
            pending.removeValue(forKey: peripheral.identifier.uuidString + "/discover")?(
                FlutterError(code: "discover", message: error.localizedDescription, details: nil))
            return
        }
        guard let services = peripheral.services, !services.isEmpty else {
            pending.removeValue(forKey: peripheral.identifier.uuidString + "/discover")?([])
            return
        }
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error {
            pending.removeValue(forKey: peripheral.identifier.uuidString + "/discover")?(
                FlutterError(code: "discover", message: error.localizedDescription, details: nil))
            return
        }
        guard let services = peripheral.services,
            services.allSatisfy({
                $0.characteristics != nil
            })
        else {
            return
        }
        let values = services.map { service in
            [
                "uuid": service.uuid.uuidString,
                "characteristics": (service.characteristics ?? []).map { value in
                    [
                        "uuid": value.uuid.uuidString, "properties": value.properties.rawValue,
                        "read": value.properties.contains(.read), "write": value.properties.contains(.write),
                        "writeWithoutResponse": value.properties.contains(.writeWithoutResponse),
                        "notify": value.properties.contains(.notify)
                    ] as [String: Any]
                }
            ] as [String: Any]
        }
        pending.removeValue(forKey: peripheral.identifier.uuidString + "/discover")?(values)
        publish("ble", ["event": "services", "id": peripheral.identifier.uuidString, "services": values])
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        let value: [String: Any] = [
            "event": "value", "id": peripheral.identifier.uuidString,
            "service": characteristic.service?.uuid.uuidString ?? "", "characteristic": characteristic.uuid.uuidString,
            "bytes": Array(characteristic.value ?? Data()), "error": error?.localizedDescription ?? ""
        ]
        if let callback = pending.removeValue(forKey: path(peripheral, characteristic)) {
            if let error {
                callback(FlutterError(code: "read", message: error.localizedDescription, details: nil))
            } else {
                callback(value)
            }
        }
        publish("ble", value)
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        let callback = pending.removeValue(forKey: path(peripheral, characteristic))
        if let error {
            callback?(FlutterError(code: "write", message: error.localizedDescription, details: nil))
        } else {
            callback?(["written": true])
        }
    }

    func peripheral(
        _ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?
    ) {
        publish(
            "ble",
            [
                "event": "notify", "id": peripheral.identifier.uuidString,
                "characteristic": characteristic.uuid.uuidString,
                "enabled": characteristic.isNotifying, "error": error?.localizedDescription ?? ""
            ])
    }

    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        signal[peripheral.identifier] = RSSI.intValue
        publish("ble", ["event": "rssi", "device": deviceInfo(peripheral)])
    }

    func peripheral(
        _ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?
    ) {
        for descriptor in characteristic.descriptors ?? [] {
            peripheral.readValue(for: descriptor)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        publish(
            "ble",
            [
                "event": "descriptor", "uuid": descriptor.uuid.uuidString,
                "value": String(describing: descriptor.value), "error": error?.localizedDescription ?? ""
            ])
    }
}
