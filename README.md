# BlocksSDK iOS

By [Blocks Lockers](https://blockslockers.com/).

## Introduction

This SDK for iOS contains the most up-to-date frameworks for integrating Mobile Key technology into your own iOS applications. It will setup the necessary security to communicate with Connect API, and unlock locks with encrypted Mobile Keys returned by the Connect API. The SDK for iOS includes iOS libraries, developer documentation and a sample Xcode project to get you up and running quickly and easily.

## Requirements

* iOS 11+
* Xcode 12
* Swift 5.3

## Installation

### Swift Package Manager

**Xcode**
Select File > Swift Packages > Add Package Dependency...,

https://github.com/blocks-lockers/blocks-sdk-ios

## Usage

Setup
```swift
import BlocksSDK

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
	// ...
	
	BlocksSDK.setup()

	return true
}
```

Package pick-up via Bluetooth
```swift
BlocksBluetoothManager.pickupPackage(
	packageId: packageId,
	unlockCode: unlockCode,
	blocksSerialNo: blocksSerialNo,
	completion: @escaping (Result<Void, Error>) -> Void
) { result in
	do {
		try result.get()
	} catch {
		print("error:", error)
	}
}
```

Beacon Monitoring
```swift
class BlocksManager {

	func startMonitoring() {
		// Request always location permissions from user
		BlocksSDK.shared.delegate = self
		BlocksSDK.shared.startMonitoring()
	}

}

extension BlocksManager: BlocksSDKDelegate {

	func didUpdateNearbyBlocksIds(_ nearbyBlockIds: [String]) {
		// ...
	}

}
```

## Author

* [Blocks Lockers](https://github.com/blocks-lockers)
