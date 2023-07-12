import Granite
import SandKit

struct SandService: GraniteService {
    @Service(.online) var center: Center
    
    //Since SandService is an `online` service
    //it will update all linked components each time
    //the state is changed, this is expensive so we
    //create a child service to handle queries
    @Relay var query: QueryService
}
