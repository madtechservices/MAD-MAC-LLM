import Granite
import SwiftUI
import VaultKit

extension AccountService {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            var nonce: String = ""
        }
        
        @Event var checkLogin: CheckLoginStatus.Reducer
        @Event var login: Login.Reducer
        @Event var logout: Logout.Reducer
        @Event var subscribe: Subscribe.Reducer
        @Event var purchase: Purchase.Reducer
        
        @Store public var state: State
    }
}
