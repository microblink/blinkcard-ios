# Transition Guide: BlinkCard v2.12.0 to BlinkCard v3000.0.0 SDK

This guide will help you migrate your application from BlinkCard v2.12.0 to the new BlinkCard v3000.0.0 SDK. The BlinkCard v3000.0.0 SDK provides a modernized approach to card scanning with improved architecture and SwiftUI support.

## Key Differences

### 1. Architecture Changes

- **New Core Components**: Instead of MBRecognizer-based architecture, BlinkCard uses a streamlined Session-based approach
- **Modern Swift Features**: Built with Swift 6, leveraging latest concurrency features
- **SwiftUI First**: Native SwiftUI support through BlinkCardUX package
- **Simplified Flow**: More straightforward API with clearer separation of concerns

### 2. Integration Methods

#### BlinkCard (v2.12.0):
```swift
// Multiple integration methods
- CocoaPods
- Carthage
- Swift Package Manager
- Manual Integration
```

#### BlinkCard (v3000.0.0):
```swift
// Two primary methods
1. Swift Package Manager (Recommended)
2. Manual Integration
```

## Migration Guide

### 1. Update Dependencies

#### Remove Old Dependencies:
```ruby
# Remove from Podfile if using CocoaPods
pod 'PPBlinkCard'

# Remove from Cartfile if using Carthage
binary "https://github.com/microblink/blinkcard-ios/blob/master/blinkcard-ios.json"
```

#### Add New Dependencies:

```swift
// Add to Swift Package Manager
dependencies: [
    .package(url: "https://github.com/microblink/blinkcard-ios.git", 
             .upToNextMajor(from: "3000.0.0"))
]
```

### 2. Update Import Statements

#### Old:
```swift
import BlinkCard
```

#### New:
```swift
import BlinkCard
import BlinkCardUX  // If using the UX components
```

### 3. Initialization Changes

#### Old (BlinkCard v2):
```swift
// Old initialization
MBMicroblinkSDK.shared().setLicenseKey("license-key")

// Creating recognizer
let blinkCardRecognizer = MBBlinkCardRecognizer()
let recognizerCollection = MBRecognizerCollection(recognizers: [blinkCardRecognizer])
```

#### New (BlinkCard v3000):
```swift
// New initialization
let settings = BlinkCardSdkSettings(
    licenseKey: "your-license-key",
    downloadResources: true
)

let sdk = try await BlinkCardSdk.createBlinkCardSdk(withSettings: settings)
let session = await sdk.createScanningSession()
```

### 4. UI Implementation Changes

#### Old (BlinkCard v2):

```swift
// Using BlinkCard overlay controller
let settings = MBBlinkCardOverlaySettings()
let blinkCardOverlayViewController = MBBlinkCardOverlayViewController(
    settings: settings,
    recognizerCollection: recognizerCollection,
    delegate: self
)

let recognizerRunnerViewController = MBViewControllerFactory.recognizerRunnerViewController(
    withOverlayViewController: blinkCardOverlayViewController
)
```

#### New (BlinkCard v3000):

```swift
// Using BlinkCardUX
let analyzer = await BlinkCardAnalyzer(
    sdk: sdk,
    eventStream: BlinkCardEventStream()
)

let viewModel = BlinkCardUXModel(analyzer: analyzer)

// In SwiftUI
struct ContentView: View {
    var body: some View {
        BlinkCardUXView(viewModel: viewModel)
    }
}
```

### 5. Result Handling

#### Old (BlinkCard v2):
```swift
// BlinkCard delegate method
func blinkCardOverlayViewControllerDidFinishScanning( _ blinkCardOverlayViewController: MBBlinkCardOverlayViewController, state: MBRecognizerResultState) {
    if state == .valid {
        // Access results through recognizer
        let result = blinkCardRecognizer.result
    }
}
```

#### New (BlinkCard v3000):

```swift
// Process results
let frameProcessResult = await session.process(inputImage: capturedImage)
if if frameProcessResult.processResult?.resultCompleteness.scanningStatus == .cardScanned {
    let finalResult = await session.getResult()
    // Handle the result
}

// Or using SwiftUI binding
viewModel.$scanningResult
    .sink { scanningResult in
        if let result = scanningResult {
            // Handle the result
        }
    }
    .store(in: &cancellables)
```

### 6. Custom UI Implementation

#### Old (BlinkCard v2):
```swift
class CustomOverlayViewController: MBCustomOverlayViewController {
    // Custom overlay implementation
}
```

#### New (BlinkCard v3000):

```swift
// Create custom ViewModel
class CustomViewModel: ObservableObject {
    let camera: Camera = Camera()
    let analyzer: any CameraFrameAnalyzer<BlinkCardScanningResult, UIEvent>
    
    @Published var captureResult: BlinkCardScanningResultState?
    
    init(analyzer: any CameraFrameAnalyzer<BlinkCardScanningResult, UIEvent>) {
        self.analyzer = analyzer
    }
}

// Create custom SwiftUI View
struct CustomScanView: View {
    @StateObject var viewModel: CustomViewModel
    
    var body: some View {
        CameraView(camera: viewModel.camera)
            .task {
                await viewModel.camera.start()
                await viewModel.analyze()
            }
    }
}
```

## Additional Considerations

### Resource Management

- BlinkCard SDK supports both downloaded and bundled resources
- Configure resource handling through `BlinkCardSdkSettings`:
  ```swift
  let settings = BlinkCardSdkSettings(
      licenseKey: "your-license-key",
      downloadResources: true,  // Set to false for bundled resources
      resourceLocalFolder: "CustomFolder"  // Optional custom storage location
  )
  ```

## Best Practices for Migration

1. **Gradual Migration**:
   - Consider migrating feature by feature if possible
   - Test thoroughly in a development environment before production deployment

2. **Resource Management**:
   - Decide between downloaded or bundled resources early in the migration
   - Set up proper resource paths and verify resource loading

3. **UI/UX Considerations**:
   - Take advantage of SwiftUI if possible
   - Consider reimplementing custom UI components using the new architecture

4. **Error Handling**:
   - Update error handling to work with the new async/await pattern
   - Implement proper error handling for resource downloading if used

## Support and Resources

- For support: Contact technical support through the support portal
