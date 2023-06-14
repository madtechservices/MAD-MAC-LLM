//
//  SandService._.swift
//  Nea
//
//  Created by PEXAVC on 5/14/23.
//

import Granite
import SandKit
import Foundation
import PDFKit

extension SandService {
    struct Reset: GraniteReducer {
        typealias Center = SandService.Center
        
        @Relay var query: QueryService
        
        func reduce(state: inout Center.State) {
            
            query.center.$state.binding.value.wrappedValue = ""
            state.response = ""
            state.responseHelpers = []
            state.isResponding = false
            state.commandAutoComplete = []
            state.subCommandSet = nil
            state.subCommandFileSet = nil
            state.commandSet = nil
            SandGPTTokenizerManager.shared.pause = false
            SandGPT.shared.reset()
        }
    }
}
