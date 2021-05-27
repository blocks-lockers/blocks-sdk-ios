//
//  BlocksBluetoothManager.swift
//  BlocksClient
//
//  Created by Alex Studnicka on 02.04.2021.
//  Copyright © 2021 Property Blocks s.r.o. All rights reserved.
//

import Foundation
import BlueSwift

public final class BlocksBluetoothManager: NSObject {

	public typealias PickupHandler = ((PickupState) -> Void)

	public enum BluetoothError: Error {
		case blocksMismatch
		case blocksBusy
		case connectionError
		case communicationError
		case pickupError
		case internalError
	}

	public enum PickupState {
		case connected
		case opened
		case finished
		case error(BluetoothError)
	}

	public static let shared = BlocksBluetoothManager()

	private let statusCharacteristic: Characteristic
	private let commandCharacteristic: Characteristic
	private let service: Service
	private let configuration: Configuration

	private var previousPickupState: BlocksStateEnum = .ready
	private var pickupHandler: PickupHandler?

	private var decoder = JSONDecoder()

	private var peripheral: Peripheral<Connectable>?

	private override init() {
		// swiftlint:disable force_try
		statusCharacteristic = try! Characteristic(uuid: "aa2fbfff-4f1c-4855-a626-5f4b7bba09a3")
		commandCharacteristic = try! Characteristic(uuid: "aa2fbfff-4f1c-4855-a626-5f4b7bba09a4")
		service = try! Service(uuid: "aa2fbfff-4f1c-4855-a626-5f4b7bba09a2", characteristics: [statusCharacteristic, commandCharacteristic])
		configuration = try! Configuration(services: [service], advertisement: "aa2fbfff-4f1c-4855-a626-5f4b7bba09a2")
		// swiftlint:enable force_try

		super.init()
	}

	internal func setup() {
		BluetoothConnection.shared.stopScanning()
	}

}

// MARK: - Scanning

extension BlocksBluetoothManager {

	private func readState(peripheral: Peripheral<Connectable>, completion: @escaping (Result<BlocksState, Error>) -> Void) {
		peripheral.read(self.statusCharacteristic) { data, error in
			if let data = data, let state = try? self.decoder.decode(BlocksState.self, from: data) {
				DispatchQueue.main.async {
					completion(.success(state))
				}
			} else {
				DispatchQueue.main.async {
					completion(.failure(error ?? BluetoothError.communicationError))
				}
			}
		}
	}

	private func checkReadyStateForPickup(peripheral: Peripheral<Connectable>, packageId: String, unlockCode: String, blocksSerialNo: String) {
		readState(peripheral: peripheral) { result in
			do {
				let state = try result.get()

				guard state.serialNo == blocksSerialNo else {
					throw BluetoothError.blocksMismatch
				}

				guard state.state == .ready else {
					throw BluetoothError.blocksBusy
				}

				self.pickupHandler?(.connected)
				self.previousPickupState = .ready

				self.pickupAndCheckState(peripheral: peripheral, packageId: packageId, unlockCode: unlockCode)
			} catch {
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
					self.checkReadyStateForPickup(peripheral: peripheral, packageId: packageId, unlockCode: unlockCode, blocksSerialNo: blocksSerialNo)
				}
			}
		}
	}

	private func pickupAndCheckState(peripheral: Peripheral<Connectable>, packageId: String, unlockCode: String) {
		readState(peripheral: peripheral) { result in
			do {
				let state = try result.get()

				switch state.state {
				case .finished:
					self.sendLogoutCommand(peripheral: peripheral)

				case .error:
					self.pickupHandler?(.error(BluetoothError.pickupError))
					self.disconnect(peripheral: peripheral)

				case .waitingForClose:
					if self.previousPickupState != .waitingForClose {
						self.pickupHandler?(.opened)
					}
					fallthrough

				case .ready, .unknown:
					let commandString = #"{"type":"pickup","package_id":"\#(packageId)","unlock_code":"\#(unlockCode)"}"#
					peripheral.write(command: .utf8String(commandString), characteristic: self.commandCharacteristic) { error in
						DispatchQueue.main.async {
							if error != nil {
								self.disconnect(peripheral: peripheral)
								self.pickupHandler?(.error(.connectionError))
							} else {
								self.pickupAndCheckState(peripheral: peripheral, packageId: packageId, unlockCode: unlockCode)
							}
						}
					}
				}

				self.previousPickupState = state.state
			} catch {
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
					self.pickupAndCheckState(peripheral: peripheral, packageId: packageId, unlockCode: unlockCode)
				}
			}
		}
	}

	private func sendLogoutCommand(peripheral: Peripheral<Connectable>) {
		let commandString = #"{"type":"logout"}"#
		peripheral.write(command: .utf8String(commandString), characteristic: self.commandCharacteristic) { error in
			DispatchQueue.main.async {
				self.disconnect(peripheral: peripheral)
				self.pickupHandler?(.finished)
			}
		}
	}

	private func disconnect(peripheral: Peripheral<Connectable>) {
		BluetoothConnection.shared.disconnect(peripheral)
		BluetoothConnection.shared.stopScanning()
	}

	public func pickupPackage(packageId: String, unlockCode: String, blocksSerialNo: String, handler: @escaping PickupHandler) {
		self.pickupHandler = handler

		let peripheral = Peripheral(configuration: configuration)
		self.peripheral = peripheral
		BluetoothConnection.shared.connect(peripheral) { [weak self] error in
			if error != nil {
				DispatchQueue.main.async {
					self?.pickupHandler?(.error(.connectionError))
				}
				return
			}

			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
				self?.checkReadyStateForPickup(peripheral: peripheral, packageId: packageId, unlockCode: unlockCode, blocksSerialNo: blocksSerialNo)
			}
		}
	}

	public func pickupPackage(package: BlocksPackage, handler: @escaping PickupHandler) {
		pickupPackage(packageId: package.id, unlockCode: package.unlockCode, blocksSerialNo: package.blocks.serialNo, handler: handler)
	}

}
