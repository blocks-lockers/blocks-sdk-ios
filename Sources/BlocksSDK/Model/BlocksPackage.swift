//
//  BlocksPackage.swift
//  BlocksSDK
//
//  Created by Alex Studnicka on 12.11.2020.
//  Copyright © 2020 Spaceflow s.r.o. All rights reserved.
//

import Foundation

public final class BlocksPackage: Codable {
	
	let id: String
	let blocks: Blocks
	let createdAt: Date
	let selfStored: Bool
	let isUsed: Bool
	let unlockCode: String
	let qrCode: String

}

// MARK: - Equatable

extension BlocksPackage: Equatable {

	public static func == (lhs: BlocksPackage, rhs: BlocksPackage) -> Bool {
		return lhs.id == rhs.id
	}

}
