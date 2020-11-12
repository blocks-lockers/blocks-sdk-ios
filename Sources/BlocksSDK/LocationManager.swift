//
//  LocationManager.swift
//  BlocksSDK
//
//  Created by Alex Studnicka on 12.11.2020.
//  Copyright © 2020 Spaceflow s.r.o. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications

internal final class LocationManager: NSObject {

	private let manager = CLLocationManager()

	private let region: CLBeaconRegion = {
		let proximityUUID = UUID(uuidString: "107d6776-1c08-4f37-b4a6-a244c1e54127")!
		let region = CLBeaconRegion(proximityUUID: proximityUUID, identifier: "io.spaceflow.blocks.beacon")
		region.notifyOnEntry = true
		region.notifyOnExit = true
		region.notifyEntryStateOnDisplay = true
		return region
	}()

	var rangingHandler: (([String]) -> Void)?

	override init() {
		super.init()
		manager.delegate = self
	}

	func startMonitoring() {
		manager.startMonitoring(for: region)
	}

	func requestState() {
		manager.requestState(for: region)
	}

}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {

//	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//		print("didChangeAuthorization:", status.rawValue)
//	}

	func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
		switch state {
		case .inside:
			locationManager(manager, didEnterRegion: region)
		case .outside:
			locationManager(manager, didExitRegion: region)
		case .unknown:
			break
		}
	}

	func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
		if let beaconRegion = region as? CLBeaconRegion {
			manager.startRangingBeacons(in: beaconRegion)
		}
	}

	func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
		if let beaconRegion = region as? CLBeaconRegion {
			manager.stopRangingBeacons(in: beaconRegion)
		}
	}

	func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
		let nearbyBeacons = beacons.filter({ $0.proximity == .immediate || $0.proximity == .near })
		let nearbyBlocksIds = nearbyBeacons.map { String(format: "%04d-%04d", $0.major.intValue, $0.minor.intValue) }
		rangingHandler?(nearbyBlocksIds)
		checkNearbyPackages(nearbyBlocksIds: nearbyBlocksIds)
	}

}

// MARK: - Utilities

extension LocationManager {

	private func checkNearbyPackages(nearbyBlocksIds: [String]) {
//		let interval: TimeInterval = 3600
//		if let date = UserDefaults.standard.nearbyNotificationLastSentDate, date.timeIntervalSinceNow > -interval {
//			return
//		}
//
//		if UIApplication.shared.applicationState == .active {
//			return
//		}
//
//		UserDefaults.standard.nearbyNotificationLastSentDate = Date()
//
//		API.User.packages { result in
//			do {
//				let response = try result.get()
//				UIApplication.shared.applicationIconBadgeNumber = response.packages.count
//				let blocksPackages = response.packages.filter({ nearbyBlocksIds.contains($0.blocks.serialNo) })
//				if let package = blocksPackages.first {
//					let blocksName = package.blocks.name
//					self.displayProximityNotification(blocksName: blocksName, packageId: package.id)
//				}
//			} catch {
//
//			}
//		}
	}

	private func displayProximityNotification(blocksName: String, packageId: String) {
//		let content = UNMutableNotificationContent()
//		content.title = String(format: ~"notification-blocks-nearby-title", blocksName)
//		content.body = ~"notification-blocks-nearby-body"
//		content.userInfo = [
//			"package_id": packageId
//		]
//		let request = UNNotificationRequest(identifier: Constants.nearbyNotificationIdentifier, content: content, trigger: nil)
//		UNUserNotificationCenter.current().add(request)
	}

}
