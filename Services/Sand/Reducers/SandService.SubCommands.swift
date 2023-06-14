//
//  SandService.SubCommands.swift
//  Nea
//
//  Created by PEXAVC on 5/14/23.
//
import Granite
import SandKit
import Foundation

extension SandService {
    struct SetSubCommand: GraniteReducer {
        typealias Center = SandService.Center
        
        struct Meta: GranitePayload {
            let id: String
            let subcommandValueId: String
        }
        
        @Payload var meta: Meta?
        
        @Relay var prompts: PromptService
        
        func reduce(state: inout Center.State) {
            guard let meta = self.meta else { return }
            
            if let command = state.commandSet {
                if let basic = prompts.prompt(command) {
                    for subcommand in basic.subCommands {
                        if let value = subcommand.values.first(where: { $0.id == meta.subcommandValueId }) {
                            state.subCommandSet?[meta.id] = Prompts.subCommand(subcommand, scValue: value)
                        }
                        
                        if let conditional = subcommand.subCommandConditional,
                           meta.id != subcommand.id {
                            if state.subCommandSet?[conditional]?.value.id != subcommand.id {
                                
                                print("[SandService] Remove subcommand")
                                state.subCommandSet?[subcommand.id] = nil
                            } else if let value = subcommand.values.first {
                                print("[SandService] Add subcommand")
                                state.subCommandSet?[subcommand.id] = Prompts.subCommand(subcommand, scValue: value)
                            }
                        }
                    }
                }
            }
        }
    }
    
    struct SetSubCommandFile: GraniteReducer {
        typealias Center = SandService.Center
        
        struct Meta: GranitePayload {
            let id: String
            let subcommandValueId: String
            let fileURL: URL
            let contents: String?
        }
        
        @Payload var meta: Meta?
        
        func reduce(state: inout Center.State) {
            guard let meta = self.meta else { return }
            
            state.subCommandFileSet?[meta.id]?[meta.subcommandValueId] = meta.fileURL.absoluteString
            
            //TODO: should be "smarter"
            if let scv = state.subCommandSet?[meta.id],
               scv.value.acceptsFile {
                
                var value = scv.value
                
                if let contents = meta.contents {
                    value.updateFileContents(contents)
                    state.subCommandSet?[meta.id] = Prompts.Subcommand(id: scv.id, value: value)
                } else if scv.value.acceptedFileExtensions.contains(meta.fileURL.pathExtension.lowercased()) {
                    
                    let processor: FileProcessor = .init()
                    processor.process(meta.fileURL)
                    value.updateFileContents(processor.documentContents)
                    state.subCommandSet?[meta.id] = Prompts.Subcommand(id: scv.id, value: value)
                } else {
                    print("[SandService] [SetSCVFile] file not supported")
                }
            } else {
                print("[SandService] [SetSCVFile] set command is nil? \(state.subCommandSet?[meta.id] == nil)")
            }
        }
    }
    
    struct SetSubCommandFileContents: GraniteReducer {
        typealias Center = SandService.Center
        
        struct Meta: GranitePayload {
            let id: String
            let subcommandValueId: String
            let contents: String
        }
        
        @Payload var meta: Meta?
        
        func reduce(state: inout Center.State) {
            guard let meta = self.meta else { return }
            
            state.subCommandFileSet?[meta.id]?[meta.subcommandValueId] = "Text"
            
            //TODO: should be "smarter"
            if let scv = state.subCommandSet?[meta.id],
               scv.value.acceptsFile {
                
                var value = scv.value
                
                value.updateFileContents(meta.contents)
                state.subCommandSet?[meta.id] = Prompts.Subcommand(id: scv.id, value: value)
            } else {
                print("[SandService] [SetSCVFile] set command is nil? \(state.subCommandSet?[meta.id] == nil)")
            }
        }
    }
}
