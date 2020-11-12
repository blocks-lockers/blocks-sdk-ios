//
//  BlocksSDKDelegate.swift
//  BlocksSDK
//
//  Created by Alex Studnicka on 12.11.2020.
//  Copyright © 2020 Spaceflow s.r.o. All rights reserved.
//

import Foundation

public protocol BlocksSDKDelegate: class {

	func blocksSdk(_ blocksSdk: BlocksSDK, didEnterBlocks serialNo: String)
	func blocksSdk(_ blocksSdk: BlocksSDK, didExitBlocks serialNo: String)

}