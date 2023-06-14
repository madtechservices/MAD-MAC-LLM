import Granite
import SwiftUI

extension ShortcutBar {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            var lastCopiedText: String = ""
        }
        
        @Store public var state: State
    }
}
