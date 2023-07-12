import Granite
import SwiftUI

extension Query {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            var isEditing: Bool = false
        }
        
        @Store public var state: State
    }
    
    //TODO: could be a better way to generate helper text, a "smarter" way. But for now order matters in SandKit
    var helperText: String {
        if var helperText = prompts.prompt(sand.state.commandSet)?.subCommandHelperText {
            if let scValues = sand.state.subCommandSet?.values {
                for value in scValues {
                    helperText += value.value.additionalHelperText ?? ""
                }
                return helperText.isEmpty ? "Ask something" : helperText
            } else {
                return helperText.isEmpty ? "Ask something" : helperText
            }
        } else {
            return "Ask something"
        }
    }
    
    var showHelperView: Bool {
        let hasQuery: Bool = sand.query.state.value.isNotEmpty
        let isStandardQuery: Bool = sand.state.isCommandSet == false
        
        return (hasQuery || (!hasQuery && isStandardQuery)) && sand.state.isResponding == false
    }
    
    var isCommandMenuActive: Bool {
        environment.center.state.isCommandActive
    }
    
    var maxTokenCount: Int {
        prompts.maxTokenCount(sand.state.commandSet)
    }
}
