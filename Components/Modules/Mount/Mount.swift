import Granite
import SandKit
import SwiftUI

struct Mount: GraniteComponent {
    @Command var center: Center
    
    @Relay var environment: EnvironmentService
    @Relay var account: AccountService
    @Relay var sand: SandService
    @Relay var config: ConfigService
    
    @SharedObject(SessionManager.id) var session: SessionManager
    
}
