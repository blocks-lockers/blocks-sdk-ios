//
//  BlocksLocalizedString.swift
//  BlocksSDK
//
//  Created by Alex Studnicka on 12.11.2020.
//  Copyright © 2020 Spaceflow s.r.o. All rights reserved.
//

import Foundation

public final class BlocksLocalizedString: Codable {

	let en: String?
	let cs: String?

}

public extension BlocksLocalizedString {

	var value: String {
		return en ?? cs ?? ""
//		if Localization.currentLanguage == "cs" {
//			return cs ?? en ?? ""
//		} else {
//			return en ?? cs ?? ""
//		}
	}

}
