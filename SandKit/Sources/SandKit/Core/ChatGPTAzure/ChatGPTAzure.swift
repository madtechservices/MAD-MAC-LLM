//
//  ChatGPTAzure.swift
//  
//
//  Created by PEXAVC on 6/14/23.
//

import Foundation

/// A simple and easy to use wrapper around the ChatGPT API from OpenAI, with support for GPT 3.5 turbo as well as GPT 4 and its large context variant.
public class ChatGPTAzure {
    public struct Config {
        var apiKey: String
        var apiVersion: String
        var resourceName: String
        var deploymentName: String
        
        public init(apiKey: String,
                    apiVersion: String = "2023-05-15",
                    resourceName: String,
                    deploymentName: String) {
            self.apiKey = apiKey
            self.apiVersion = apiVersion
            self.resourceName = resourceName
            self.deploymentName = deploymentName
        }
    }

    private let client: APIClient
    private let config: Config
    
    private let api: APITYPE = .azure
    private let apiClientRequestHandler: _APIClientRequestHandler

    /// A simple and easy to use wrapper around the ChatGPT API from OpenAI, with support for GPT 3.5 turbo as well as GPT 4 and its large context variant.
    ///
    /// - Parameter properties: Azure config properties
    /// - Parameter urlSessionConfiguration: An optional URL session configuration object.
    public init(
        config: Config,
        urlSessionConfiguration: URLSessionConfiguration? = nil
    ) {
        self.config = config
        self.apiClientRequestHandler = .init(apiKey: config.apiKey)
        
        let path: String = config.base
        
        self.client = APIClient(baseURL: URL(string: path)) { [apiClientRequestHandler] configuration in
            configuration.delegate = apiClientRequestHandler
            if let urlSessionConfiguration {
                configuration.sessionConfiguration = urlSessionConfiguration
            }
        }
    }

    /// Ask ChatGPT a single prompt without any special configuration.
    /// - Parameter userPrompt: The prompt to send
    /// - Parameter systemPrompt: an optional system prompt to give GPT instructions on how to answer.
    /// - Returns: The response as string.
    /// - Throws: A `GPTSwiftError` if the request fails or the server returns an unauthorized status code.
    public func ask(
        _ userPrompt: String,
        withSystemPrompt systemPrompt: String? = nil,
        withConfig config: PromptConfig
    ) async throws -> String {
        var messages: [ChatMessage] = []

        if let systemPrompt {
            messages.insert(.init(role: .system, content: systemPrompt), at: 0)
        }

        messages.append(.init(role: .user, content: userPrompt))

        let path: String = self.config.chatCompletion
        
        let request = Request<ChatResponse>(
            path: path,
            method: .post,
            query: [("api-version", self.config.apiVersion)],
            body: ChatRequestAzure(messages: messages, config: config)
        )
        
        print("[ChatGPTAzure] asking without messages.")

        let response = try await send(request: request)
        guard let answer = response.choices.first?.message.content else {
            throw GPTSwiftError.responseParsingFailed
        }

        return answer
    }

    /// Ask ChatGPT something by sending multiple messages without any special configuration.
    /// - Parameter messages: The chat messages.
    /// - Parameter config: Prompt parameters
    /// - Returns: The response as string.
    /// - Throws: A `GPTSwiftError` if the request fails or the server returns an unauthorized status code.
    public func askWithMessages(
        messages: [ChatMessage],
        withConfig config: PromptConfig
    ) async throws -> String {
        
        let path: String = AZURE_API.v1ChatCompletion
        
        let request = Request<ChatResponse>(
            path: path,
            method: .post,
            query: [("api-version", self.config.apiVersion)],
            body: ChatRequestAzure(messages: messages)
        )
        print("[ChatGPTAzure] asking with messages.")

        let response = try await send(request: request)
        guard let answer = response.choices.first?.message.content else {
            throw GPTSwiftError.responseParsingFailed
        }

        return answer
    }

    /// Sends the request, catches all errors and replaces them with a `GPTSwiftError`. If successful, it returns the response value.
    /// - Parameter request: The request to send.
    /// - Returns: The response object, already decoded.
    private func send<Response: Codable>(request: Request<Response>) async throws -> Response {
        do {
            return try await client.send(request).value
        } catch {
            throw _errorToGPTSwiftError(error)
        }
    }
}

extension ChatGPTAzure.Config {
    var base: String {
        "https://\(self.resourceName).openai.azure.com"
    }
    
    var chatCompletion: String {
        "openai/deployments/\(self.deploymentName)/chat/completions"
    }
    
    var completion: String {
        "openai/deployments/\(self.completion)/completions"
    }
}
