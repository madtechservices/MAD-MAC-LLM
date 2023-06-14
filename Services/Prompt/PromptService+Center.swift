import Granite
import SwiftUI
import SandKit

extension PromptService {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            var customPrompts: [CustomCommand : CustomPrompt] = [ : ]
        }
        
        @Event var create: Create.Reducer
        @Event var modify: Modify.Reducer
        @Event var delete: Delete.Reducer
        
        @Store(persist: "nea.persistence.prompts.0000", autoSave: true) public var state: State
    }
    
    static var normalPromptMaxTokenCount: Int {
        2000
    }
    
    static var systemPromptMaxTokenCount: Int {
        500
    }
    
    static var customPromptMaxTokenCount: Int {
        1200
    }
    
    //Entire max for engines (Should probably be in SandGPT.shared?)
    static var maxTokenCount: Int {
        4096
    }
    
    func maxTokenCount(_ command: String?) -> Int {
        if let prompt = prompt(command) {
            return prompt.maxTokens
        } else {
            return PromptService.normalPromptMaxTokenCount
        }
    }
    
    var commands: [String] {
        customCommands.map { $0.lowercased() } + systemPromptsRaw + environmentCommandsRaw
    }
    
    var customCommands: [String] {
        state.customPrompts.keys.map({ $0.value.lowercased() })
    }
    
    var systemPrompts: [Prompts] {
        Prompts.allCases
    }
    
    var environmentCommandsRaw: [String] {
        EnvironmentCommand.allCases.map { $0.command.value.lowercased() }
    }
    
    var systemPromptsRaw: [String] {
        systemPrompts.map { $0.rawValue.lowercased() }
    }
    
    func prompt(_ command: String?) -> (any BasicPrompt)? {
        guard let value = command else { return nil }
        if customCommands.contains(value.lowercased()) {
            let command: CustomCommand = .init(value.lowercased())
            return state.customPrompts[command]
        } else if let systemPrompt = Prompts.init(rawValue: value.lowercased()) {
            return Prompts.all[systemPrompt]
        } else {
            return nil
        }
    }
    
    func environmentCommand(_ command: String) -> EnvironmentCommand? {
        EnvironmentCommand(rawValue: command)
    }
}
