//
//  API.swift
//  BlocksSDK
//
//  Created by Alex Studnicka on 12.11.2020.
//  Copyright © 2020 Spaceflow s.r.o. All rights reserved.
//

import Foundation

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

//	static let jwtExpirationValidator: DataRequest.Validation = { request, response, data in
//		if response.statusCode == 401 {
//			return .failure(APIError.jwtExpired)
//		}
//		return .success
//	}

	static func createRequest(_ url: String) throws -> URLRequest {
		guard let url = URL(string: baseUrl + url) else {
			throw BlocksApiError.internalError
		}
		return URLRequest(url: url)
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
				let responseObj = try API.process(data: data, response: response, error: error)
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

//	static func makeRequest(request: DataRequest, completion: ((Swift.Result<Void, Error>) -> Void)? = nil) {
//		request.validate(jwtExpirationValidator)
//		request.response { response in
//			if response.isSuccessful {
//				completion?(.success(()))
//			} else if let data = response.data, let json = API.decode(ErrorResponse.self, from: data, logError: false), let error = json.errorCode {
//				completion?(.failure(error))
//			} else {
//				Crashlytics.reportServerError(response: response)
//				if response.error != nil {
//					completion?(.failure(APIError.networkError))
//				} else {
//					completion?(.failure(APIError.serverError))
//				}
//			}
//		}
//	}

	static func process<T>(data: Data?, response: URLResponse?, error: Error?, decoder: JSONDecoder = jsonDecoder) throws -> T where T: Decodable {
		if let data = data, let json = try? decoder.decode(T.self, from: data) {
			return json
//		} else if let data = response.data, let json = API.decode(ErrorResponse.self, from: data, logError: false), let error = json.errorCode {
//			print("ERROR:", error)
//			throw error
		} else {
			try throwError(response: response, error: error)
		}
	}

	static func throwError(response: URLResponse?, error: Error?) throws -> Never {
		print("ERROR:", response as Any, error as Any)
		if error != nil {
			throw BlocksApiError.networkError
		} else {
			throw BlocksApiError.serverError
		}
	}

}
