import Granite
import SandKit

extension Query {
    struct Ask: GraniteReducer {
        typealias Center = Query.Center
        
        func reduce(state: inout Center.State) {
            //print("{TEST} \(state.query)")
        }
    }
}
