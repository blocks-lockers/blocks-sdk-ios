//
//  APIBlocks.swift
//  BlocksSDK
//
//  Created by Alex Studnicka on 12.11.2020.
//  Copyright © 2020 Spaceflow s.r.o. All rights reserved.
//

import Foundation

extension API {

	struct Blocks {

		static func auth(request: BlocksAuthRequest, completion: @escaping (Swift.Result<BlocksAuthResponse, Error>) -> Void) {
			guard let urlRequest = try? API.createRequest("/user/auth", method: "POST", request: request) else {
				return completion(.failure(BlocksApiError.internalError))
			}
			API.makeRequest(request: urlRequest, completion: completion)
		}

		static func myPackages(completion: @escaping (Swift.Result<BlocksPackagesResponse, Error>) -> Void) {
			guard var urlRequest = try? API.createRequest("/user/packages") else {
				return completion(.failure(BlocksApiError.internalError))
			}
			if let token = BlocksSDK.shared.authResponse?.token {
				urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
			}
			API.makeRequest(request: urlRequest, completion: completion)
		}

		static func openBox(packageId: String, completion: @escaping (Swift.Result<Void, Error>) -> Void) {
			guard var urlRequest = try? API.createRequest("/packages/\(packageId)/open-box") else {
				return completion(.failure(BlocksApiError.internalError))
			}
			if let token = BlocksSDK.shared.authResponse?.token {
				urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
			}
			urlRequest.httpMethod = "POST"
			API.makeRequest(request: urlRequest, completion: completion)
		}

	}

}
