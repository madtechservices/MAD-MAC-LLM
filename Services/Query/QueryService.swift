import Granite

struct QueryService: GraniteService {
    @Service(.online) var center: Center
}
