//
//  CustomPrompt.swift
//  Nea
//
//  Created by PEXAVC on 5/13/23.
//

import Foundation
import Granite
import SandKit
import SwiftUI

struct CustomCommand: BasicCommand, GraniteModel, Hashable {
    var value: String
    
    init(_ command: String) {
        
        self.value = command
    }
}

struct CustomPrompt: GraniteModel, BasicPrompt, Identifiable {
    var id: String {
        customCommand.value
    }
    
    var customCommand: CustomCommand
    var prompt: String
    var iconName: String
    var baseColorHex: String
    var description: String
    var dateCreated: Date?
    var dateUpdated: Date?
    var creativity: Double?
    var role: String
    var tokenCount: Int
    var customConfig: PromptConfig?
    var author: PromptAuthor?
    
    var config: PromptConfig {
        if let customCGF = customConfig,
           role.isNotEmpty {
            return .init(customCGF, systemPrompt: role)
        } else {
            return customConfig ?? .init(temperature: creativity,
                                         systemPrompt: role.isEmpty ? nil : role)
        }
    }
    
    var command: any BasicCommand {
        customCommand
    }
    
    var hasSubcommand: Bool {
        false
    }
    
    var promptTokenCount: Int {
        tokenCount
    }
    
    var maxTokens: Int {
        if let configTokenCount = customConfig?.maximumTokens {
            let tokensLeft = configTokenCount - (promptTokenCount + 240) //240 reserved for the system
            return tokensLeft
        } else {
            let tokensLeft = PromptService.maxTokenCount - (promptTokenCount + 240) //240 reserved for the system
            return tokensLeft
        }
        //PromptService.customPromptMaxTokenCount - promptTokenCount
    }
    
    var version: String {
        "1.0"
    }
    
    init(_ command: CustomCommand,
         prompt: String,
         iconName: String,
         baseColorHex: String,
         description: String,
         creativity: Double?,
         role: String,
         tokenCount: Int,
         dateUpdated: Date? = nil,
         customConfig: PromptConfig?) {
        
        self.customCommand = command
        self.prompt = prompt
        self.iconName = iconName
        self.baseColorHex = baseColorHex
        self.description = description
        self.dateCreated = .init()
        self.dateUpdated = dateUpdated
        self.creativity = creativity
        self.role = role
        self.tokenCount = tokenCount
        self.customConfig = customConfig
    }
}

extension CustomPrompt {
    var baseColor: Color {
        .init(hex: baseColorHex)
    }
    
    public var isSystemPrompt: Bool { false }
}
