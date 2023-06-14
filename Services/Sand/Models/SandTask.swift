//
//  SandTask.swift
//  Nea
//
//  Created by PEXAVC on 5/8/23.
//

import Granite
import Foundation
import SwiftUI
import Combine

class SandTask: GraniteModel {
    static func == (lhs: SandTask, rhs: SandTask) -> Bool {
        lhs.id == rhs.id
    }
    
    var id: UUID = .init()
    var notifier: (() -> Void)?
    var task: Task<(), Error>? = nil {
        didSet {
            isStarting = true
            lastUpdate = .init()
        }
    }
    
    private(set) var lastUpdate: Date = .init()
    private(set) var isStarting: Bool = false
    private var timerCancellable: AnyCancellable? = nil
    
    init(id: UUID = .init()) {
        self.id = id
    }
    
    
    enum CodingKeys: CodingKey {
        case id
        case isStarting
        case lastUpdate
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(id, forKey: .id)
        try? container.encode(isStarting, forKey: .isStarting)
        try? container.encode(lastUpdate, forKey: .lastUpdate)
    }
    
    public required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try? container.decode(UUID.self, forKey: .id)
        let isStarting = try? container.decode(Bool.self, forKey: .isStarting)
        let lastUpdate = try? container.decode(Date.self, forKey: .lastUpdate)
        
        self.init(id: id ?? .init())
        self.lastUpdate = lastUpdate ?? self.lastUpdate
        self.isStarting = isStarting ?? false
    }
}

extension SandTask {
    public func attach<S: EventExecutable>(_ expedition: S) {
        self.notifier = {
            expedition.send()
        }
        lastUpdate = .init()
    }
    
    public func cancel() {
        task?.cancel()
        timerCancellable?.cancel()
    }
    
    public func cancelDelay() {
        isStarting = false
        lastUpdate = .init()
        timerCancellable?.cancel()
    }
}
