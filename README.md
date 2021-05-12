# BlocksSDK iOS

By [Blocks Lockers](https://blockslockers.com/).

## Requirements

* iOS 11+
* Xcode 12
* Swift 5.3

## Installation

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
BlocksBluetoothManager.pickupPackage(
    packageId: "cb5d5c4f-20ed-477e-a3f9-e6e5e46c82ce",
    unlockCode: "123456",
    blocksSerialNo: "2000-0001"
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
