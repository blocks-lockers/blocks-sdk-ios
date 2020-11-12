//
//  BlocksAuthRequest.swift
//  BlocksSDK
//
//  Created by Alex Studnicka on 12.11.2020.
//  Copyright © 2020 Spaceflow s.r.o. All rights reserved.
//

import Foundation

final class BlocksAuthRequest: Codable {

	let userId: String
	let buildingId: String
	let apiKey: String

	init(userId: String, buildingId: String, apiKey: String) {
		self.userId = userId
		self.buildingId = buildingId
		self.apiKey = apiKey
	}

}
