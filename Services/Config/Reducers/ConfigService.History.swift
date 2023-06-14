//
//  ConfigService.History.swift
//  Nea (iOS)
//
//  Created by PEXAVC on 5/20/23.
//

import Granite
import SwiftUI
import Foundation
import SandKit

extension ConfigService {
    struct UpdateHistory: GraniteReducer {
        typealias Center = ConfigService.Center
        
        struct Meta: GranitePayload {
            let query: String
            let response: String
            let prompt: (any BasicPrompt)?
            var subCommandSet: [String: Prompts.Subcommand]?
            var subCommandFileSet: [String: [String: String]]?
        }
        
        @Payload var meta: Meta?
        
        func reduce(state: inout Center.State) {
            guard let meta = self.meta else { return }
            var history = state.history
            
            var scvS: [String : String] = [:]
            
            if let keys = meta.subCommandSet?.keys {
                for key in keys {
                    if let value = meta.subCommandSet?[key] {
                        scvS[key] = value.value.id
                    }
                }
            }
            
            
            history.append(.init(query: meta.query,
                                 response: meta.response,
                                 command: meta.prompt?.command.value,
                                 subCommandSet: scvS,
                                 subCommandFileSet: meta.subCommandFileSet,
                                 iconName: meta.prompt?.iconName,
                                 baseColor: meta.prompt?.baseColor.hexaRGB,
                                 isSystemPrompt: meta.prompt?.isSystemPrompt == true))
            
            state.history = history.suffix(8)
        }
    }
}
