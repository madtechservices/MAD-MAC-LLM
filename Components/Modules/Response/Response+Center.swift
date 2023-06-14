import Granite
import SwiftUI

extension Response {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            var response: String = "Hello!"
        }
        
        @Store public var state: State
    }
}
