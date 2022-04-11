//
//  BlocksBluetoothManager.swift
//  BlocksSDK
//
//  Created by Alex Studnicka on 02.04.2021.
//  Copyright © 2021 Property Blocks s.r.o. All rights reserved.
//

import Foundation
import CoreBluetooth

public final class BlocksBluetoothManager: NSObject {

	public typealias PickupHandler = ((PickupState) -> Void)

	public enum BluetoothError: Error {
		/// Another operation is already in progress
		case operationInProgress
		/// BLE is not ready (no authorization or not powered on)
		case bleNotReady
		/// Blocks not found nearby
		case blocksNotFound
		/// Blocks found, but connection failed
		case connectionError
		/// Package not found in Blocks
		case packageNotFound
		/// Box did not open
		case boxNotOpened
		/// Internal error
		case internalError
	}

	public enum PickupState {
		case connected
		case finished
        case opened
		case error(BluetoothError)
	}
    
    public enum Command {
        case pickup(packageId: String, unlockCode: String)
        case phoneStorage(phone: String, boxType: String)
        case addressbookStorage(personId: String, boxType: String)
        case reservationStorage(personId: String, boxType: String)
        case changeBoxSize
    }

	public static let shared = BlocksBluetoothManager()

	public var enableDebugLog = false

	private var centralManager: CBCentralManager!
	private var peripheral: CBPeripheral!

	private let serviceUuid = CBUUID(string: "aa2fbfff-4f1c-4855-a626-5f4b7bba09a2")
	private let statusCharacteristicUuid = CBUUID(string: "aa2fbfff-4f1c-4855-a626-5f4b7bba09a3")
	private let commandCharacteristicUuid = CBUUID(string: "aa2fbfff-4f1c-4855-a626-5f4b7bba09a4")

    private var command: Command?

	private var statusCharacteristic: CBCharacteristic?
	private var commandCharacteristic: CBCharacteristic?
	private var timeoutTimer: Timer?

	private var previousPickupState: BlocksStateEnum = .ready
	private var pickupHandler: PickupHandler?

	private let jsonDecoder = JSONDecoder()

	private override init() {
		super.init()
		centralManager = CBCentralManager(delegate: self, queue: nil)
	}

	internal func setup() { }

	public func disconnect() {
		if let peripheral = peripheral {
			centralManager.cancelPeripheralConnection(peripheral)
		}
	}

}

// MARK: - Scanning

extension BlocksBluetoothManager {

	public func pickupPackage(packageId: String, unlockCode: String, handler: @escaping PickupHandler) {
        sendCommand(.pickup(packageId: packageId, unlockCode: unlockCode), handler: handler)
	}
    
    public func phoneStorage(phone: String, boxType: String, handler: @escaping PickupHandler) {
        sendCommand(.phoneStorage(phone: phone, boxType: boxType), handler: handler)
    }
    
    
    public func changeBoxSize(handler: @escaping PickupHandler) {
        sendCommand(.changeBoxSize, handler: handler)
    }
}

// MARK: - CBCentralManagerDelegate

extension BlocksBluetoothManager: CBCentralManagerDelegate {

	public func centralManagerDidUpdateState(_ central: CBCentralManager) {

	}

	public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
		log("Discovered")
		peripheral.delegate = self
		self.peripheral = peripheral
		central.stopScan()
		central.connect(peripheral)
	}

	public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
		log("Connected")
		self.pickupHandler?(.connected)
		peripheral.discoverServices([serviceUuid])
	}

	public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
		log("Disconnected")
		self.timeoutTimer?.invalidate()
		self.timeoutTimer = nil
		self.peripheral = nil
		self.statusCharacteristic = nil
		self.commandCharacteristic = nil
        self.command = nil
	}

}

// MARK: - CBPeripheralDelegate

extension BlocksBluetoothManager: CBPeripheralDelegate {

	public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
		guard let services = peripheral.services else { return }

