import Granite

struct EnvironmentService: GraniteService {
    @Service(.online) var center: Center
}
