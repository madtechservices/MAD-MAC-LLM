//
//  SandGPT.swift
//  Nea
//
//  Created by PEXAVC on 5/9/23.
//

import Foundation
import SandKit
import Combine
import Granite
import GPT3_Tokenizer

class SandGPT {
    static let shared: SandGPT = .init()
    
    @SharedObject(SessionManager.id) var session: SessionManager
    
    //OpenAI - Front-end use for client to customize api key without hardcoding
    var CUSTOM_API_KEY: String? = nil {
        didSet {
            session.isCustomAPI(CUSTOM_API_KEY != nil)
        }
    }
    
    //OpenAI
    static var API_KEY: String {
        ""
    }
    
    //Bard (WIP)
    static var GOOGLE_API_KEY: String {
        ""
    }
    
    static var AZURE_CONFIG: ChatGPTAzure.Config {
        .init(apiKey: "",
              resourceName: "",
              deploymentName: "")
    }
    
    static var DEFAULT_ENGINE: String {
        "gpt-3.5-turbo"
    }
    
    private var client: ChatGPT? = nil
    private var clientAzure: ChatGPTAzure? = nil
    
    private var lastEngineUsed: String = ""
    
    let gpt3Tokenizer = GPT3Tokenizer()
    
    private var currentTask: SandTask? = nil
    private var reqDebounceTimer: Timer? = nil
    private var replyCompletedTimer: Timer? = nil
    
    @Published var isResponding: Bool = false
    
    func ask<E: EventExecutable>(_ prompt: String,
                                 withSystemPrompt systemPrompt: String? = nil,
                                 withConfig config: PromptConfig,
                                 stream: Bool = false,
                                 event: E,
                                 _ engineClass: APITYPE = .openai) {
        print("[SandGPT] prompt token count: \(prompt.components(separatedBy: " ").count)")
        
        guard prompt.isNotEmpty else { return }
        
        if lastEngineUsed != config.engine {
            useCustomEngine(config.engine)
        }
        
        currentTask?.cancel()
        currentTask = .init()
        isResponding = true
        
        print("[SandGPT] creating Debounce Timer")
        
        reqDebounceTimer?.invalidate()
        reqDebounceTimer = Timer.scheduledTimer(
            withTimeInterval: 0.8.randomBetween(1.2),
            repeats: false) { [weak self] timer in
                
                print("[SandGPT] invalidating timer")
                
                timer.invalidate()
                
                print("[SandGPT] creatingTask")
                
                if stream {
                    self?.updateCompletedTimer(event)
                }
                
                self?.currentTask?.task = Task {
                    
                    var reply: String = ""
                    
                    if stream && engineClass == .openai,
                       let client = self?.client {
                        var replyDebouncerInit: CGFloat = CFAbsoluteTimeGetCurrent()
                        for try await nextWord in try await client
                            .streamedAnswer.ask(prompt,
                                                withSystemPrompt: systemPrompt,
                                                withConfig: config) {
                            
                            SandGPT.shared.updateCompletedTimer(event)
                            
                            reply += nextWord
                            
                            //print("[SandGPT] streaming // nextWord: \(nextWord)")
                            
                            if CFAbsoluteTimeGetCurrent() - replyDebouncerInit >= 0.24 {
                                replyDebouncerInit = CFAbsoluteTimeGetCurrent()
                                event.send(Response(data: reply, isComplete: false, isStream: true))
                            }
                        }
                    } else {
                        
                        switch engineClass {
                        case .openai:
                            reply = (try await self?.client?.ask(prompt, withSystemPrompt: systemPrompt, withConfig: config)) ?? ""
                        case .azure:
                            reply = (try await self?.clientAzure?.ask(prompt, withSystemPrompt: systemPrompt, withConfig: config)) ?? ""
                        }
                        
                        DispatchQueue.main.async { [weak self] in
                            self?.isResponding = false
                        }
                        
                        event.send(Response(data: reply, isComplete: true, isStream: false))
                    }
                }
            }
    }
    
    func updateCompletedTimer<E: EventExecutable>(_ event: E) {
        DispatchQueue.main.async { [weak self] in
            self?.replyCompletedTimer?.invalidate()
            self?.replyCompletedTimer = Timer.scheduledTimer(
                withTimeInterval: 2.4,
                repeats: false) { completedTimer in
                    
                    print("[SandGPT] stream isComplete")
                    
                    completedTimer.invalidate()
                    DispatchQueue.main.async { [weak self] in
                        self?.isResponding = false
                    }
                    event.send(Response(data: nil, isComplete: true, isStream: true))
                }
        }
    }
    
    func reset() {
        self.currentTask?.cancel()
        self.reqDebounceTimer?.invalidate()
        self.replyCompletedTimer?.invalidate()
        self.isResponding = false
    }
    
    struct Response: GranitePayload {
        var data: String?
        var isComplete: Bool
        var isStream: Bool
        var isRestoring: Bool = false
    }
}

extension SandGPT {
    func setup() {
        //Setup OpenAI
        self.client = ChatGPT(apiKey: SandGPT.API_KEY, defaultModel: .custom(modelId: SandGPT.DEFAULT_ENGINE))
        self.lastEngineUsed = SandGPT.DEFAULT_ENGINE
        
        //Setup Azure
        self.clientAzure = ChatGPTAzure(config: SandGPT.AZURE_CONFIG)
    }
    
    //TODO: Clean up, setup seperate client for custom do not replace main client
    func useCustomAPI() {
        print("[SandGPT] Using custom API \(CUSTOM_API_KEY != nil)")
        guard let customAPIKey = self.CUSTOM_API_KEY else { return }
        
        self.client = ChatGPT(apiKey: customAPIKey,
                              defaultModel: .custom(modelId: SandGPT.DEFAULT_ENGINE))
        self.lastEngineUsed = SandGPT.DEFAULT_ENGINE
    }
    
    //TODO: Clean up
    func useCustomEngine(_ engine: String) {
        print("[SandGPT] Using custom API w/ Custom Engine \(CUSTOM_API_KEY != nil)")
        guard let customAPIKey = self.CUSTOM_API_KEY else { return }
        
        self.client = ChatGPT(apiKey: customAPIKey, defaultModel: .custom(modelId: engine))
        self.lastEngineUsed = engine
    }
    
    //TODO: Clean up
    func useMainAPI() {
        print("[SandGPT] Using main API \(CUSTOM_API_KEY == nil)")
        
        self.client = ChatGPT(apiKey: SandGPT.API_KEY, defaultModel: .custom(modelId: SandGPT.DEFAULT_ENGINE))
        self.lastEngineUsed = SandGPT.DEFAULT_ENGINE
    }
}
