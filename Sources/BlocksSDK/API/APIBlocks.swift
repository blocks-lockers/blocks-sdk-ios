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
			guard var urlRequest = try? API.createRequest("/user/auth", method: "POST", request: request) else {
				return completion(.failure(BlocksError.internalError))
			}
			urlRequest.setValue(nil, forHTTPHeaderField: "Authorization")
			makeRequest(request: urlRequest, completion: completion)
		}

		static func myPackages(completion: @escaping (Swift.Result<BlocksPackagesResponse, Error>) -> Void) {
			guard let urlRequest = try? API.createRequest("/user/packages") else {
				return completion(.failure(BlocksError.internalError))
			}
			makeRequest(request: urlRequest, completion: completion)
		}

		static func openBox(packageId: String, completion: @escaping (Swift.Result<Void, Error>) -> Void) {
			guard var urlRequest = try? API.createRequest("/packages/\(packageId)/open-box") else {
				return completion(.failure(BlocksError.internalError))
			}
			urlRequest.httpMethod = "POST"
			makeRequest(request: urlRequest, completion: completion)
		}

		static func openNewStorage(blocksSerial: String, completion: @escaping (Swift.Result<Void, Error>) -> Void) {
			let request = BlocksOpenNewStorageRequest(blocksSerial: blocksSerial)
			guard let urlRequest = try? API.createRequest("/user/open-new-storage", method: "POST", request: request) else {
				return completion(.failure(BlocksError.internalError))
			}
			makeRequest(request: urlRequest, completion: completion)
		}

	}

}
