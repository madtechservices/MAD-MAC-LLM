//
//  File.swift
//
//
//  Created by PEXAVC on 5/7/23.
//

import Foundation
import SwiftUI

extension Prompts {
    public struct Typefaces {
        public init(){}
    }
}

extension Prompts.Typefaces: BasicPrompt {
    public var prompt: String {
        """
        Provide typefaces/font suggestions for the product described in the user_prompt. The response should share a method of how to import the typefaces in CSS.
        
        The typeface suggestions should be free. And each suggestion or font-family name should be clearely labelled with "font-family".
        """
    }
    
    public var iconName: String {
        "textformat.size"
    }
    
    public var baseColor: Color {
        .init(red: 110 / 255, green: 87 / 255, blue: 78 / 255)
    }
    
    public var description: String {
        "Generate typeface/font suggestions for a website or product..."
    }
    
    public var hasSubcommand: Bool {
        false
    }
    
    public var subCommandHelperText: String? {
        "What would you like typeface suggestions about.."
    }
    
    public var config: PromptConfig {
        .init(temperature: 0.75,
              systemPrompt: "Act like a Designer")
    }
    
    public var command: any BasicCommand {
        SystemCommand(value: Prompts.typefaces.rawValue.lowercased())
    }
}
