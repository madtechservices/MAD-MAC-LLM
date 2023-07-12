import Granite
import SandKit
import Foundation
import PDFKit

extension SandService {
    struct ActivateCommands: GraniteReducer {
        typealias Center = SandService.Center
        
        @Relay var query: QueryService
        @Relay var environment: EnvironmentService
        @Relay var prompts: PromptService
        
        func reduce(state: inout Center.State) {
            guard state.commandSet == nil else { return }
            
            let isActive = state.commandAutoComplete.isNotEmpty ? false : true
            
            environment
                .center
                .commandMenuActivated
                .send(
                    EnvironmentService
                        .CommandMenuActivated
                        .Meta(isActive: isActive))
            
            SandGPTTokenizerManager.shared.pause = isActive
            
            if isActive && query.state.value.isEmpty {
                query.center.$state.binding.value.wrappedValue = "/"
            } else if isActive == false &&
                        query.center.$state.binding.value.wrappedValue.starts(with: "/") {
                query.center.$state.binding.value.wrappedValue = ""
            }
            
            if isActive {
                state.commandAutoComplete = prompts.commands
            } else {
                state.commandAutoComplete = []
            }
        }
    }
    
    struct SetCommand: GraniteReducer {
        typealias Center = SandService.Center
        
        struct Meta: GranitePayload {
            let value: String
            let reset: Bool
        }
        
        @Payload var meta: Meta?
        
        @Relay var environment: EnvironmentService
        @Relay var prompts: PromptService
        @Relay var query: QueryService
        
        func reduce(state: inout Center.State) {
            guard let meta = self.meta else { return }
            
            var commandComponents: [String] = []
            if meta.reset {
                state.commandSet = nil
            } else {
                state.commandAutoComplete = prompts.commands
                
                let components = meta.value.lowercased().components(separatedBy: " ").map { $0.newlinesSanitized }
                
                //Setup main command
                if let first = components.first,
                   let firstCommand = first.lowercased().suggestions(state.commandAutoComplete).first {
                    
                    print("[SandService] setting command: \(firstCommand)")
                    //Setup Command toolbar
                    environment
                        .center
                        .commandToolbarActivated
                        .send(
                            EnvironmentService
                                .CommandToolbarActivated
                                .Meta(isActive: meta.reset == false))
                    
                    state.commandSet = firstCommand.lowercased().replacingOccurrences(of: "/", with: "")
                    
                    commandComponents = components
                }
            }
            
            //When command menu is shown tokenizer is paused so we unpause it
            SandGPTTokenizerManager.shared.pause = false
            
            //Setup subcommands
            state.subCommandSet = [:]
            state.subCommandFileSet = [:]
            
            if commandComponents.count > 1,
               commandComponents[1].newlinesSanitized.lowercased().isEmpty == false {
                if let basic = prompts.prompt(state.commandSet) {
                    let second = commandComponents[1].newlinesSanitized.lowercased()
                   
                    let scVs = basic.subCommands.compactMap({ scV in
                        
                        var dict: [String : Any] = [:]
                        dict["subcommand"] = scV
                        dict["subcommandValue"] = scV.values.first(where: {
                            let range = $0.id.lowercased().range(of: second.lowercased())
                            
                            if let rangeCheck = range {
                                return rangeCheck.lowerBound == $0.id.startIndex
                            } else {
                                return false
                            }
                            
                        })
                        
                        return dict
                    })
                    
                    if let scV = scVs.first {
                        if let sc = scV["subcommand"] as? (any AnySubcommand),
                           let value = scV["subcommandValue"] as? SubcommandValue {
                            state.subCommandSet?[sc.id] = Prompts.subCommand(sc, scValue: value)
                            state.subCommandFileSet?[sc.id] = [:]
                        }
                    }
                }
            }
            
            //Set rest of subcommand defaults if any
            if let command = state.commandSet {
                if let basic = prompts.prompt(command) {
                    
                    for subcommand in basic.subCommands {
                        if let conditional = subcommand.subCommandConditional {
                            if state.subCommandSet?[conditional]?.value.id == subcommand.id,
                               let value = subcommand.values.first{
                                
                                state.subCommandSet?[subcommand.id] = Prompts.subCommand(subcommand, scValue: value)
                            }
                        } else if state.subCommandSet?[subcommand.id] == nil,
                           let value = subcommand.values.first {
                            state.subCommandSet?[subcommand.id] = Prompts.subCommand(subcommand, scValue: value)
                            state.subCommandFileSet?[subcommand.id] = [:]
                        }
                    }
                }
            }
            
            query.center.$state.binding.value.wrappedValue = ""
        }
    }
}

extension String {
    func suggestions(_ options: [String]) -> [String] {
        guard self.count > 1 else  { return [] }
        
        let text = self
        
        let textAfterCommand: String
        
        if text.hasPrefix("/") {
            textAfterCommand = String(text[text.index(after: text.startIndex)...])
        } else {
            textAfterCommand = text
        }

        let isUppercased: Bool = textAfterCommand.first?.isUppercase == true
       
        let suggestions: [String] = options
            .filter {
                let range = $0.lowercased().range(of: textAfterCommand.lowercased())
                
                if let rangeCheck = range {
                    return rangeCheck.lowerBound == $0.startIndex
                } else {
                    return false
                }
                
            }.map {
                if isUppercased {
                    return ("/"+$0).capitalized
                } else {
                    return ("/"+$0).lowercased()
                }
            }
        
        return suggestions
    }
}
