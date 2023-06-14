import Granite
import SwiftUI

extension CommandToolbar {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            var scSelected: String = ""
            var toggleDropdown: Bool = false
            var showFileExtAlert: Bool = false
            
            var editorProperties: FileTextEditorView.Properties? = nil
        }
        
        @Store public var state: State
    }
}
