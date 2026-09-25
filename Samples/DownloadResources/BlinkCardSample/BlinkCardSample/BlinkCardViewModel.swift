// Created by Toni Krešo on 18.02.2026.. 
// Copyright (c) 2026 Microblink Ltd. All rights reserved.

// ANY UNAUTHORIZED USE OR SALE, DUPLICATION, OR DISTRIBUTION 
// OF THIS PROGRAM OR ANY OF ITS PARTS, IN SOURCE OR BINARY FORMS, 
// WITH OR WITHOUT MODIFICATION, WITH THE PURPOSE OF ACQUIRING 
// UNLAWFUL MATERIAL OR ANY OTHER BENEFIT IS PROHIBITED! 
// THIS PROGRAM IS PROTECTED BY COPYRIGHT LAWS AND YOU MAY NOT 
// REVERSE ENGINEER, DECOMPILE, OR DISASSEMBLE IT.

import SwiftUI
import Combine
import BlinkCard
import BlinkCardUX

enum UIState {
    case loading
    case home
    case scanBuiltin(BlinkCardUXModel)
    case scanCustom(CustomScanningViewModel)
    case error(String)
    case success(BlinkCardScanningResult)
}

@MainActor
final class BlinkCardViewModel: ObservableObject {
    
    // Valid until: 2026-01-25
    private let licenseKey = "sRwDAAEeY29tLm1pY3JvYmxpbmsuQmxpbmtDYXJkU2FtcGxlAR5jb20ubWljcm9ibGluay5CbGlua0NhcmRTYW1wbGVJXPedJytmX1991dCwz48kKR5wPOypLKSB4QrsQZ2ecRqjPXFz1QGD1TKdVaHEssJQnrdLajlgUAv0z8RV+tNhnVHJ7eroITOTdP3dKmbLRo7MdXA3rdwPCgDJSWGFDbynE0s="
    private var sdkInstance: BlinkCardSdk?
    private var cancellables = Set<AnyCancellable>()
    @Published var state: UIState = .loading
    
    init() {
        Task {
            await initializeSdk()
        }
    }
    
    func initializeSdk() async {
        do {
            let settings = BlinkCardSdkSettings(licenseKey: licenseKey)
            sdkInstance = try await BlinkCardSdk.createBlinkCardSdk(withSettings: settings)
        } catch {
            state = .error(error.localizedDescription)
        }
        state = .home
    }
    
    func performScan(customScan: Bool = false) async {
        guard let sdkInstance = sdkInstance
        else {
            state = .error("Failed to perform scan due to missing sdk")
            return
        }
        
        if let analyzer = try? await BlinkCardAnalyzer(sdk: sdkInstance, blinkCardSessionSettings: BlinkCardSessionSettings(), eventStream: BlinkCardEventStream()) {
            if customScan {
                let scanningUxModel = CustomScanningViewModel(analyzer: analyzer)
                scanningUxModel.$scanningResult
                    .sink { [weak self] scanningResult in
                        if let scanningResult = scanningResult {
                            self?.state = .success(scanningResult)
                        } else {
                            self?.state = .home
                        }
                    }
                    .store(in: &cancellables)
                
                state = .scanCustom(scanningUxModel)
            } else {
                let scanningUxModel = BlinkCardUXModel(analyzer: analyzer)
                scanningUxModel.$result
                    .sink { [weak self] scanningResultState in
                        if let scanningResultState {
                            if let scanningResult = scanningResultState.scanningResult {
                                self?.state = .success(scanningResult)
                            }
                            else {
                                self?.state = .home
                            }
                        }
                    }
                    .store(in: &cancellables)
                
                state = .scanBuiltin(scanningUxModel)
            }
        }
    }
}
