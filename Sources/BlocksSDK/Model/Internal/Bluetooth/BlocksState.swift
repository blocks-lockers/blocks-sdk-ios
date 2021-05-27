//
//  BlocksPackagesResponse.swift
//  BlocksSDK
//
//  Created by Alex Studnicka on 12.05.2021.
//  Copyright © 2021 Property Blocks s.r.o. All rights reserved.
//

import Foundation

enum BlocksStateEnum: String, Codable {
	case unknown
	case ready
	case waitingForClose = "waiting_for_close"
	case finished
	case error
}

struct BlocksState: Codable {
	var version: Int
	var serialNo: String
	var state: BlocksStateEnum
	var error: String?
	var packageId: String?
}
