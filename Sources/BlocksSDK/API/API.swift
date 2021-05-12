//
//  API.swift
//  BlocksSDK
//
//  Created by Alex Studnicka on 12.11.2020.
//  Copyright © 2021 Property Blocks s.r.o. All rights reserved.
//

import Foundation
import Alamofire

final class API {

	static let baseUrl = "https://api.blockslockers.com"

	static let session: URLSession = {
		let configuration = URLSessionConfiguration.default
		let session = URLSession(configuration: configuration)
		return session
	}()

	static let jsonDecoder: JSONDecoder = {
		let decoder = JSONDecoder()
		decoder.keyDecodingStrategy = .convertFromSnakeCase
		decoder.dateDecodingStrategy = .iso8601
		return decoder
	}()

	static let jsonEncoder: JSONEncoder = {
		let encoder = JSONEncoder()
		encoder.keyEncodingStrategy = .convertToSnakeCase
		encoder.dateEncodingStrategy = .iso8601
		return encoder
	}()

	static func createRequest(_ url: String) throws -> URLRequest {
		guard let url = URL(string: baseUrl + url) else {
			throw BlocksError.internalError
		}
		var urlRequest = URLRequest(url: url)
		if let token = BlocksSDK.shared.authResponse?.token {
			urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
		}
		return urlRequest
	}

	static func createRequest<T>(_ url: String, method: String = "POST", request: T) throws -> URLRequest where T: Encodable {
		var urlRequest = try createRequest(url)
		urlRequest.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
		urlRequest.httpMethod = "POST"
		urlRequest.httpBody = try API.jsonEncoder.encode(request)
		return urlRequest
	}

	static func makeRequest<U>(request: URLRequest, completion: ((Swift.Result<U, Error>) -> Void)? = nil) where U: Decodable {
		session.dataTask(with: request, completionHandler: { data, response, error in
			do {
				let responseObj: U = try API.process(data: data, response: response, error: error)
				DispatchQueue.main.async {
					completion?(.success(responseObj))
				}
			} catch {
				DispatchQueue.main.async {
					completion?(.failure(error))
				}
			}
		}).resume()
	}

	static func makeRequest(request: URLRequest, completion: ((Swift.Result<Void, Error>) -> Void)? = nil) {
		session.dataTask(with: request, completionHandler: { data, response, error in
			if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
				DispatchQueue.main.async {
					completion?(.success(()))
				}
			} else {
				DispatchQueue.main.async {
					completion?(.failure(BlocksError.serverError))
				}
			}
		}).resume()
	}

	static func process<T>(data: Data?, response: URLResponse?, error: Error?, decoder: JSONDecoder = jsonDecoder) throws -> T where T: Decodable {
		if let data = data, let json = try? decoder.decode(T.self, from: data) {
			return json
		} else {
			try throwError(response: response, error: error)
		}
	}

	static func throwError(response: URLResponse?, error: Error?) throws -> Never {
		if error != nil {
			throw BlocksError.networkError
		} else {
			throw BlocksError.serverError
		}
	}

}
