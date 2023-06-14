//
//  PaneKit.Visibility.swift
//  Nea
//
//  Created by PEXAVC on 5/13/23.
//

import Foundation
import Combine
import Granite
import ApplicationServices

class WindowVisibilityKit {
    @Published var isVisible: [String:Bool] = [:]
    
    public init(ids: [String]) {
        for id in ids {
            isVisible[id] = false
        }
    }
    
    public func toggle(_ id: String) {
        isVisible[id] = isVisible[id] == true ? false : true
    }
    
    public func open(_ id: String) {
        isVisible[id] = true
    }
    
    public func close(_ id: String) {
        isVisible[id] = false
    }
}

final class WindowVisibilityManager: Equatable, SharableObject {
    static func == (lhs: WindowVisibilityManager, rhs: WindowVisibilityManager) -> Bool {
        lhs.kit.isVisible == rhs.kit.isVisible
    }
    
    public static var initialValue: WindowVisibilityManager {
        .init()
    }
    
    public static var id : String = "nyc.stoic.Nea.WindowVisibilityManager"
    
    internal var cancellables = Set<AnyCancellable>()
    internal var windowNumbers = Set<Int>()
    
    let kit: WindowVisibilityKit
    
    init() {
        kit = .init(ids: InteractionManager.Kind.allCases.map { $0.rawValue })
        observe()
    }
    
    private func observe() {
        kit.$isVisible
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] newValue in
            self?.objectWillChange.send()
                
//            let showInDock = newValue.values.contains(true)
//            let transformState = showInDock ?
//                  ProcessApplicationTransformState(kProcessTransformToForegroundApplication)
//                : ProcessApplicationTransformState(kProcessTransformToUIElementApplication)
//            var psn = ProcessSerialNumber(highLongOfPSN: 0, lowLongOfPSN: UInt32(kCurrentProcess))
//
//            let transformStatus: OSStatus = TransformProcessType(&psn, transformState)
//            print("[WindowVisibility] dock state changed: \(transformStatus == 0)")
        }.store(in: &cancellables)
    }
    
    public func toggle(id: String) {
        DispatchQueue.main.async {
            self.kit.toggle(id)
        }
    }
    
    public func isVisible(id: String) -> Bool {
        kit.isVisible[id] == true
    }
    
    public func open(id: String) {
        DispatchQueue.main.async {
            self.kit.open(id)
        }
    }
    
    public func close(id: String) {
        DispatchQueue.main.async {
            self.kit.close(id)
        }
    }
    
    public func addWindowNumber(_ id: Int) {
        windowNumbers.insert(id)
    }
}
