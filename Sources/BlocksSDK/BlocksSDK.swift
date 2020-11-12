//
//  BlocksSDK.swift
//  BlocksSDK
//
//  Created by Alex Studnicka on 12.11.2020.
//  Copyright © 2020 Spaceflow s.r.o. All rights reserved.
//

import Foundation

public final class BlocksSDK: NSObject {

	public static let shared = BlocksSDK()

	private let locationManager = LocationManager()
	internal var authResponse: BlocksAuthResponse?

	public weak var delegate: BlocksSDKDelegate?

	public var storageQrCode: String? {
		return authResponse?.storageQrCode
	}

	/// Nearby Blocks serial numbers
	public internal(set) var nearbyBlocks: [String] = []

	private override init() {
		super.init()
	}

	public func authenticate(apiKey: String, userId: String, buildingId: String, completion: @escaping (Swift.Result<Void, Error>) -> Void) {
		let request = BlocksAuthRequest(userId: userId, buildingId: buildingId, apiKey: apiKey)
		API.Blocks.auth(request: request) { result in
			completion(Swift.Result {
				self.authResponse = try result.get()
			})
		}
	}

	public func listPackages(completion: @escaping (Swift.Result<[BlocksPackage], Error>) -> Void) {
		API.Blocks.myPackages { result in
			completion(Swift.Result {
				return try result.get().packages
			})
		}
	}

	public func openBox(packageId: String, completion: @escaping (Swift.Result<Void, Error>) -> Void) {
		API.Blocks.openBox(packageId: packageId, completion: completion)
	}

	public func startMonitoring() {
		locationManager.startMonitoring()
	}

	public func requestState() {
		locationManager.requestState()
	}

}
