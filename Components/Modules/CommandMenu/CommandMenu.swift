import Granite

struct CommandMenu: GraniteComponent {
    @Command var center: Center
    
    @Relay var sand: SandService
    @Relay var prompts: PromptService
    @Relay var query: QueryService
    
    @SharedObject(SessionManager.id) var session: SessionManager
}