		for service in services {
			peripheral.discoverCharacteristics(nil, for: service)
		}
	}

	public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
		guard let characteristics = service.characteristics else { return }

		for characteristic in characteristics {
			switch characteristic.uuid {
			case statusCharacteristicUuid:
				self.statusCharacteristic = characteristic
				peripheral.readValue(for: characteristic)
			case commandCharacteristicUuid:
				self.commandCharacteristic = characteristic
			default:
				break
			}
		}
	}

	public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
		guard
			characteristic.uuid == statusCharacteristicUuid,
			let data = characteristic.value,
			let state = try? jsonDecoder.decode(BlocksState.self, from: data)
		else {
			self.pickupHandler?(.error(.internalError))
			return
		}

		log("Blocks state: \(state)")
		switch state.state {
		case .ready:
			guard let characteristic = commandCharacteristic else {
				self.pickupHandler?(.error(.internalError))
				return
			}
            
            guard let command = command else {
                return
            }
            
            switch command {
            case .pickup(let packageId, let unlockCode):
                let str = #"{"type":"pickup","packageId":"\#(packageId)","unlock_code":"\#(unlockCode)"}"#
                peripheral.writeValue(str.data(using: .utf8)!, for: characteristic, type: .withResponse)
            case .phoneStorage(let phone, let boxType):
                let str = #"{"type":"phone_storage","phone":"\#(phone)","boxType":"\#(boxType)"}"#
                peripheral.writeValue(str.data(using: .utf8)!, for: characteristic, type: .withResponse)
            case .addressbookStorage(let personId, let boxType):
                let str = #"{"type":"addressbook_storage","personId":"\#(personId)","boxType":"\#(boxType)"}"#
                peripheral.writeValue(str.data(using: .utf8)!, for: characteristic, type: .withResponse)
            case .reservationStorage(let personId, let boxType):
                let str = #"{"type":"reservation_storage","personId":"\#(personId)","boxType":"\#(boxType)"}"#
                peripheral.writeValue(str.data(using: .utf8)!, for: characteristic, type: .withResponse)
            case .changeBoxSize:
                let str = #"{"type":"change_box_size"}"#
                peripheral.writeValue(str.data(using: .utf8)!, for: characteristic, type: .withResponse)
            }
		case .unknown, .opening:
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
				peripheral.readValue(for: characteristic)
			}
            
        case .opened:
            self.pickupHandler?(.opened)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                peripheral.readValue(for: characteristic)
            }
            
		case .finished:
			self.pickupHandler?(.finished)
			self.disconnect()

		case .error:
			switch state.error {
			case "PACKAGE_NOT_FOUND":
				self.pickupHandler?(.error(.packageNotFound))
			case "BOX_NOT_OPENED":
				self.pickupHandler?(.error(.boxNotOpened))
			default:
				self.pickupHandler?(.error(.internalError))
			}
			self.disconnect()
		}
	}

	public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
		log("Did write value / error: \(String(describing: error))")
		guard let characteristic = statusCharacteristic else {
			self.pickupHandler?(.error(.internalError))
			return
		}
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
			peripheral.readValue(for: characteristic)
		}
	}

}


// MARK: - Logging

extension BlocksBluetoothManager {

	private func log(_ log: String) {
		guard enableDebugLog else { return }
		print("[BlocksSDK]", log)
	}

}


// MARK: - Private methods

private extension BlocksBluetoothManager {
    
    func sendCommand(_ command: Command, handler: @escaping PickupHandler) {
        guard self.command == nil else {
            handler(.error(.operationInProgress))
            return
        }

        guard centralManager.state == .poweredOn else {
            handler(.error(.bleNotReady))
            return
        }

        self.pickupHandler = handler
        self.command = command

        centralManager.scanForPeripherals(withServices: [serviceUuid])

        timeoutTimer?.invalidate()
        timeoutTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { _ in
            if self.peripheral == nil {
                self.log("Scan timeout")
                self.centralManager.stopScan()
                self.pickupHandler?(.error(.blocksNotFound))
                self.command = nil
            } else if self.statusCharacteristic == nil {
                self.log("Connection timeout")
                self.pickupHandler?(.error(.connectionError))
                self.disconnect()
            }
        }
    }
}
