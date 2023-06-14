//
//  File.swift
//  
//
//  Created by PEXAVC on 5/16/23.
//

import Foundation
import SwiftUI

extension Prompts {
    public struct Writing {
        public init(){}
    }
}

extension Prompts.Writing: BasicPrompt {
    public var prompt: String {
        """
        Provide a writing suggestion in {$subcommand=wordcount} words or less.

        The content is a {$subcommand=subject}
        
        The user_prompt will have the subject to begin writing about.
        
        Provide 1 example suggestion.

        Provide a simple reasoning for the example. The reasoning should not be more than 4 sentences.
        """
    }
    
    public var iconName: String {
        "pencil.tip"
    }
    
    public var baseColor: Color {
        .init(red: 103 / 255, green: 225 / 255, blue: 253 / 255)
    }
    
    public var description: String {
        "Ideas on how to write or begin to write something..."
    }
    
    public var hasSubcommand: Bool {
        true
    }
    
    public var subCommandHelperText: String? {
        "Describe what you want written here"
    }
    
    public var config: PromptConfig {
        .init(temperature: 0.66,
              systemPrompt: "Act as a prolific and famous writer/author.")
    }
    
    public var command: any BasicCommand {
        SystemCommand(value: Prompts.writing.rawValue.lowercased())
    }
}

extension Prompts.Writing {
    public var subCommands: [any AnySubcommand] {
        [
            SubjectSubcommand(),
            WordCountSubcommand()
        ]
    }
    
    public struct WordCountSubcommand: AnySubcommand {
        public var id: String {
            "wordcount"
        }
        
        public var values: [SubcommandValue] {
            [
                .init(id: "24 words", value: "60 words or less"),
                .init(id: "48 words", value: "120 words or less"),
                .init(id: "120 words", value: "300 words or less"),
                .init(id: "300 words", value: "400 words or less"),
                .init(id: "500 words", value: "500 words or less"),
                .init(id: "600 words", value: "600 words or less")
            ]
        }
    }
    
    public struct SubjectSubcommand: AnySubcommand {
        public var id: String {
            "subject"
        }
        
        public var values: [SubcommandValue] {
            [
                .init(id: "product", value: "product description"),
                .init(id: "intros", value: "introduction into an essay"),
                .init(id: "endings", value: "conclusion of an essay"),
                .init(id: "blog", value: "blog post"),
                .init(id: "social", value: "social media post"),
                .init(id: "article", value: "news article")
            ]
        }
    }
}
