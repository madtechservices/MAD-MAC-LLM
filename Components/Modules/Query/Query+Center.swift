import Granite
import SwiftUI

extension Query {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            var query: String = ""
            var isEditing: Bool = false
            var isCommandMenuActive: Bool = false
            //var response: String = ""
        }
        
        @Event var ask: Query.Ask.Reducer
        
        @Store public var state: State
    }
}
