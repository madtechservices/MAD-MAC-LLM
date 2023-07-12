import Granite
import SandKit

struct Query: GraniteComponent {
    @Command var center: Center
    
    @Relay var environment: EnvironmentService
    @Relay var account: AccountService
    @Relay var sand: SandService
    @Relay var prompts: PromptService
    
    @SharedObject(SessionManager.id) var session: SessionManager
}
