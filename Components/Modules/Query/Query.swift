import Granite
import SandKit

struct Query: GraniteComponent {
    @Command var center: Center
    
    @Relay var environment: EnvironmentService
    @Relay var account: AccountService
    @Relay var sand: SandService
    @Relay var prompts: PromptService
    @Relay var query: QueryService
    
    @SharedObject(SessionManager.id) var session: SessionManager
    
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
    
    var maxTokenCount: Int {
        prompts.maxTokenCount(sand.state.commandSet)
    }
}
