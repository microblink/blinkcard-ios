<p align="center" >
  <img src="https://raw.githubusercontent.com/wiki/blinkcard/blinkcard-android/images/logo-microblink.png" alt="Microblink" title="Microblink">
</p>

[![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)

# BlinkCard SDK

The BlinkCard SDK is a comprehensive solution for implementing secure card scanning on iOS. It offers powerful capabilities for capturing and analyzing a wide range of payment cards. The package consists of BlinkCard, which serves as the core module, and an optional BlinkCardUX package that provides a complete, ready-to-use solution with a user-friendly interface.

# Table of Contents

- [Requirements](#requirements)
- [Quick Start](#quick-start)
  - [Getting started with the BlinkCard SDK](#getting-started-with-the-blinkcard-sdk)
    - [Integration](#integration)
    - [Manual integration](#manual-integration)
    - [Initiating the card scanning process](#initiating-the-blinkcard-process)
    - [Initiating BlinkCard UX](#initiating-blinkcard-ux)
    - [Initiating BlinkCard](#blinkcard)
- [BlinkCard Components](#BlinkCard-components)
  - [BlinkCardSdk](#BlinkCardSdk)
  - [BlinkCardSession](#blinkcardsession)
  - [ProcessResult](#processresult)
  - [InputImage](#inputimage)
  - [Resource Management](#resource-management)
- [BlinkCardUX Components](#BlinkCard-ux-components)
  - [BlinkCardAnalyzer](#BlinkCardAnalyzer)
  - [BlinkCardUXModel](#BlinkCardUXModel)
  - [BlinkCardUXView](#BlinkCardUXModel)
- [Creating custom UX component](#creating-custom-ux-component)
- [Localization](#localization)
- [SDK Integration Troubleshooting](#sdk-integration-troubleshooting)
- [SDK size](#blinkcard-sdk-size)
- [Additional info](#additional-info)

# Requirements

SDK package contains `BlinkCard` framework, `BlinkCardUX` package and one or more sample apps that demonstrate their integration. The `BlinkCard` framework can be deployed on iOS 15.0 or later and `BlinkCardUX` package can be deployed on iOS 16.0 or later. The framework and package support Swift projects.

> Both `BlinkCard` and `BlinkCardUX` are **dynamic packages**

> This project is designed with Swift 6, leveraging the latest concurrency features to ensure efficient, and modern application performance.

> `BlinkCardUX` is built with full support for SwiftUI, enabling seamless integration of declarative user interfaces with modern, responsive design principles.

## Requirements

| SDK        | Platform       | Installation                                    | Minimum Swift Version | Type    |
| ---------- | -------------- | ----------------------------------------------- | --------------------- | ------- |
| BlinkCard    | iOS 15.0+      | [Swift Package Manager](#swift-package-manager) | 5.10 / Xcode 26.2     | Dynamic |
| BlinkCardUX  | iOS 16.0+      | [Swift Package Manager](#swift-package-manager) | 5.10 / Xcode 26.2     | Dynamic |


# <a name="quick-start"></a> Quick Start

In this section, you will initialize the SDK, create a capture session, and submit the images for either server-side or client-side verification, resulting in a fraud verdict and a detailed analysis of the card images.

## <a name="getting-started-with-the-blinkcard-sdk"></a> Getting started with the BlinkCard SDK

This Quick Start guide will get you up and performing card scanning as quickly as possible. All steps described in this guide are required for the integration.

This guide closely follows the BlinkCard app in the Samples folder of this repository. We highly recommend you try to run the sample app. The sample app should compile and run on your device.

The source code of the sample app can be used as a reference during the integration.

### <a name="integration"></a> Integration

To integrate the BlinkCard SDK into your iOS project, you'll need to:

1. Obtain a valid license key from the [Microblink dashboard](https://developer.microblink.com)
2. Add the SDK framework to your project

#### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler.

Once you have your Swift package set up, adding BlinkCard and BlinkCardUX as a dependency are as easy as adding it to the `dependencies` value of your `Package.swift` or the Package list in Xcode.

##### **BlinkCard**

We provide a URL to the public package repository that you can add in Xcode:

```shell
https://github.com/microblink/blinkcard-swift-package
```

##### **BlinkCardUX**

```swift
dependencies: [
    .package(url: "https://github.com/microblink/blinkcard-ios.git", .upToNextMajor(from: "3000.0.0"))
]
```

Normally you'll want to depend on the `BlinkCardUX` target:

```swift
.product(name: "BlinkCardUX", package: "BlinkCardUX")
```

> `BlinkCardUX` has a binary target dependency on `BlinkCard`, so **use this package only if you are also using our UX.**

You can see dependency in our `Package.swift`:

```swift
.binaryTarget(
    name: "BlinkCard",
    path: "Frameworks/BlinkCard.xcframework"
)
```

#### <a name="manual-integration"></a> Manual integration

If you prefer not to use Swift Package Manager, you can integrate BlinkCard and BlinkCardUX into your project manually.

##### **BlinkCard**

[Download](https://github.com/microblink/blinkcard-ios/releases) latest release (Download `BlinkCard.xcframework.zip` file or clone this repository).

- Copy `BlinkCard.xcframework` to your project folder.

- In your Xcode project, open the Project navigator. Drag the `BlinkCard.xcframework` file to your project, ideally in the Frameworks group.

- Since `BlinkCard.xcframework` is a dynamic framework, you also need to add it to embedded binaries section in General settings of your target and choose option `Embed & Sign`.

##### **BlinkCardUX**

- Open up Terminal, cd into your top-level project directory, and run the following command "if" your project is not initialized as a git repository:

```shell
$ git init
```

- Add BlinkCardUX as a git submodule by running the following command:

```shell
$ git submodule add https://github.com/microblink/blinkcard-ios.git
```

To add a local Swift package as a dependency in Xcode:
    1.    Go to your Xcode project.
    2.    Select your project in the Project Navigator.
    3.    Go to the Package Dependencies tab under your project settings.
    4.    Click the ”+” button to add a new dependency.
    5.    In the dialog that appears, select the “Add Local…” option at the bottom left.
    6.    Navigate to the folder containing your local Swift package and select it.

This will add the local Swift package as a dependency to your Xcode project.

> `BlinkCardUX` has a binary target dependency on `BlinkCard`, so **use this package only if you are also using our UX.**

### <a name="initiating-the-blinkcard-process"></a> Initiating the card scanning process

In files in which you want to use the functionality of the SDK place the import directive.

```swift
import BlinkCard
```

1. Initialize the SDK with your license key:

```swift
let settings = BlinkCardSdkSettings(
    licenseKey: "your-license-key",
    downloadResources: true
)

let sdk = try await BlinkCardSdk.createBlinkCardSdk(withSettings: settings)
```

2. Create a capture session:

```swift
let session = await sdk.createScanningSession()
```

3. Process images and handle results:

```swift
let result = await session.process(inputImage: capturedImage)
if result.processResult?.resultCompleteness.scanningStatus == .cardScanned {
    let finalResult = await session.getResult()
    Task { @ProcessingActor in
        let sessionResult = BlinkCardSession.getResult()
    }
}
```

### <a name="initiating-blinkcard-ux"></a> Initiating BlinkCard UX

We provide the BlinkCardUX package, which encapsulates all the necessary logic for the card scanning process, streamlining integration into your app.

In files in which you want to use the functionality of the SDK place the import directive.

```swift
import BlinkCardUX
```

1. Initialize the BlinkCardAnalyzer:

- Begin by creating an instance of the BlinkCardAnalyzer after initializing the capture session:

```swift
let analyzer = await BlinkCardAnalyzer(
    sdk: sdk,
    eventStream: BlinkCardEventStream()
)
```

2. Create a BlinkCardUXModel:

- Next, use the BlinkCardAnalyzer to initialize the BlinkCardUXModel:

```swift
let viewModel = BlinkCardUXModel(analyzer: analyzer)
```

3. Display the BlinkCardUXView in SwiftUI:

- Add the BlinkCardUXView to your SwiftUI view hierarchy using the BlinkCardUXModel::

```swift
struct ContentView: View {
    var body: some View {
        BlinkCardUXView(viewModel: viewModel)
    }
}
```

4. Access the Capture Result:

- The BlinkCardUXModel exposes the scanning result through the result property, which is a @Published variable. You can observe it to handle the result of the card capture and verification process inside your ViewModel:

```swift
viewModel.$result
    .sink { [weak self] scanningResultState in
        if let scanningResultState {
                if let scanningResult = scanningResultState.scanningResult {
                    // Handle the scanning result
                    print("Scanning completed with result: \(scanningResult)")
                }
        }
    }
    .store(in: &cancellables)
```

- or you can also directly observe it within your SwiftUI views using SwiftUI’s @ObservedObject or @StateObject property wrappers. This allows you to automatically update your UI based on the capture result without manually handling Combine subscriptions.

```swift
struct ContentView: View {
    @StateObject var viewModel: BlinkCardUXModel

    var body: some View {
        VStack {
            BlinkCardUXView(viewModel: viewModel)

            if let result = viewModel.scanningResult {
                Text("Scanning Result: \(result.scanningResult.description)")
            } else {
                Text("Awaiting scanning...")
            }
        }
    }
}
```

### <a name="blinkcard"></a> Initiating BlinkCard

BlinkCard is a powerful card scanning solution designed to enhance the security and accuracy of card scanning processes.

## <a name="BlinkCard-components"></a> BlinkCard Components

### BlinkCardSdk

The `BlinkCardSdk` class serves as the main entry point for card scanning functionality. It manages SDK initialization, resource downloading, and session creation.

```swift
let settings = BlinkCardSdkSettings(
    licenseKey: "your-license-key",
    downloadResources: true
)

do {
    let sdk = try await BlinkCardSdk.createBlinkCardSdk(withSettings: settings)
    let session = await sdk.createScanningSession()
    // Use the session for card scanning
} catch {
    // Handle initialization errors
}
```

### BlinkCardSession

`BlinkCardSession` is a Swift class that manages card scanning operations, providing a robust interface for capturing, processing, and validating cards through image analysis and scanning.

The `BlinkCardSession` class serves as the primary controller for card scanning workflows, handling various aspects such as:
- Image processing and analysis
- Session lifecycle management
- Result generation and processing

#### Initialization

```swift
let sdk = try await BlinkCardSdk.createBlinkCardSdk(withSettings: settings)
let BlinkCardSession = await sdk.createScanningSession()
```

Creates a new capture session with specified settings and resource path configurations.

#### Key Features

##### Cancel Processing

```swift
public func cancelActiveProcessing()
```

Immediately terminates any ongoing processing operations. This method can be called from any context and is useful for handling user cancellations or session aborts.

##### Image Processing

```swift
@ProcessingActor
public func process(inputImage: InputImage) -> FrameProcessResult
```

Processes an input image and provides detailed analysis results. This method:
- Analyzes the provided image according to session settings
- Returns a `FrameProcessResult` containing analysis results and completion status
- Must be executed within the ProcessingActor context

##### Result Retrieval

```swift
@ProcessingActor
public func getResult() -> BlinkCardScanningResult
```

Retrieves the final results of the capture session, including:
- All captured images
- Session metadata
- Must be called within the ProcessingActor context

#### Usage Example

```swift
/// Processes a camera frame for card analysis.
/// - Parameter image: The camera frame to analyze
public func analyze(image: CameraFrame) async {
    guard !paused else { return }
    let inputImage = InputImage(cameraFrame: image)
    
    let result = await blinkCardSession.process(inputImage: inputImage)

    if result.processResult?.resultCompleteness.scanningStatus == .cardScanned {
        guard !scanningDone else { return }
        scanningDone = true
        Task { @ProcessingActor in
            let sessionResult = BlinkCardSession.getResult()
            // Finish scanning
        }
    }
}
```

Please refer to our `BlinkCardAnalyzer` in the BlinkCardUX module for implementation details and guidance on its usage.

#### Integration Considerations

1. Actor Isolation: Many methods must be called within the `ProcessingActor` context to ensure thread safety
2. Session Management: Each session maintains its own unique identifier and state
3. Resource Management: Proper initialization with valid resource paths is crucial for operation
4. Cancellation Support: Operations can be cancelled at any time using `cancelActiveProcessing()`

The class implements the `Sendable` protocol and uses actor isolation (`@ProcessingActor`) to ensure thread-safe operations in concurrent environments.

- Ensure proper error handling for processing operations
- Consider implementing timeout mechanisms for long-running operations
- Maintain proper lifecycle management of the session
- Handle results appropriately according to your application's needs

### ProcessResult

`ProcessResult` is a Swift structure that encapsulates the complete results of a card scanning process, combining frame analysis with completion status information.

- Image analysis status
- Completion status

#### Key Features

##### InputImageAnalysisResult

Contains detailed analysis results for a single frame in the scanning process.

##### DetectionStatus

An enumeration representing the status of card detection during scanning.

- `failed`: Card recognition failed
- `success`: Card recognition completed successfully
- `cameraTooFar`: Card has been detected but the camera is too far from the card
- `cameraTooClose`: Card has been detected but the camera is too close to the card
- `cameraAngleTooSteep`: Card has been detected but the camera’s angle is too steep
- `documentTooCloseToCameraEdge`: Card has been detected but the card is too close to the camera edge
- `documentPartiallyVisible`: Only part of the card is visible

##### ScanningStatus

An enumeration that defines the possible statuses that can occur during the scanning operation, specifically for managing the progress of scanning sides and the entire card.

- `scanningSideInProgress`: Scanning of a side is in progress
- `sideScanned`: First side of the card is scanned
- `documentScanned`: The card is scanned
- `cancelled`: Scanning process is cancelled

##### ResultCompleteness

A structure tracking the progress of different verification phases.

- `scanningStatus`: `ScanningStatus` - Indicates the status of the scanning process
- `cardNumberExtractionStatus`: `FieldExtractionStatus` - Indicates the status of the card number extraction
- `cardNumberPrefixExtractionStatus`: `FieldExtractionStatus` - Indicates the status of the card number prefix extraction
- `expiryDateExtractionStatus`: `FieldExtractionStatus` - Indicates the status of the expiry date extraction
- `cardholderNameExtractionStatus`: `FieldExtractionStatus` - Indicates the status of the cardholder name extraction
- `cvvExtractionStatus`: `FieldExtractionStatus` - Indicates the status of the CVV extraction
- `ibanExtractionStatus`: `FieldExtractionStatus` - Indicates the status of the IBAN extraction
- `cardImageExtractionStatus`: `ImageExtractionStatus` - Indicates the status of the card image extraction

##### Point

Represents a 2D point in the coordinate system.

- `x`: `Int32` - X-coordinate
- `y`: `Int32` - Y-coordinate

##### Quadrilateral

Represents a four-sided polygon defined by its corner points.

- `upperLeft`: `Point`
- `upperRight`: `Point`
- `lowerRight`: `Point`
- `lowerLeft`: `Point`

#### CardLocation

Combines physical position and orientation information of a detected card.

- `location`: `Quadrilateral` - Boundary coordinates of the detected card
- `orientation`: `CardOrientation` - Orientation of the detected card

#### Usage Example

```swift
if result.processResult?.resultCompleteness.scanningStatus == .cardScanned {
    guard !scanningDone else { return }
    scanningDone = true
    Task { @ProcessingActor in
        let sessionResult = session.getResult()
        // Finish scanning
    }
}
```

#### Integration Considerations

1. Error Handling
   - Monitor `detectionStatus` for potential capture issues
   - Check `processingStatus` for overall processing success

2. Quality Control
   - Use `blur` detection to ensure optimal image quality

3. Progress Tracking
   - Use `ResultCompleteness` to track verification progress
   - Monitor `scanningStatus` for overall process state
   - Handle partial completions appropriately

All types conform to the `Sendable` protocol, ensuring thread-safe operations in concurrent environments.

##### Best practices

1. Always check `resultCompleteness.scanningStatus == .cardScanned` before concluding the scanning process
2. Implement proper error handling for all possible `DetectionStatus` cases
4. Monitor quality indicators (blur, glare, moire) for optimal capture conditions
5. Implement appropriate user feedback based on `processingStatus` and `detectionStatus`

### InputImage

`InputImage` is a Swift class that wraps either a UIImage or camera frame for processing in the card scanning system.

#### Initialization

```swift
// Create from UIImage
public init(uiImage: UIImage, regionOfInterest: RegionOfInterest = RegionOfInterest())

// Create from camera frame
public init(cameraFrame: CameraFrame)
```

#### Key Features

##### RegionOfInterest

A structure that defines the area of interest within an image for processing.

- `x`: `Float` - X-coordinate (normalized between 0 and 1)
- `y`: `Float` - Y-coordinate (normalized between 0 and 1)
- `width`: `Float` - Width (normalized between 0 and 1)
- `height`: `Float` - Height (normalized between 0 and 1)

##### CameraFrameVideoOrientation

An enumeration representing the device orientation during frame capture.

- `portrait`: Device in normal upright position
- `portraitUpsideDown`: Device held upside down
- `landscapeRight`: Device rotated 90 degrees clockwise
- `landscapeLeft`: Device rotated 90 degrees counterclockwise

##### CameraFrame

A structure representing a complete camera frame with its metadata.

- `buffer`: `MBSampleBufferWrapper` - Raw camera buffer containing image data
- `roi`: `RegionOfInterest` - Region of interest within the frame
- `orientation`: `CameraFrameVideoOrientation` - Camera orientation
- `width`: `Int` - Frame width in pixels (computed property)
- `height`: `Int` - Frame height in pixels (computed property)

```swift
public init(
    buffer: MBSampleBufferWrapper, 
    roi: RegionOfInterest = RegionOfInterest(), 
    orientation: CameraFrameVideoOrientation = .portrait
)
```

```swift
func processCameraOutput(_ sampleBuffer: CMSampleBuffer) {
    let frame = CameraFrame(
        buffer: MBSampleBufferWrapper(buffer: sampleBuffer),
        roi: RegionOfInterest(x: 0, y: 0, width: 1.0, height: 1.0),
        orientation: .portrait
    )

    let inputImage = InputImage(cameraFrame: frame)
}
```

#### Usage Example

```swift
// Creating from UIImage
let inputImage1 = InputImage(
    uiImage: cardImage,
    regionOfInterest: RegionOfInterest(x: 0, y: 0, width: 1.0, height: 1.0)
)

// Creating from camera frame
let inputImage2 = InputImage(cameraFrame: cameraFrame)
```

#### Integration Considerations

1. Image Source Handling
   - Choose appropriate initialization method based on image source (UIImage or camera frame)
   - Consider memory management implications when working with camera frames
   - Handle orientation conversions properly

2. Region of Interest
   - Use normalized coordinates (0-1) for region of interest
   - Validate region boundaries to prevent out-of-bounds issues
   - Consider UI implications when setting custom regions

3. Performance Optimization
   - Minimize frame buffer copies
   - Consider frame rate and processing overhead
   - Handle memory efficiently when processing multiple frames

- `InputImage` and related types conform to the `Sendable` protocol
- `CameraFrame` is marked as `@unchecked Sendable` due to buffer handling
- Care should be taken when sharing frames across threads

###### Best Practices

1. Memory Management
   - Release camera frames promptly after processing
   - Avoid unnecessary copies of large image buffers
   - Use appropriate autorelease pool when processing multiple frames

2. Error Handling
   - Check frame dimensions before processing
   - Handle invalid region of interest parameters
   - Validate image orientation data

3. Performance
   - Process frames in appropriate queue/thread
   - Consider frame rate requirements
   - Optimize region of interest for specific use cases

### <a name="resource-management"></a> Resource Management

The SDK supports both downloaded and bundled resources:

- Automatic resource downloading and caching
- Bundle-based resource loading
- Resource validation and verification

#### Downloading models

The SDK supports downloading machine learning models from our CDN. Models are automatically retrieved from https://models.cdn.microblink.com/resources when enabled.

To enable model downloads, set the downloadResources property to true in your `BlinkCardSdkSettings`:

```swift
let settings = BlinkCardSdkSettings(
    licenseKey: yourLicenseKey,
    downloadResources: true  // Enable model downloads
)
```

By default, downloaded models are stored in the `MLModels` folder. You can specify a custom storage location using the `resourceLocalFolder` property in the settings.

Model downloads occur during SDK initialization in the `createBlinkCardSdk` method:

```swift
do {
    let instance = try await BlinkCardSdk.createBlinkCardSdk(withSettings: settings)
} catch let error as ResourceDownloaderError {
    // Handle specific download errors
    if case .noInternetConnection = error {
        // Handle no internet connection
    }
    // Handle other download errors as needed
}
```

The operation may throw a `ResourceDownloaderError` with the following possible cases:

| Error Case | Description |
|------------|-------------|
| `invalidURL(String)` | The provided URL for model download is invalid |
| `downloadFailed(Int)` | Download failed with specific HTTP status code |
| `fileNotFound(URL)` | Resource file not found at specified location |
| `hashMismatch(String)` | File hash verification failed |
| `fileAccessError(Error)` | Error accessing file system |
| `cacheDirNotFound` | Cache directory not found |
| `fileCreationError(Error)` | Error creating file |
| `noInternetConnection` | No internet connection available |
| `invalidResponse` | Invalid or unexpected server response |
| `resourceUnavailable` | Requested resource is not available |

The SDK provides built-in components for handling network connectivity states.
`NetworkMonitor` is ready-to-use network connectivity monitor that uses `NWPathMonitor`:

```swift
@MainActor
public class NetworkMonitor: ObservableObject {
    @Published public var isConnected = true
    public var isOffline: Bool { !isConnected }
    
    public init() {
        setupMonitor()
    }
}
```

`NoInternetView` is a pre-built SwiftUI view for handling offline states:

```swift
public struct NoInternetView: View {
    public init(retryAction: @escaping () -> Void)
}
```

#### Bundling models

To use bundled models with our SDK, ensure the required model files are included in your app package and set the `downloadResources` property of `BlinkCardSdkSettings` to `false`. Specify the location of the bundled models using the `bundleURL` property of `BlinkCardSdkSettings`. If you are using the main bundle, you can retrieve its URL as follows:

```swift
let bundle = Bundle.main.bundleURL
```

## <a name="BlinkCard-ux-components"></a> BlinkCard UX Components

The BlinkCardUX package is source-available, allowing you to customize and adapt its functionality to suit the specific needs of your project. This flexibility ensures that you can tailor the user experience and scanning workflow to align with your app’s design and requirements.

In the next section, we will explain the main components of the BlinkCardUX package and how they work together to simplify card scanning integration.

### BlinkCardAnalyzer

The BlinkCardAnalyzer component provides a robust set of features to streamline and enhance the card scanning process. It includes real-time camera frame analysis for immediate feedback during scanning and asynchronous event streaming to ensure smooth, non-blocking operations. The component supports pause and resume functionality, allowing users to temporarily halt the process and continue seamlessly. With session result handling, developers can easily access and process the final scanning outcomes. Additionally, it offers cancellation support, enabling users to terminate the scanning process at any time. Designed with comprehensive UI event feedback, it delivers clear and actionable guidance to users throughout the scanning workflow.

#### Key Features

##### ScanningSide

An enumeration that represents different sides of a card during the scanning process:

```swift
public enum ScanningSide: Sendable {
    case first    // First side of the card
    case second     // Second side of the card
}
```

##### BlinkCardEventStream

An actor that manages the stream of UI events during the card scanning process:

```swift
public actor BlinkCardEventStream: EventStream {
    public func send(_ events: [BlinkCardUIEvent])
    public var stream: AsyncStream<[BlinkCardUIEvent]>
}
```

##### BlinkCardAnalyzer

The main analyzer component that processes camera frames and manages the card scanning workflow:

```swift
public actor BlinkCardAnalyzer: CameraFrameAnalyzer {
    public init(
        sdk: BlinkCardSdk,
        blinkCardSessionSettings: BlinkCardSessionSettings = BlinkCardSessionSettings(inputImageSource: .video),
        eventStream: BlinkCardEventStream
    )
}
```

#### Usage Example

##### Initialization

```swift
// Create an event stream
let eventStream = BlinkCardEventStream()

// Initialize the analyzer
let analyzer = await BlinkCardAnalyzer(
    sdk: blinkCardVerifySdk,
    blinkCardSessionSettings: BlinkCardSessionSettings(inputImageSource: .video),
    eventStream: eventStream
)
```

##### Processing Frames

```swift
// Analyze a camera frame
for await frame in await camera.sampleBuffer {
    await analyzer.analyze(image: CameraFrame(buffer: MBSampleBufferWrapper(cmSampleBuffer: frame.buffer), roi: roi, orientation: camera.orientation.toCameraFrameVideoOrientation()))
}
```

##### Event Handling

The component provides real-time feedback through an event stream. Events can be observed to update the UI or trigger specific actions based on the scanning progress.

```swift
eventHandlingTask = Task {
    for await events in await analyzer.events.stream {
        if events.contains(.requestSecondSide) {
            firstSideScanned(frontFlipImage: Image.frontCardImage, backFlipImage: Image.backCardImage, flipState: .flip, nextState: .second)
        } else if events.contains(.fieldIdentificationFailed) {
            self.setReticleState(.error("mb_blinkcard_card_not_fully_visible"))
        } else if events.contains(.wrongSide) {
            self.setReticleState(.error("mb_blinkcard_scanning_wrong_side"))
        } else if events.contains(.imageReturnFailed) {
            self.setReticleState(.error("mb_blinkcard_card_not_fully_visible"))
        } else if events.contains(.tooClose) {
            self.setReticleState(.error("mb_move_farther"))
        } else if events.contains(.tooFar) {
            self.setReticleState(.error("mb_move_closer"))
        } else if events.contains(.tilt) {
            self.setReticleState(.error("mb_blinkcard_keep_card_parallel"))
        } else if events.contains(.tooCloseToEdge) {
            self.setReticleState(.error("mb_move_farther"))
        } else if events.contains(.notFullyVisible) {
            self.setReticleState(.error("mb_blinkcard_card_not_fully_visible"))
        } else if events.contains(.blur) {
            self.setReticleState(.error("mb_blinkcard_blur_detected"))
        } else {
            self.setReticleState(reticleStateMachine.fallbackState)
        }
    }
}
```

##### Best Practices

When integrating the BlinkCardAnalyzer component, it is essential to follow best practices to ensure a seamless and efficient card scanning experience. By adhering to these guidelines, you can enhance user satisfaction and maintain robust application performance:

- Always handle the event stream to provide real-time user feedback during the scanning process.
- Implement proper error handling to manage scan failures gracefully and guide users effectively.
- Consider implementing timeout handling for production environments to prevent indefinite scanning sessions. Check out our implementation for more details.
- Manage memory efficiently by calling cancel() when the scanner is no longer needed, freeing up resources.
- Handle the pause/resume cycle appropriately to align with app lifecycle events, ensuring a consistent user experience.

### BlinkCardUXModel

The BlinkCardUXModel is a comprehensive view model that manages the card scanning user experience in iOS applications. This component handles camera preview, card detection, user guidance, and scanning state transitions.

BlinkCardUXModel serves as the business logic layer for the card scanning interface. It is designed as a MainActor to ensure thread-safe UI updates and implements the ObservableObject protocol for SwiftUI integration. The model manages the entire scanning workflow, from camera initialization to card capture and verification.

#### Key Features

##### Camera Management

The model offers comprehensive camera control functionality through seamless integration with AVFoundation. It includes a fully implemented camera session, ensuring thread-safe access and synchronization with the BlinkCardAnalyzer for reliable and efficient performance.

The camera system is designed to provide robust and user-friendly functionality, including:

- Automatic session management for effortless setup and teardown.
- Torch/flashlight control to adapt to various lighting conditions.
- Frame capture and analysis synchronization for real-time card processing.
- Orientation handling to ensure correct alignment regardless of device orientation.

```swift
public class ScanningViewModel<T, U, V: ReticleStateMachineProtocol, A: AlertTypeProtocol>: ObservableObject, ScanningViewModelProtocol {
    let camera: Camera = Camera()
}
```

##### User Feedback

The model provides comprehensive user feedback mechanisms. The feedback features are designed to enhance user experience and guide users effectively throughout the card scanning process. These include:

- Visual guidance through reticle state management, helping users align cards accurately.
- Error messaging and recovery suggestions, providing clear instructions to resolve issues.
- Success animations and transitions, offering a smooth and engaging user experience upon successful scans.
- Accessibility announcements, ensuring inclusivity by providing auditory feedback for users with disabilities.
- Progress indicators, keeping users informed about the scanning status in real time.

```swift
@Published var reticleState: ReticleState = .first
```

The model features a sophisticated animation system designed to provide dynamic and engaging user feedback during the card scanning process. Key animations include:

- Card flip animations, guiding users to scan both sides of a card when required.
- Success indicators, visually confirming successful scans.
- Ripple effects, drawing attention to areas of interest during the scanning process.
- State transitions, ensuring smooth and intuitive changes between different scanning states.

#### Best Practices

When implementing the BlinkCardUXModel, it’s crucial to follow best practices to ensure smooth and efficient operation. Key considerations include:

- Implement proper error handling to manage all scanning states gracefully and provide a robust user experience.
- Monitor memory usage during extended scanning sessions to avoid potential performance bottlenecks or crashes.
- Clean up resources promptly when the scanning process is complete to maintain optimal app performance.
- Handle orientation changes appropriately to ensure consistent user experience across different device orientations.

### BlinkCardUXView

BlinkCardUXView is the main scanning interface component that combines camera functionality with user interaction elements. The view is designed to provide real-time feedback during the card scanning process while maintaining a clean and intuitive user interface.

The view is built using SwiftUI and follows the MVVM (Model-View-ViewModel) pattern, where:

- The view (BlinkCardUXView) handles the UI layout and user interactions
- The view model (BlinkCardUXModel) manages the business logic and state
- The camera integration handles the card capture pipeline

#### Key Features

##### Camera Integration

The view incorporates a camera feed through the CameraView component and manages the entire capture pipeline, including:

- Automatic camera session management
- Support for torch/flashlight functionality
- Real-time frame processing
- Orientation handling

#### User Interface Elements

The interface consists of several key components:

1. Camera Feed

    - Full-screen camera preview
    - Real-time card boundary detection
    - Automatic orientation adjustment


2. Reticle

    - Visual guidance for card positioning
    - Dynamic state feedback
    - Accessibility support
    - Animation capabilities


3. Control Buttons

    - Cancel button for session termination
    - Torch button for lighting control
    - Help button for user guidance


4. Feedback Elements

    - Success indicators
    - Visual animations
    - Accessibility announcements

#### Accessibility

The component provides comprehensive accessibility support:

- VoiceOver compatibility
- Dynamic text scaling
- Accessibility labels and hints
- Automatic announcements for state changes

### Best Practices

1. Always initialize the view with a properly configured view model
2. Implement proper error handling and user feedback
3. Monitor memory usage during extended scanning sessions
4. Handle orientation changes appropriately
5. Implement proper cleanup on view dismissal

## <a name="creating-custom-ux-component"></a> Creating custom UX component

You have the flexibility to create your own custom UX if needed. However, we strongly recommend following the implementations provided in this package as a foundation. Since the package is source-available, you can modify or extend the code directly within your project to tailor it to your specific requirements.

We also highly recommend using our built-in Camera and CameraView components, as they are fully optimized for performance and seamlessly integrated with the BlinkCardAnalyzer. However, if necessary, you can implement and use your own camera solution. 

> If implementing your own Camera component, be sure to wrap your CMSampleBufferRef to our own `MBSampleBufferWrapper`. `MBSampleBufferWrapper` safely encapsulates a Core Media sample buffer, ensuring proper reference counting and memory management while maintaining binary compatibility across different Swift versions.

### ViewModel Creation

To integrate the card scanning workflow effectively, you will start by creating a ViewModel to manage the scanning logic and interface with the underlying components. The ViewModel acts as the bridge between the CameraFrameAnalyzer and your UI, handling data flow, state management, and event processing.

In this section, we will guide you through the process of setting up and configuring the ViewModel, integrating it with the camera and analyzer components, and linking it to your SwiftUI view. This approach ensures a modular and maintainable architecture while leveraging the optimized components provided by the SDK.

```swift
@MainActor
public final class ViewModel: ObservableObject {
    // Use our Camera controller
    let camera: Camera = Camera()
    let analyzer: CameraFrameAnalyzer
    // Instructions text for the View
    @Published var instructionText: String = "Scan the first side"
    // Published BlinkCardCaptureResult, use it in your ViewModel, or directly in your SwiftUI View
    @Published public var captureResult: BlinkCardCaptureResult?

    private var eventHandlingTask: Task<Void, Never>?

    public init(analyzer: CameraFrameAnalyzer) {
        self.analyzer = analyzer
        startEventHandling()
    }
```

The `startEventHandling` method initializes an event task, allowing you to receive and process UIEvents from the CameraFrameAnalyzer’s event stream. 

```swift
private func startEventHandling() {
    eventHandlingTask = Task {
        for await events in await analyzer.events.stream {
            if events.contains(.requestSecondSide) {
                firstSideScanned(frontFlipImage: Image.frontCardImage, backFlipImage: Image.backCardImage, flipState: .flip, nextState: .second)
            } else if events.contains(.fieldIdentificationFailed) {
                self.setReticleState(.error("mb_blinkcard_card_not_fully_visible"))
            } else if events.contains(.wrongSide) {
                self.setReticleState(.error("mb_blinkcard_scanning_wrong_side"))
            } else if events.contains(.imageReturnFailed) {
                self.setReticleState(.error("mb_blinkcard_card_not_fully_visible"))
            } else if events.contains(.tooClose) {
                self.setReticleState(.error("mb_move_farther"))
            } else if events.contains(.tooFar) {
                self.setReticleState(.error("mb_move_closer"))
            } else if events.contains(.tilt) {
                self.setReticleState(.error("mb_blinkcard_keep_card_parallel"))
            } else if events.contains(.tooCloseToEdge) {
                self.setReticleState(.error("mb_move_farther"))
            } else if events.contains(.notFullyVisible) {
                self.setReticleState(.error("mb_blinkcard_card_not_fully_visible"))
            } else if events.contains(.blur) {
                self.setReticleState(.error("mb_blinkcard_blur_detected"))
            } else {
                self.setReticleState(reticleStateMachine.fallbackState)
            }
        }
    }
}
```

Implement `analyze` and `pauseScanning` methods:

```swift
public func analyze() async {
    
    Task {
        let result = await analyzer.result()
        if let scanningResult = result as? ScanningResult<BlinkCardScanningResult, BlinkCardScanningAlertType> {
            switch scanningResult {
            case .completed(let scanningResult):
                finishScan()
                self.result = BlinkCardResultState(scanningResult: scanningResult)
            case .interrupted(let alertType):
                self.alertType = alertType
            case .cancelled:
                showLicenseErrorAlert = true
            case .ended:
                self.result = BlinkCardResultState(scanningResult: nil)
            }
        }
    }
    
    for await frame in await camera.sampleBuffer {
        await analyzer.analyze(image: CameraFrame(buffer: MBSampleBufferWrapper(cmSampleBuffer: frame.buffer), roi: roi, orientation: camera.orientation.toCameraFrameVideoOrientation()))
    }
}
```

```swift
func pauseScanning() {
    Task {
        await analyzer.cancel()
    }
}
```

#### CameraFrameAnalyzer

The CameraFrameAnalyzer protocol defines the core interface for components that analyze camera frames during card scanning operations. This protocol is designed to provide a standardized way of processing camera input while maintaining thread safety through Swift's concurrency system.

The protocol defines essential methods and properties for analyzing camera frames in real-time, managing the analysis lifecycle, and providing feedback through an event stream.

```swift
public protocol CameraFrameAnalyzer: Sendable {
    func analyze(image: CameraFrame) async
    func cancel() async
    func pause() async
    func resume() async
    func restart() async throws
    func end() async
    func result() async -> ScanningResult
    var events: EventStream { get }
}
```

##### Requirements

```swift
analyze(image: CameraFrame) async
```

Processes a single camera frame for analysis. This method operates asynchronously to prevent blocking the main thread during intensive image processing operations.

```swift
cancel() async
```
Terminates the current analysis operation immediately. This method ensures proper cleanup of resources when analysis needs to be stopped before completion.

```swift
pause() async
```
Temporarily suspends the analysis operation while maintaining the current state. This is useful for scenarios where analysis needs to be temporarily halted, such as when the app enters the background.

```swift
resume() async
```
Continues a previously paused analysis operation. This method restores the analyzer to its active state and resumes processing frames.

```swift
restart() async throws
```
Starts a new analysis operation. This method resets the analyzer to its initial state and resumes processing frames.

```swift
end() async
```
Ends the analysis operation. This is used when analysis needs to be stopped, such as when the cancel button is pressed.

```swift
result() async -> ScanningResult
```
Retrieves the final result of the analysis operation. This method returns a ScanningResult object containing the analysis outcome.

```swift
events: EventStream
```
Provides access to a stream of UI events generated during the analysis process. This stream can be used to update the user interface based on analysis progress and findings.

> We strongly recommend using our `BlinkCardAnalyzer` for seamless integration. However, you can create your own custom implementation as long as it conforms to the `CameraFrameAnalyzer` protocol.

### View Creation

Once the ViewModel is set up and configured, the next step is to create a SwiftUI view that interacts with it. The ViewModel serves as the central point for managing the card scanning workflow, including handling events, processing results, and updating the UI state. By linking the ViewModel to your view, you can create a dynamic and responsive interface that provides real-time feedback to users. In this section, we will demonstrate how to build a SwiftUI view using the ViewModel, ensuring seamless integration with the underlying card scanning components.

Start by creating new SwiftUI View called CaptureView. 

```swift
struct CaptureView: View {
    @ObservedObject private var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
}
```

We need to add CameraView to our body:

```swift
var body: some View {
    GeometryReader { geometry in
    ZStack {
        CameraView(camera: viewModel.camera)
            .ignoresSafeArea()
            .statusBarHidden()
            .task {
                await viewModel.camera.start()
                await viewModel.analyze()
            }
            .onDisappear {
                viewModel.stopEventHandling()
                Task {
                    await viewModel.camera.stop()
                }
            }
        }
    }
}
```

The camera feed is displayed using CameraView, which is tightly integrated with the ViewModel’s camera property. The .task modifier ensures that the camera starts and begins analysis as soon as the view appears, and proper cleanup is handled in onDisappear to stop the camera and event handling gracefully.

We also need to add some instuction view to our ZStack that will connect our ViewModel's `instructionText`:

```swift
VStack {
    Spacer()

    // Text is in the middle of the screen     
    Text(viewModel.instructionText)
        .font(.system(size: 20))
        .foregroundColor(Color.white)
        .padding()
        .background(Color.gray)
        .clipShape(.capsule)
    
    Spacer()
}
```

### Connecting ViewModel and View

In this section, we will demonstrate how to establish the connection between the ViewModel and the View to facilitate a seamless card scanning workflow:

```swift
let analyzer = await BlinkCardAnalyzer(
    sdk: localSdk,
    eventStream: BlinkCardEventStream()
)

let viewModel = ViewModel(analyzer: analyzer)
```

In your SwiftUI View, add CaptureView:

```swift
struct ContentView: View {
    var body: some View {
        CaptureView(viewModel: viewModel)
    }
}
```

And that's it! You have created a custom SwiftUI View and ViewModel!

## <a name="localization"></a> Localization

Our app supports localization following Apple’s recommended approach. We provide a `Localizable.xcstrings` file that you can use or modify as needed. Localization is determined by the system settings, meaning you must define 
supported languages in your app’s `Info.plist` under the `Localizations` key, ensuring all required keys are included. Once configured, users can change the app’s language via Settings > [App Name] > Language. Note that in-app 
language switching is not supported, as we adhere to Apple’s intended localization flow.

### <a name="custom-translations"></a> Providing your own translations

If you want to override some or all of the SDK's built-in strings — for example to change the wording, or to ship a language we don't provide out of the box — you can point the SDK at your own translations bundle through the theme.

Add the keys you want to override (the SDK's string keys are prefixed with `mb_`, e.g. `mb_back_instructions`) to your app's `Localizable.xcstrings` (or a dedicated `.strings`/`.stringsdict` table), then configure the theme before presenting the scanning UI:

```swift
import BlinkCardUX

// Load overrides from your app's main bundle.
BlinkCardTheme.shared.localizationBundle = .main

// Optional: if your overrides live in a dedicated table (e.g. BlinkCardStrings.xcstrings),
// set its name here. Leave it as nil to use the default `Localizable` table.
BlinkCardTheme.shared.localizationTableName = "BlinkCardStrings"
```

For every string, the SDK first looks up the key in `localizationBundle` and falls back to its own built-in translation when the key isn't found — so you only need to provide the strings you actually want to change. Set `localizationBundle` back to `nil` to restore the SDK's own translations.

### <a name="forcing-a-language"></a> Forcing a specific language (in-app language switching)

By default the SDK follows the device's system language. If you want to display the scanning UI in a specific language regardless of the device settings — for example to let users switch language from within your app — set the language on the theme:

```swift
import BlinkCardUX

BlinkCardTheme.shared.language = "de"   // force German
// BlinkCardTheme.shared.language = nil // follow the system language (default)
```

The language must be present in the SDK's bundled translations (or in your `localizationBundle`); if it isn't, the SDK falls back to the system language. Right-to-left languages (Arabic, Hebrew, …) automatically flip the scanning UI's layout direction.

Configure this **before presenting the scanning UI** — SwiftUI does not re-render an already-visible scanning screen when the value changes, so set it prior to launching a new scan.

## <a name="sdk-integration-troubleshooting"></a> SDK Integration Troubleshooting

In case of problems with using the SDK, you should do as follows:

### <a name="troubleshooting-licensing-problems"></a> Licensing problems

If you are getting "invalid licence key" error or having other licence-related problems (e.g. some feature is not enabled that should be or there is a watermark on top of camera), first check the console. All licence-related problems are logged to error log so it is easy to determine what went wrong.

When you have determine what is the licence-relate problem or you simply do not understand the log, you should contact us [help.microblink.com](http://help.microblink.com). When contacting us, please make sure you provide following information:

* exact Bundle ID of your app (from your `info.plist` file)
* licence that is causing problems
* please stress out that you are reporting problem related to iOS version of BlinkCard SDK
* if unsure about the problem, you should also provide excerpt from console containing licence error

### <a name="troubleshooting-other-problems"></a> Other problems

If you are having problems with scanning certain items, undesired behaviour on specific device(s), crashes inside BlinkCard SDK or anything unmentioned, please do as follows:
    
* Contact us at [help.microblink.com](http://help.microblink.com) describing your problem and provide following information:
    * log file obtained in previous step
    * high resolution scan/photo of the item that you are trying to scan
    * information about device that you are using
    * please stress out that you are reporting problem related to iOS version of BlinkCard SDK

# <a name="blinkcard-sdk-size"></a> BlinkCard SDK size

BlinkCard is really lightweight SDK. Compressed size is just **2.0MB**. SDK size calculation is done by [creating an App Size Report with Xcode](https://developer.apple.com/documentation/xcode/reducing-your-app-s-size), one with and one without the SDK.
Here is the SDK *App Size Report* for iPhone:

|     Size     | App + On Demand Resources size | App size |
| ------------ |:------------------------------:|:--------:|
|  compressed  |             2.0 MB             |  2.0 MB  |
| uncompressed |             4.3 MB             |  4.3 MB  |

The uncompressed size is equivalent to the size of the installed app on the device, and the compressed size is the download size of your app.
You can find the *App Size Report* [here]().

# <a name="additional-info"></a> Additional info

Complete API references can be found:

* [BlinkCard](http://microblink.github.io/blinkcard-swift-package/documentation/blinkcard/)
* [BlinkCardUX](http://microblink.github.io/blinkcard-ios/documentation/blinkcardux/)
