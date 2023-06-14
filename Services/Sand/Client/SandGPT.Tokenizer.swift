//
//  SandGPT.Tokenizer.swift
//  Nea
//
//  Created by PEXAVC on 5/13/23.
//

import Foundation
import Combine

class SandGPTTokenizerKit {
    @Published var tokenCount: Int = 0
    
    func update(_ query: String) {
        guard query.isNotEmpty else {
            tokenCount = 0
            return
        }
        tokenCount = SandGPT.shared.gpt3Tokenizer.encoder.enconde(text: query).count
    }
}

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
        DispatchQueue.global(qos: .utility).async {
            SandGPTTokenizerManager.shared.kit.update(query)
        }
    }
    
    public static var tokenCount: Int {
        SandGPTTokenizerManager.shared.tokenCount
    }
}
