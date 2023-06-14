import Granite
import SandKit

struct ShortcutBar: GraniteComponent {
    @Command var center: Center
    
    @Relay var environment: EnvironmentService
    
    @Relay var sand: SandService
}
