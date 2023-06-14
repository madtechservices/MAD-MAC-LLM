//
//  PaneKit.Window.Component.swift
//  Nea
//
//  Created by PEXAVC on 5/8/23.
//

import Foundation

//MARK: TableRow ResultBuilder

public struct WindowComponent : Identifiable, Hashable, Equatable, Codable {
    public var id: String
    public var size: CGSize? = nil
    public var defaultSize: CGSize
    public var addSize: CGSize
    
    init(_ id: any WindowComponentType, size: CGSize? = nil, addSize: CGSize = .zero) {
        self.id = "\(id.id)"
        self.size = size
        self.defaultSize = id.defaultSize
        self.addSize = addSize
    }
    
    //Equatable & Hashable
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: WindowComponent, rhs: WindowComponent) -> Bool {
        lhs.id == rhs.id
    }
}

public protocol WindowComponentGroup {
    
    var components : [WindowComponent] { get }
    
}

extension WindowComponent : WindowComponentGroup {
    
    public var components: [WindowComponent] {
        [self]
    }
    
}

extension Array: WindowComponentGroup where Element == WindowComponent {
    
    public var components: [WindowComponent] {
        self
    }
    
}

@resultBuilder public struct WindowComponentBuilder {
    
    public static func buildBlock() -> [WindowComponent] {
        []
    }
    
    public static func buildBlock(_ component : WindowComponent) -> [WindowComponent] {
        [component]
    }
    
    public static func buildBlock(_ components: WindowComponentGroup...) -> [WindowComponent] {
        components.flatMap { $0.components }
    }
    
    public static func buildEither(first component: [WindowComponent]) -> [WindowComponent] {
        component
    }
    
    public static func buildEither(second component: [WindowComponent]) -> [WindowComponent] {
        component
    }
    
    public static func buildOptional(_ components: [WindowComponent]?) -> [WindowComponent] {
        components?.flatMap { $0.components } ?? []
    }
    
}
