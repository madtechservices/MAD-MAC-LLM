//
//  File.swift
//  
//
//  Created by PEXAVC on 5/5/23.
//

import Foundation
import SwiftUI

//MARK: Basic Types
public protocol BasicCommand: Identifiable {
    var value: String { get }
}

extension BasicCommand {
    public var id: String {
        value
    }
}

public struct SystemCommand: BasicCommand {
    public var value: String
}

public enum EnvironmentCommand: String, CaseIterable {
    case reset
    
    public var command: any BasicCommand {
        return SystemCommand(value: self.rawValue.lowercased())
    }
}

public protocol BasicPrompt: Equatable, Codable, Identifiable {
    var prompt: String { get }
    var iconName: String { get }
    var baseColor: Color { get }
    var description: String { get }
    var hasSubcommand: Bool { get }
    var subCommands: [any AnySubcommand] { get }
    var subCommandHelperText: String? { get }
    var isSystemPrompt: Bool { get }
    var maxTokens: Int { get }
    var promptTokenCount: Int { get }
    var config: PromptConfig { get }
    var author: PromptAuthor? { get }
    var command: any BasicCommand { get }
    var dateCreated: Date? { get }
    var dateUpdated: Date? { get }
    var version: String { get }
}

extension BasicPrompt {
    public var id: String {
        command.id
    }
    public var subCommands: [any AnySubcommand] { [] }
    public var subCommandHelperText: String? { nil }
    public var isSystemPrompt: Bool { true }
    public var maxTokens: Int {
        500
    }
    public var promptTokenCount: Int {
        500
    }
    public var config: PromptConfig {
        .init()
    }
    public var author: PromptAuthor? {
        if isSystemPrompt {
            return .init(name: "Nea")
        } else {
            return nil
        }
    }
    public var dateCreated: Date? {
        nil
    }
    public var dateUpdated: Date? {
        nil
    }
    public var version: String {
        "1.0"
    }
    
    public var debugDescription: String {
        """
        -----------[\(isSystemPrompt ? "System" : "Custom") Prompt]------------
        
        \(config.description)
        
        -------------------------------------//end
        """
    }
}

extension BasicPrompt {
    public func create(_ userPrompt: String) -> String {
        """
        A task description will be provided to run on a prompt. The prompt will be labeled with this flag, within the double quotes and after the equal sign "$user_prompt=".
        
        \(self.prompt)
        
        $user_prompt=###
        \(userPrompt)
        ###
        """
    }
    
    public func createWithSubCommand(_ userPrompt: String, subCommands: [Prompts.Subcommand]) -> String {
        
        var subcommandPrompt: String = self.prompt
        
        for sc in subCommands {
            //TODO: need to include "modifiers" as an option to subcommands so they can be added on top of subcommands that override the base prompts
            if sc.value.isSubCommandConditional == false {
                if sc.value.ignoresBasePrompt {
                    subcommandPrompt = sc.value.value
                } else {
                    subcommandPrompt = subcommandPrompt.replacingOccurrences(of: Prompts.Subcommand.key(sc.id), with: sc.value.value)
                }
                
                if sc.value.acceptsFile {
                    subcommandPrompt += """
                    \(Prompts.Subcommand.file)###
                    \(sc.value.fileContents)
                    ###
                    """
                }
            }
        }
        
        if userPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && self.isSystemPrompt == false {
            return subcommandPrompt
        } else {
            return """
            A task description will be provided to run on a prompt. The prompt will be labeled with this flag, within the double quotes and after the equal sign "$user_prompt=".
            
            \(subcommandPrompt)
            
            $user_prompt=###
            \(userPrompt)
            ###
            """
        }
    }
}

//MARK: Prompt Types
public enum Prompts: String, Equatable, Codable, CaseIterable, Identifiable {
    public var id: String {
        "\(self)"
    }
    
    case jobs
    case reword
    case summarize
    case brainstorm
    case colors
    case typefaces
    case code
    case writing
    case custom
    case empty
    
    public static var all: [Prompts: any BasicPrompt] {
        [
            .jobs: Prompts.Jobs(),
            .reword: Prompts.Reword(),
            .summarize: Prompts.Summarize(),
            .brainstorm: Prompts.Brainstorm(),
            .colors: Prompts.Colors(),
            .typefaces: Prompts.Typefaces(),
            .code: Prompts.Code(),
            .writing: Prompts.Writing(),
            .empty : Prompts.Empty()
        ]
    }
    
    public var basic: any BasicPrompt {
        Prompts.all[self] ?? Prompts.Empty()
    }
    
    static public var allCases: [Prompts] {
        [
            .jobs,
            .reword,
            .summarize,
            .brainstorm,
            .colors,
            .typefaces,
            .code,
            .writing
        ]
    }
}

extension Prompts {
    public struct Empty {
        public init(){}
    }
}

extension Prompts.Empty: BasicPrompt {
    public var prompt: String {
        ""
    }
    
    public var iconName: String {
        "questionmark.circle"
    }
    
    public var baseColor: Color {
        .init(red: 12 / 255, green: 12 / 255, blue: 12 / 255)
    }
    
    public var description: String {
        "Something wrong happened..."
    }
    
    public var hasSubcommand: Bool {
        false
    }
    
    public var command: any BasicCommand {
        SystemCommand.init(value: "")
    }
}

//MARK: Subcommands
extension Prompts {
    public struct Subcommand: Equatable, Hashable, Codable {
        public var id: String
        public var value: SubcommandValue
        
        public init(id: String,
                    value: SubcommandValue) {
            self.id = id
            self.value = value
        }
    }
}

extension Prompts.Subcommand {
    public static func key(_ id: String) -> String {
        "{$subcommand=\(id)}"
    }
    
    public static var file: String {
        "$user_file="
    }
}

extension Prompts {
    public static func subCommand(_ sc: any AnySubcommand, scValue: SubcommandValue) -> Prompts.Subcommand {
        .init(id: sc.id, value: scValue)
    }
}

extension BasicPrompt {
    public func subcommandFor(id: String) -> (any AnySubcommand)? {
        self.subCommands.first(where: { $0.id == id })
    }
}

public protocol AnySubcommand: Identifiable, Equatable, Codable {
    var id: String { get }
    var subCommandConditional: String? { get }
    var values: [SubcommandValue] { get }
}

extension AnySubcommand {
    public var subCommandConditional: String? { nil }
    
    var keyedValues: [SubcommandValue:String] {
        var dict: [SubcommandValue:String] = [:]
        for value in self.values {
            dict[value] = id
        }
        return dict
    }
}

public struct SubcommandValue: Equatable, Identifiable, Hashable, Codable {
    public var id: String
    public var value: String
    public var isSubCommandConditional: Bool = false
    public var acceptsFile: Bool = false
    public var ignoresBasePrompt: Bool = false
    public var acceptedFileExtensions: [String] = []
    public var additionalHelperText: String? = nil
    public var fileMaxTokenCount: Int = SubcommandValue.defaultMaxTokenCount
    public var fileDescription: String = ""
    
    //TODO: Should be able to accept anything. Maybe DATA object?
    public var fileContents: String = ""
    
    mutating public func updateFileContents(_ contents: String) {
        fileContents = contents
    }
    
    public static var defaultMaxTokenCount: Int {
        1200
    }
}
