# BlocksSDK iOS

By [Blocks lockers](https://blockslockers.com/)

## Requirements

* iOS 11+
* Xcode 12
* Swift 5.3

## Installation

### CocoaPods

To install BlocksSDK, simply add the following line to your Podfile:

    pod 'BlocksSDK', '~> 0.4.0'

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

    case .opened:
        // Box opened

    case .finished:
        // Box closed

    case .error(let error):
        switch error {
        case .blocksMismatch:
            // Blocks serial number mismatch

        case .blocksBusy:
            // Blocks are not ready for bluetooth pairing

        case .connectionError:
            // Bluetooth connection error

        case .communicationError:
            // Bluetooth communication error

        case .pickupError:
            // Package not found or already picked up

        case .internalError:
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
