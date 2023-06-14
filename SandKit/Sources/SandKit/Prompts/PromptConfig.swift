//
//  File.swift
//  
//
//  Created by PEXAVC on 5/14/23.
//

import Foundation

public struct PromptConfig: Equatable, Codable {
    public var temperature: Double?
    public var topP: Double?
    public var topK: Double?
    public var numberOfAnswers: Double?
    public var maximumTokens: Int?
    
    public var stream: Bool = false
    public var stop: [String]?
    public var presencePenalty: Double?
    public var frequencyPenalty: Double?
    public var logitBias: [String: Double]?
    public var user: String?
    public var systemPrompt: String?
    
    public var useTopP: Bool = false
    
    public var engine: String
    public var engineClass: String
    public var version: String
    
    public init(temperature: Double? = nil,
                topP: Double? = nil,
                topK: Double? = nil,
                numberOfAnswers: Double? = nil,
                maximumTokens: Int? = nil,
                stop: [String]? = nil,
                presencePenalty: Double? = nil,
                frequencyPenalty: Double? = nil,
                logitBias: [String: Double]? = nil,
                user: String? = nil,
                systemPrompt: String? = nil,
                engine: String = "gpt-3.5-turbo",
                engineClass: String = "open_ai",
                version: String = "1.0") {
        
        self.temperature = temperature
        self.topP = topP
        self.topK = topK
        self.numberOfAnswers = numberOfAnswers
        self.maximumTokens = maximumTokens
        self.useTopP = topP != nil
        self.stop = stop
        self.presencePenalty = presencePenalty
        self.frequencyPenalty = frequencyPenalty
        self.logitBias = logitBias
        self.user = user
        self.systemPrompt = systemPrompt
        self.engine = engine
        self.engineClass = engineClass
        self.version = version
    }
    
    public init(_ config: PromptConfig, systemPrompt: String) {
        self.temperature = config.temperature
        self.topP = config.topP
        self.topK = config.topK
        self.numberOfAnswers = config.numberOfAnswers
        self.maximumTokens = config.maximumTokens
        self.useTopP = config.useTopP
        self.stop = config.stop
        self.presencePenalty = config.presencePenalty
        self.frequencyPenalty = config.frequencyPenalty
        self.logitBias = config.logitBias
        self.user = config.user
        self.systemPrompt = systemPrompt
        self.engine = config.engine
        self.engineClass = config.engineClass
        self.version = config.version
    }
    
    var description: String {
        """
        [PromptConfig] -------------------
        temperature: \(String(describing: self.temperature)) \(self.useTopP ? "" : "(using)")
        topP: \(String(describing: self.topP)) \(self.useTopP ? "(using)" : "")
        numberOfAnswers: \(String(describing: numberOfAnswers))
        maximumTokens: \(String(describing: maximumTokens))
        -----------------------------//end
        """
    }
}
