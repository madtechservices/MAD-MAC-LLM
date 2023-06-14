//
//  File.swift
//  
//
//  Created by PEXAVC on 5/7/23.
//

import Foundation
import SwiftUI

extension Prompts {
    public struct Brainstorm {
        public init(){}
    }
}

extension Prompts.Brainstorm: BasicPrompt {
    public var prompt: String {
        """
        Provide some ideas about a topic that will be within this subject matter, {$subcommand=subject}.
        
        These ideas should help facilitate and jumpstart the creative process.
        
        Provide a helpful roadmap in how one can help themselves get to the creation phase of the idea.
        
        An audience can be any demographic of your choosing depending on the subject matter.
        
        Use the H3 markdown when labeling audiences and put suggestions in markdown blockquote.
        """
    }
    
    public var iconName: String {
        "brain.head.profile"
    }
    
    public var baseColor: Color {
        .init(red: 196 / 255, green: 136 / 255, blue: 255 / 255)
    }
    
    public var description: String {
        "Brainstorm ideas on anything, maybe on building something new..."
    }
    
    public var hasSubcommand: Bool {
        true
    }
    
    public var subCommandHelperText: String? {
        "Describe your idea or general topics around it here"
    }
    
    public var config: PromptConfig {
        .init(temperature: 0.7)
    }
    
    public var command: any BasicCommand {
        SystemCommand(value: Prompts.brainstorm.rawValue.lowercased())
    }
}

extension Prompts.Brainstorm {
    public var subCommands: [any AnySubcommand] {
        [
            SubjectSubcommand()
        ]
    }
    
    public struct SubjectSubcommand: AnySubcommand {
        public var id: String {
            "subject"
        }
        
        public var values: [SubcommandValue] {
            [
                .init(id: "writing", value: "writing"),
                .init(id: "product", value: "product development"),
                .init(id: "music", value: "music or composition"),
                .init(id: "speeches", value: "speech writing"),
                .init(id: "cooking", value: "cooking"),
                .init(id: "mixology", value: "mixology"),
                .init(id: "teaching", value: "teaching or lesson plans")
            ]
        }
    }
}
