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

	public var rangingHandler: (([String]) -> Void)? {
		get { return locationManager.rangingHandler }
		set { locationManager.rangingHandler = newValue }
	}

	private let locationManager = LocationManager()
	private var authResponse: BlocksAuthResponse?

	public var storageQrCode: String? {
		return authResponse?.storageQrCode
	}

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
		guard let token = authResponse?.token else {
			return completion(.failure(BlocksApiError.internalError))
		}
		API.Blocks.myPackages(token: token) { result in
			completion(Swift.Result {
				return try result.get().packages
			})
		}
	}

	public func startMonitoring() {
		locationManager.startMonitoring()
	}

	public func requestState() {
		locationManager.requestState()
	}

}
