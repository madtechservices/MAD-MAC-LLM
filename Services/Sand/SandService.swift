import Granite
import SandKit

struct SandService: GraniteService {
    @Service(.online) var center: Center
}
