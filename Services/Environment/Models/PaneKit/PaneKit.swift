//
//  PaneKit.swift
//  Nea
//
//  Created by PEXAVC on 5/8/23.
//

import Foundation
import Combine
import SwiftUI

class PaneKit<Content: View>: Equatable, Codable, ObservableObject {
    static func == (lhs: PaneKit, rhs: PaneKit) -> Bool {
        lhs.id == rhs.id &&
        lhs.componentStorage == rhs.componentStorage &&
        lhs.lastUpdate == rhs.lastUpdate
    }
    
    private(set) var isPrepared: Bool = false
    private var requiresUpdate: Bool = false
    internal var cancellables = Set<AnyCancellable>()
    
    internal var componentStorage: [WindowComponent : CGSize] = [ : ]
    
    let id: String
    let window: PaneKit.Window
    let defaultSize: CGSize
    let content: () -> Content
    internal var lastUpdate: Date
    private var activePopover: NSPopover? = nil
    
    init(id: String,
         defaultSize: CGSize,
         useMain: Bool = false,
         lastUpdate: Date = .init(),
         @ViewBuilder content : (@escaping () -> Content)) {
        self.id = id
        window = .init(id: id,
                       useMain: useMain,
                       size: defaultSize,
                       maxSize: WindowComponent.Style.maxWindowSize)
        self.defaultSize = defaultSize
        self.content = content
        self.lastUpdate = lastUpdate
    }
    
    func build(title: String? = nil, center: Bool = false) {
        if window.isPrepared == false {
            window.$isPrepared.removeDuplicates()
                .receive(on: RunLoop.main)
                .sink { [weak self] state in
                    self?.isPrepared = state
                    
                    self?.host()
                    
                    if self?.requiresUpdate == true {
                        //Post update needs
                        self?.requiresUpdate = false
                    }
            }.store(in: &cancellables)
            window.build(title: title, center: center)
        } else {
            self.isPrepared = true
        }
    }
    
    private func host() {
        window.setHost(NSHostingController(rootView: content()))
    }
    
    func toggleWindow() {
        window.toggle()
    }
    
    func bringToFront() {
        window.bringToFront()
    }
    
    func showPopover<ContentPopover: View>(size: CGSize,
                                           bounds: CGRect,
                                           preferredEdge: NSRectEdge,
                                           @ViewBuilder content : (@escaping () -> ContentPopover)) {
        guard self.activePopover?.isShown == false || self.activePopover == nil else { return }
        print("[PaneKit] [Popup] showing, window available? \(self.window.retrieve() != nil)")
        closePopover()
        
        let popover: NSPopover = .init()
        popover.contentSize = size
        popover.contentViewController = NSHostingController(rootView: content())
        popover.behavior = .transient
        
        DispatchQueue.main.async { [weak self] in
            guard let window = self?.window.retrieve(),
                  let contentView = window.contentView else {
                
                print("[PaneKit] [Popup] window available? \(self?.window.retrieve() != nil)")
                print("[PaneKit] [Popup] contentView available? \(self?.window.retrieve()?.contentView != nil)")
                return
            }
            
            popover.show(relativeTo: bounds,
                         of: contentView,
                         preferredEdge: preferredEdge)
        }
        
        self.activePopover = popover
    }
    
    func closePopover() {
        self.activePopover?.performClose(self)
        self.activePopover = nil
    }
    
    enum CodingKeys: CodingKey {
        case id
        case isPrepared
        case defaultSize
        case componentStorage
        case lastUpdate
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(id, forKey: .id)
        try? container.encode(isPrepared, forKey: .isPrepared)
        try? container.encode(componentStorage, forKey: .componentStorage)
        try? container.encode(lastUpdate, forKey: .lastUpdate)
    }
    
    public required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try? container.decode(String.self, forKey: .id)
        let defaultSize = try? container.decode(CGSize.self, forKey: .defaultSize)
        let storage = try? container.decode([WindowComponent : CGSize].self, forKey: .componentStorage)
        let date = try? container.decode(Date.self, forKey: .lastUpdate)
        self.init(id: id ?? UUID().uuidString, defaultSize: defaultSize ?? .zero, lastUpdate: date ?? .init()) { EmptyView() as! Content }
        
        self.componentStorage = storage ?? self.componentStorage
    }
}

