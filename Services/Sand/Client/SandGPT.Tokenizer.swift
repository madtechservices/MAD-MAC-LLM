//
//  SandGPT.Tokenizer.swift
//  Nea
//
//  Created by PEXAVC on 5/13/23.
//

import Foundation
import Combine

//TODO: is this still needed? Seems as though independant instances were focused on
class SandGPTTokenizerKit {
    @Published var tokenCount: Int = 0
    
    let operationQueue: OperationQueue = .init()
    
    init() {
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.qualityOfService = .userInteractive
    }
    
    func update(_ query: String) {
        guard query.isNotEmpty else {
            tokenCount = 0
            return
        }
        
        operationQueue.addOperation {
            DispatchQueue.main.async {
                self.tokenCount = SandGPT.shared.gpt3Tokenizer.encoder.enconde(text: query).count
            }
        }
    }
}

//TODO: is this still needed? Seems as though independant instances were focused on
class SandGPTTokenizerManager: ObservableObject {
    static let shared: SandGPTTokenizerManager = .init()
    internal var cancellables = Set<AnyCancellable>()
    
    let kit: SandGPTTokenizerKit
    
    @Published var tokenCount: Int = 0
    @Published var pause: Bool = false
    
    init() {
        kit = .init()
        observe()
    }
    
    private func observe() {
        kit.$tokenCount
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] newValue in
            self?.tokenCount = newValue
            guard SandGPTTokenizerManager.shared.pause == false else { return }
            self?.objectWillChange.send()
        }.store(in: &cancellables)
    }
    
    public static func update(_ query: String) {
        guard SandGPTTokenizerManager.shared.pause == false else { return }
        SandGPTTokenizerManager.shared.kit.update(query)
    }
    
    public static var tokenCount: Int {
        SandGPTTokenizerManager.shared.tokenCount
    }
}
