import Granite
import SwiftUI
import Foundation

extension Home {
    struct DidAppear: GraniteReducer {
        typealias Center = Home.Center
        
//        @Relay var stockTest: StockService
        
        func reduce(state: inout Center.State) {
//            stockTest.center.getMovers.send(StockService.GetMovers.Meta())
        }
    }
}
