//
//  BlocksAuthResponse.swift
//  BlocksSDK
//
//  Created by Alex Studnicka on 12.11.2020.
//  Copyright © 2021 Property Blocks s.r.o. All rights reserved.
//

import Foundation

final class BlocksAuthResponse: Codable {

	let userId: String
	let token: String
	let storageQrCode: String

}
