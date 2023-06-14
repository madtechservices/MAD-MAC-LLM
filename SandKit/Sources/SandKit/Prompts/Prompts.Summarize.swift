//
//  File.swift
//  
//
//  Created by PEXAVC on 5/7/23.
//

import Foundation
import SwiftUI

extension Prompts {
    public struct Summarize {
        public init(){}
    }
}

extension Prompts.Summarize: BasicPrompt {
    public var prompt: String {
        """
        Provide a suggestion on how to summarize this in {$subcommand=wordcount}.

        1 suggestion that diversifies the words and grammar. Stick to the subject matter and eloquently shares the same message as the original.

        Provide a simple reasoning for the suggestion. The reasoning should not be more than 4 sentences.
        
        """
    }
    
    public var iconName: String {
        "doc"
    }
    
    public var baseColor: Color {
        .init(red: 255 / 255, green: 136 / 255, blue: 204 / 255)
    }
    
    public var description: String {
        "Summarize any text into the length of your choosing..."
    }
    
    public var hasSubcommand: Bool {
        true
    }
    
    public var subCommandHelperText: String? {
        "Paste something to summarize here"
    }
    
    public var command: any BasicCommand {
        SystemCommand(value: Prompts.summarize.rawValue.lowercased())
    }
}

extension Prompts.Summarize {
    public var subCommands: [any AnySubcommand] {
        [
            WordCountSubcommand()
        ]
    }
    
    public struct WordCountSubcommand: AnySubcommand {
        public var id: String {
            "wordcount"
        }
        
        public var values: [SubcommandValue] {
            [
                .init(id: "60 words", value: "60 words or less"),
                .init(id: "120 words", value: "120 words or less"),
                .init(id: "300 words", value: "300 words or less"),
                .init(id: "400 words", value: "400 words or less"),
                .init(id: "500 words", value: "500 words or less"),
                .init(id: "600 words", value: "600 words or less")
            ]
        }
    }
}
