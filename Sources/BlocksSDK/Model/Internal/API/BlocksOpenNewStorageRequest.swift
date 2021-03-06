//
//  BlocksOpenNewStorageRequest.swift
//  BlocksSDK
//
//  Created by Alex Studnicka on 12.11.2020.
//  Copyright © 2021 Property Blocks s.r.o. All rights reserved.
//

import Foundation

final class BlocksOpenNewStorageRequest: Codable {

	let blocksSerial: String

	init(blocksSerial: String) {
		self.blocksSerial = blocksSerial
	}

}
