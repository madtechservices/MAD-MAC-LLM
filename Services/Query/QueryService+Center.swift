import Granite
import SwiftUI

extension QueryService {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            var value: String = ""
        }
        
        @Event public var restore: Restore.Reducer
        
        @Store public var state: State
    }
}
