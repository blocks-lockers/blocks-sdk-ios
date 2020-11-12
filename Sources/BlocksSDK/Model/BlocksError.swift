//
//  BlocksError.swift
//  BlocksSDK
//
//  Created by Alex Studnicka on 12.11.2020.
//  Copyright © 2020 Spaceflow s.r.o. All rights reserved.
//

import Foundation

public enum BlocksError: Error {

	case internalError
	case serverError
	case networkError

	case blocksNotNearby

}
