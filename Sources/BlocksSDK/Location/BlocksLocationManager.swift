//
//  BlocksLocationManager.swift
//  BlocksSDK
//
//  Created by Alex Studnicka on 12.11.2020.
//  Copyright © 2021 Property Blocks s.r.o. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications

public final class BlocksLocationManager: NSObject {

	private let manager = CLLocationManager()

	private let region: CLBeaconRegion = {
		let proximityUUID = UUID(uuidString: "107d6776-1c08-4f37-b4a6-a244c1e54127")!
		let region = CLBeaconRegion(proximityUUID: proximityUUID, identifier: "io.spaceflow.blocks.beacon")
		region.notifyOnEntry = true
		region.notifyOnExit = true
		region.notifyEntryStateOnDisplay = true
		return region
	}()

	/// App will be launched and the delegate will be notified when the device's screen is turned on and the user is in the region.
	public var notifyEntryStateOnDisplay = true {
		didSet {
			region.notifyEntryStateOnDisplay = notifyEntryStateOnDisplay
		}
	}

	override init() {
		super.init()
		manager.delegate = self
	}

	func startMonitoring() {
		manager.startMonitoring(for: region)
	}

	func stopMonitoring() {
		manager.stopMonitoring(for: region)
	}

	func requestState() {
		manager.requestState(for: region)
	}

}

// MARK: - CLLocationManagerDelegate

extension BlocksLocationManager: CLLocationManagerDelegate {

	public func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
		switch state {
		case .inside:
			locationManager(manager, didEnterRegion: region)
		case .outside:
			locationManager(manager, didExitRegion: region)
		case .unknown:
			break
		}
	}

	public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
		if let beaconRegion = region as? CLBeaconRegion {
			manager.startRangingBeacons(in: beaconRegion)
		}
	}

	public func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
		if let beaconRegion = region as? CLBeaconRegion {
			manager.stopRangingBeacons(in: beaconRegion)
		}
	}

	public func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
		let nearbyBeacons = beacons.filter({ $0.proximity == .immediate || $0.proximity == .near })
		let nearbyBlocks = nearbyBeacons.map { String(format: "%04d-%04d", $0.major.intValue, $0.minor.intValue) }
		BlocksSDK.shared.nearbyBlocks = nearbyBlocks
		BlocksSDK.shared.delegate?.didUpdateNearbyBlocks(nearbyBlocks)
	}

}
