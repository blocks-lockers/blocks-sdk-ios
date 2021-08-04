# BlocksSDK iOS

By [Blocks lockers](https://blockslockers.com/)

## Requirements

* iOS 11+
* Xcode 12
* Swift 5.3

## Installation

### CocoaPods

To install BlocksSDK, simply add the following line to your Podfile:

    pod 'BlocksSDK', '~> 1.0.1'

### Swift Package Manager

**Xcode**

Select File > Swift Packages > Add Package Dependency...

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
BlocksBluetoothManager.shared.pickupPackage(
    packageId: "cb5d5c4f-20ed-477e-a3f9-e6e5e46c82ce",
    unlockCode: "123456",
    blocksSerialNo: "2000-0001"
) { state in
    switch state {
    case .connected:
        // Connected to Blocks

    case .finished:
        // Box opened

    case .error(let error):
        switch error {
		case operationInProgress:
			// Another operation is already in progress
			
		case bleNotReady:
			// BLE is not ready (no authorization or not powered on)
		
		case blocksNotFound:
			// Blocks not found nearby
		
		case connectionError:
			// Blocks found, but connection failed
		
		case packageNotFound:
			// Package not found in Blocks
		
		case boxNotOpened:
			// Box did not open
		
		case internalError:
			// Unknown error
        }
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

    func didUpdateNearbyBlocks(_ serialNumbers: [String]) {
        // ...
    }

}
```

## Author

* [Blocks lockers](https://github.com/blocks-lockers)
