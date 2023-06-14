//
//  File.swift
//  
//
//  Created by PEXAVC on 5/7/23.
//

import Foundation
import SwiftUI

extension Prompts {
    public struct Colors {
        public init(){}
    }
}

extension Prompts.Colors: BasicPrompt {
    public var prompt: String {
        """
        """
    }
    
    public var iconName: String {
        "paintpalette"
    }
    
    public var baseColor: Color {
        .init(red: 220 / 255, green: 104 / 255, blue: 155 / 255)
    }
    
    public var description: String {
        "Generate complimentary colors or describe the palette of a scene..."
    }
    
    public var hasSubcommand: Bool {
        true
    }
    
    public var subCommandHelperText: String? {
        ""
    }
    
    public var config: PromptConfig {
        .init(temperature: 0.75,
              systemPrompt: "Act like a Designer")
    }
    
    public var command: any BasicCommand {
        SystemCommand(value: Prompts.colors.rawValue.lowercased())
    }
}

extension Prompts.Colors {
    public var subCommands: [any AnySubcommand] {
        [
            ComparisonSubcommand()
        ]
    }
    
    public struct ComparisonSubcommand: AnySubcommand {
        public var id: String {
            "comparison"
        }
        
        /* Notes
         - Analogous, Triadic, Complimentary
         
         */
        
        public var values: [SubcommandValue] {
            [
                .init(id: "shades",
                      value: """
                        Provide complimentary shades for the color in the user_prompt. The prompt could share a color by Name, HSL, HSV, RGB, AND HEX. HEX must be provided at least. Label it with their respective type.
                        
                        Label each suggestion of a complimentary shade with markdown.
                        
                        DO NOT share previews of the colors only share the Name, HSL, HSV, RGB, AND HEX.
                        """,
                     ignoresBasePrompt: true,
                     additionalHelperText: "Name a color and see suggestions"),
                .init(id: "scenes",
                      value: """
                        Provide some list of colors that are related to the scene in the user_prompt. When providing the color suggestion, provide the HSL, HSV, RGB, AND HEX. HEX must be provided at least. Label it with their respective type.
                        
                        Label each suggestion with markdown.
                        """,
                      ignoresBasePrompt: true,
                      additionalHelperText: "The color palette of a New York summer night...")
            ]
        }
    }
}
