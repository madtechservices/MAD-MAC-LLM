//
//  File.swift
//  
//
//  Created by PEXAVC on 5/5/23.
//

import Foundation
import SwiftUI

extension Prompts {
    public struct Code {
        public init(){}
    }
}

extension Prompts.Code: BasicPrompt {
    public var prompt: String {
        """
        Provide sample code in this programming language {$subcommand=language}.
        
        It will most likely be about a UI element or a user-experience. Only provide the code sample.
        
        The code example must be in a code block. Markdown style the code sample in a code block.
        
        Provide any other libraries, third party or first party that could be helpful in solving the problem given by the prompt. Label them with headlines and explain why in 1 sentence.
        """
    }
    
    public var iconName: String {
        "chevron.left.forwardslash.chevron.right"
    }
    
    public var baseColor: Color {
        .init(red: 170 / 255, green: 243 / 255, blue: 228 / 255)
    }
    
    public var description: String {
        "Pick a language, type your problem or UI element, see a snippet..."
    }
    
    public var hasSubcommand: Bool {
        true
    }
    
    public var subCommandHelperText: String? {
        "Describe the UI/UX of the code snippet you'd like here"
    }
    
    public var config: PromptConfig {
        .init(temperature: 0.2,
              systemPrompt: "Act like a Senior Level Engineer")
    }
    
    public var command: any BasicCommand {
        SystemCommand(value: Prompts.code.rawValue.lowercased())
    }
}

extension Prompts.Code {
    public var subCommands: [any AnySubcommand] {
        [
            LanguageSubcommand()
        ]
    }
    
    public struct LanguageSubcommand: AnySubcommand {
        public var id: String {
            "language"
        }
        
        public var values: [SubcommandValue] {
            [
                .init(id: "swiftui", value: "swiftui"),
                .init(id: "swift-uikit", value: "swift-uikit"),
                .init(id: "objective-c", value: "objective-c"),
                .init(id: "c++", value: "c++"),
                .init(id: "java", value: "java"),
                .init(id: "c#", value: "c-sharp / c#"),
                .init(id: "javascript", value: "javascript"),
                .init(id: "html", value: "html"),
                .init(id: "php", value: "php"),
                .init(id: "java", value: "java"),
                .init(id: "flutter", value: "flutter")
            ]
        }
    }
}
