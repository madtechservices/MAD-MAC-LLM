//
//  PaneKit.Window.Components.Types.swift
//  Nea
//
//  Created by PEXAVC on 5/8/23.
//

import Granite
import Foundation
import SwiftUI

public protocol WindowComponentType: Equatable, Codable, Identifiable, Hashable {
    var defaultSize: CGSize { get }
}

extension WindowComponent {
    public enum Kind: WindowComponentType {
        public var id: String {
            "\(self)"
        }
        
        enum Size: GraniteModel {
            case defaultWindow
            case maxWindow
        }
        
        case toolbar
        case shortcutbar
        case spacer
        case divider
        case query
        case response
        case command
        case config
        case promptStudio
        
        func size(_ windowSize: Kind.Size) -> CGSize {
            switch windowSize {
            case .defaultWindow:
                switch self {
                case .divider:
                    return .init(WindowComponent.Style.defaultWindowSize.width, 8)
                case .spacer:
                    return .init(WindowComponent.Style.defaultWindowSize.width, WindowComponent.Style.defaultComponentOuterPaddingContainerAware)
                case .query, .response:
                    return WindowComponent.Style.defaultWindowSize
                case .toolbar:
                    return WindowComponent.Style.defaultWindowSize
                case .command:
                    return .init(WindowComponent.Style.defaultWindowSize.width,
                                 (/*WindowComponent.Style.commandMenuElementHeight * WindowComponent.Style.commandMenuDefaultElements*/450) + (WindowComponent.Style.defaultComponentOuterPadding))
                case .config:
                    return .init(610, 600)
                case .promptStudio:
                    return .init(600, 600)
                case .shortcutbar:
                    return WindowComponent.Style.defaultWindowSize
                }
            case .maxWindow:
                switch self {
                case .query:
                    return .init(WindowComponent.Style.defaultWindowSize.width, 300)
                case .response:
                    return .init(WindowComponent.Style.defaultWindowSize.width, 450)
                case .toolbar,
                        .spacer,
                        .shortcutbar,
                        .divider,
                        .command,
                        .promptStudio,
                        .config:
                    return self.defaultSize
                }
            }
        }
        
        public var defaultSize: CGSize {
            self.size(.defaultWindow)
        }
    }
    
    struct Style {
        static var defaultWindowSize: CGSize {
            .init(800, 48)
        }
        
        static var defaultElementSize: CGSize {
            .init(36, 36)
        }
        
        static var maxWindowSize: CGSize {
            .init(Style.defaultWindowSize.width,
                  WindowComponent.Kind.toolbar.size(.maxWindow).height +
                  WindowComponent.Kind.spacer.size(.maxWindow).height +
                  WindowComponent.Kind.query.size(.maxWindow).height +
                  WindowComponent.Kind.divider.size(.maxWindow).height +
                  WindowComponent.Kind.response.size(.maxWindow).height +
                  WindowComponent.Kind.spacer.size(.maxWindow).height +
                  WindowComponent.Kind.shortcutbar.size(.maxWindow).height)
        }
        
        static var defaultContainerOuterPadding: CGFloat {
            8
        }
        
        static var defaultComponentOuterPadding: CGFloat {
            24
        }
        
        static var defaultComponentOuterPaddingContainerAware: CGFloat {
            Style.defaultComponentOuterPadding - Style.defaultContainerOuterPadding
        }
        
        static var commandMenuElementHeight: CGFloat {
            60
        }
        
        static var commandMenuDefaultElements: CGFloat {
            7
        }
        
        static var defaultTitleBarHeight: CGFloat {
            24
        }
    }
}
