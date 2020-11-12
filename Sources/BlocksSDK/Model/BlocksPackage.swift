//
//  BlocksPackage.swift
//  BlocksSDK
//
//  Created by Alex Studnicka on 12.11.2020.
//  Copyright © 2020 Spaceflow s.r.o. All rights reserved.
//

import Foundation

public final class BlocksPackage: Codable {
	
	public let id: String
	public let blocks: Blocks
	public let createdAt: Date
	public let selfStored: Bool
	public let isUsed: Bool
	public let unlockCode: String
	public let qrCode: String

}

// MARK: - Equatable

extension BlocksPackage: Equatable {

	public static func == (lhs: BlocksPackage, rhs: BlocksPackage) -> Bool {
		return lhs.id == rhs.id
	}

}
