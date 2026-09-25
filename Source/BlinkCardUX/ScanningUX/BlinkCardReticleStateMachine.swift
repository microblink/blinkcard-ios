//  Created by Toni Kreso on 11.02.2026..
//  Copyright (c) Microblink. All rights reserved.
//  This code is provided for use as-is and may not be copied, modified, or redistributed.
//

import Combine
import Foundation

public class BlinkCardReticleStateMachine: ReticleStateMachineProtocol {
    public typealias ReticleStateType = BlinkCardReticleState
    
    @Published public var reticleState: BlinkCardReticleState
    public var fallbackState: BlinkCardReticleState
    public var lastReticleStateChange: TimeInterval
    public var eventCounter: [BlinkCardReticleState : Int]
    public var reticleStateIsInterruptible: Bool
    
    public init() {
        self.reticleState = .initialState
        self.fallbackState = .initialState
        self.lastReticleStateChange = Date().timeIntervalSince1970
        self.eventCounter = [:]
        self.reticleStateIsInterruptible = false
    }
    
    public func calculateState(using mostFrequentState: BlinkCardReticleState) -> BlinkCardReticleState {
        return mostFrequentState
    }

    public func forcedState(state: ReticleStateType) {
        // no-op
        print("WARN: forcedState(state:) not yet implemented for BlinkCardReticleStateMachine")
    }


    public func setInitialState() {
        // no-op
        print("WARN: setInitialState not yet implemented for BlinkCardReticleStateMachine")
    }
}
