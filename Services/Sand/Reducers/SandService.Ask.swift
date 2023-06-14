import Granite
import SandKit
import Foundation
import SwiftUI

extension SandService {
    struct Ask: GraniteReducer {
        typealias Center = SandService.Center
        
        @Event var received: AskResponse.Reducer
        
        @Relay var environment: EnvironmentService
        @Relay var prompts: PromptService
        @Relay var config: ConfigService
        @Relay var query: QueryService
        
        func reduce(state: inout Center.State) {
            guard SandGPT.shared.isResponding == false else { return }
            
            let maxTokenCount: Int = prompts.maxTokenCount(state.commandSet)
            
            state.lastError = nil
            
            let userPrompt: String
            
            let engineeredPrompt: (any BasicPrompt)? = prompts.prompt(state.commandSet)
            
            //custom prompts may not require queries
            guard query.state.value.newlinesSanitized.isNotEmpty || engineeredPrompt?.isSystemPrompt == false else { return }
            
            let systemPrompt: String? = engineeredPrompt?.config.systemPrompt
            
            //Prompt Generation
            if let command = state.commandSet,
               let prompt = engineeredPrompt {
                if SandGPTTokenizerManager.shared.kit.tokenCount > maxTokenCount {
                    state.lastError = .init(message: "Please reduce the amount of text in order reach the token count limit. You are currently at \(SandGPTTokenizerManager.shared.kit.tokenCount)/\(maxTokenCount)")
                    
                    return
                }
                
                if prompt.hasSubcommand == true,
                    let subcommands = state.subCommandSet?.values {
                    
                    //TODO: this would also be changed once (maybe) when subcommand system gets more sophisticated
                    if let firstScv = subcommands.filter({ $0.value.acceptsFile }).filter({ $0.value.fileContents.isEmpty }).first {
                        
                        //TODO: multiple file types
                        state.lastError = .init(message: "Please add a portion of text to accompany the prompt by clicking the   􀣘  symbol in the command toolbar.")//.init(message: "Please upload a file type of \(firstScv.value.acceptedFileExtensions.map { $0.uppercased() }.joined(separator: ", ")).")
                        
                        return
                    }
                    
                    userPrompt = prompt.createWithSubCommand(query.state.value, subCommands: Array(subcommands))
                } else {
                    userPrompt = prompt.create(query.state.value)
                }
                print("[SandService] Using /\(command.capitalized) \(prompt.isSystemPrompt ? "" : "(custom)") ------------- ")
                print(prompt.debugDescription)
            } else {
                if SandGPTTokenizerManager.shared.kit.tokenCount > maxTokenCount {
                    state.lastError = .init(message: "Please reduce the amount of text in order reach the token count limit. You are currently at \(SandGPTTokenizerManager.shared.kit.tokenCount)/\(maxTokenCount)")
                    
                    return
                }
                
                userPrompt = query.state.value
                
                print("[SandService] Normal Query --------------------- ")
            }
            
            //UI
            //First time response is seen
            environment
                .center
                .responseWindowSize
                .send(
                    EnvironmentService
                        .ResponseWindowSizeUpdated
                        .Meta(lineCount: 1))
            
            state.response = ""
            state.isResponding = true
            state.responseHelpers = []
            
            SandGPT.shared.reset()
            
            print("[SandService] Command for prompt: \(state.commandSet)")
            print("[SandService] Sub Command for prompt: \(state.subCommandSet?.values.compactMap { "\($0.id):\($0.value.id)" })")
            print("[SandService] Use custom config: \(config.state.customPromptConfigEnabled)")
            print("[SandService] Use System prompt: \(systemPrompt)")
            SandGPT.shared.ask(userPrompt,
                               withSystemPrompt: systemPrompt,
                               withConfig: engineeredPrompt?.config ?? .init(),
                               stream: config.state.streamResponse,
                               event: received,
                               config.state.engineClass)
        }
    }
    
    struct AskResponse: GraniteReducer {
        typealias Center = SandService.Center
        
        @Relay var environment: EnvironmentService
        @Relay var prompts: PromptService
        @Relay var query: QueryService
        @Relay var config: ConfigService
        
        @Payload var response: SandGPT.Response?
        
        func reduce(state: inout Center.State) {
            guard response?.isComplete == false else {
                print("[SandService] AskIsComplete")
                
                if response?.isStream == false,
                   let data = response?.data {
                    
                    state.response = data
                }
                
                if state.response.isNotEmpty {
                    
                    state.responseHelpers = HelperInfo.generate(from: state.response)
                    
                    //processDocument.send(payload)
//                    let doc = Document(parsing: state.response, source: nil)
                    let lineCount = 1//Int(doc.range?.upperBound.line ?? 0)
//
                    environment
                        .center
                        .responseWindowSize
                        .send(
                            EnvironmentService
                                .ResponseWindowSizeUpdated
                                .Meta(lineCount: lineCount + (lineCount > 1 ? 2 : 0),
                                      responseHelpersActive: state.responseHelpers.isEmpty == false,
                                      basedOnString: state.response))
                    
                }
                
                state.isResponding = false
                
                guard response?.isRestoring == false,
                      config.state.storeHistory else { return }
                
                config
                    .center
                    .updateHistory
                    .send(ConfigService
                        .UpdateHistory
                        .Meta(query: query.state.value,
                              response: state.response,
                              prompt: prompts.prompt(state.commandSet),
                              subCommandSet: state.subCommandSet,
                              subCommandFileSet: state.subCommandFileSet))
                
                return
            }
            
            state.response = response?.data ?? ""
            //print("[SandService] Sending: \(state.response)")
        }
    }
}
