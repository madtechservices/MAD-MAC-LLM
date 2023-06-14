import Granite
import SandKit
import Foundation
import SwiftUI

extension SandService {
    struct Restore: GraniteReducer {
        typealias Center = SandService.Center
        
        struct Meta: GranitePayload {
            let history: QueryHistory
        }
        
        @Payload var meta: Meta?
        
        @Relay var query: QueryService
        @Relay var prompts: PromptService
        @Relay var environment: EnvironmentService
        
        func reduce(state: inout Center.State) {
            guard let meta = self.meta else { return }
            
            //TODO: multiple reducers in a single block are not persisting states
            //Race conditions, related to Issue #1 in Granite repo
            
            SandGPT.shared.reset()
            
            if let command = meta.history.command {
                //Restore command
                state.commandAutoComplete = prompts.commands
                
                print("[SandService] restoring command: \(command)")
                
                //Setup Command toolbar
                environment
                    .center
                    .commandToolbarActivated
                    .send(
                        EnvironmentService
                            .CommandToolbarActivated
                            .Meta(isActive: true))
                
                state.commandSet = command.lowercased().replacingOccurrences(of: "/", with: "")
                
                //Restore subcommands
                if let prompt = prompts.prompt(command),
                   let scvKeys = meta.history.subCommandSet?.keys {
                    var scvS: [String: Prompts.Subcommand] = [:]
                    
                    let used = prompt.subCommands.filter( { Array(scvKeys).contains($0.id) == true })
                    for scv in used {
                        if let scValueId = meta.history.subCommandSet?[scv.id],
                           let scValue = scv.values.first(where: { $0.id == scValueId }) {
                            scvS[scv.id] = .init(id: scv.id, value: scValue)
                        }
                    }
                    state.subCommandSet = scvS//meta.history.subCommandSet
                    state.subCommandFileSet = meta.history.subCommandFileSet
                }
            }
            
            //Restore Response
            state.response = meta.history.response
            if meta.history.response.isEmpty == false {
                
                state.responseHelpers = HelperInfo.generate(from: state.response)
                
                //processDocument.send(payload)
                //let doc = Document(parsing: state.response, source: nil)
                let lineCount = 1//Int(doc.range?.upperBound.line ?? 0)
                
                environment
                    .center
                    .responseWindowSize
                    .send(
                        EnvironmentService
                            .ResponseWindowSizeUpdated
                            .Meta(lineCount: lineCount + (lineCount > 1 ? 2 : 0),
                                  responseHelpersActive: state.responseHelpers.isNotEmpty,
                                  basedOnString: state.response))
                
            }
            
            //Restore query
            query.center.$state.binding.value.wrappedValue = meta.history.query
            
            //Environment
            environment
                .center
                .interact
                .send(EnvironmentService
                    .Interact
                    .Meta(interaction: .bringToFront(.mount)))
        }
    }
}
