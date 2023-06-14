import Granite
import SwiftUI
import SandKit

extension SandService {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            var response: String = ""
            var responseHelpers: [HelperInfo] = []
            
            var isResponding: Bool = false
            
            var commandAutoComplete: [String] = []
            
            var commandSet: String? = nil
            var subCommandSet: [String: Prompts.Subcommand]? = nil
            var subCommandFileSet: [String: [String: String]]? = nil
            var lastError: Error? = nil {
                didSet {
                    errorExists = lastError != nil
                }
            }
            
            var errorExists: Bool = false
            
            var isCommandSet: Bool {
                commandSet != nil
            }
        }
        
        @Event public var ask: Ask.Reducer
        @Event public var activateCommands: ActivateCommands.Reducer
        @Event public var setCommand: SetCommand.Reducer
        @Event public var setSubCommand: SetSubCommand.Reducer
        @Event public var setSubCommandFile: SetSubCommandFile.Reducer
        @Event public var setSubCommandFileContents: SetSubCommandFileContents.Reducer
        
        @Event public var restore: Restore.Reducer
        @Event public var reset: Reset.Reducer
        
        @Store public var state: State
    }
    
    struct Error: GraniteModel {
        var message: String
        var symbol: String = ""
    }
}
