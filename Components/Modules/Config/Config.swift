import Granite
import SwiftUI

struct Config: GraniteComponent {
    @Command var center: Center
    
    @Relay var account: AccountService
    @Relay var config: ConfigService
    @Relay var sand: SandService
    
    @SharedObject(WindowVisibilityManager.id) var windowVisibility: WindowVisibilityManager
    @SharedObject(SessionManager.id) var session: SessionManager
}
