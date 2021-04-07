//
//  BluetoothManager.swift
//  BlocksClient
//
//  Created by Alex Studnicka on 02.04.2021.
//  Copyright © 2021 Property Blocks s.r.o. All rights reserved.
//

import Foundation
import BlueSwift

public final class BluetoothManager: NSObject {

	public static let shared = BluetoothManager()

	private let statusCharacteristic: Characteristic
	private let commandCharacteristic: Characteristic
	private let service: Service
	private let configuration: Configuration

	private var peripheral: Peripheral<Connectable>?
	private var completion: ((Result<Void, Error>) -> Void)?

	private override init() {
		// swiftlint:disable force_try
		statusCharacteristic = try! Characteristic(uuid: "aa2fbfff-4f1c-4855-a626-5f4b7bba09a3", shouldObserveNotification: true)
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

extension BluetoothManager {

	public func open(packageId: String, completion: @escaping (Result<Void, Error>) -> Void) {
		self.completion = completion

		let peripheral = Peripheral(configuration: configuration)
		self.peripheral = peripheral
		BluetoothConnection.shared.connect(peripheral) { error in
			if let error = error {
				print("connect error:", error)
				self.completion?(.failure(error))
				return
			}

			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
				guard let peripheral = self.peripheral else {
					self.completion?(.failure(NSError(domain: "io.spaceflow.blocks.client.error", code: 1)))
					return
				}
				let commandString = #"{"type":"open","package_id":"\#(packageId)"}"#
				peripheral.write(command: .utf8String(commandString), characteristic: self.commandCharacteristic) { error in
					if let error = error {
						self.completion?(.failure(error))
					} else {
						self.completion?(.success(()))
					}

					BluetoothConnection.shared.disconnect(peripheral)
					BluetoothConnection.shared.stopScanning()
				}
			}
		}
	}

}
