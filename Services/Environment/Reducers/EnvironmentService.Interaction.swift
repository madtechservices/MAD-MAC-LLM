//
//  EnvironmentService.Direction.swift
//  Nea
//
//  Created by PEXAVC on 5/6/23.
//

import Foundation
import Granite
import SwiftUI

extension EnvironmentService {
    struct Interact: GraniteReducer {
        typealias Center = EnvironmentService.Center
        
        struct Meta: GranitePayload {
            let interaction: Interaction
        }
        
        @Payload var meta: Meta?
        
        func reduce(state: inout Center.State) {
            switch meta?.interaction {
            case .bringToFront(let kind):
                switch kind {
                case .mount:
                    state.pane?.bringToFront()
                case .promptStudio:
                    state.promptStudioPane?.bringToFront()
                }
            default:
                break
            }
            
            state.lastInteraction = meta?.interaction ?? state.lastInteraction
        }
    }
    
    struct ShowPopup: GraniteReducer {
        typealias Center = EnvironmentService.Center
        
        struct Meta<Content: View>: GranitePayload {
            let kind: InteractionManager.Kind
            let size: CGSize
            let bounds: CGRect
            let preferredEdge: NSRectEdge
            let content: () -> Content
            
            init(kind: InteractionManager.Kind,
                 size: CGSize,
                 bounds: CGRect,
                 preferredEdge: NSRectEdge,
                 @ViewBuilder content : (@escaping () -> Content)) {
                self.kind = kind
                self.size = size
                self.bounds = bounds
                self.preferredEdge = preferredEdge
                self.content = content
            }
        }
        
        @Payload var meta: Meta<PopupView>?
        
        func reduce(state: inout Center.State) {
            guard let meta = self.meta else { return }
            switch meta.kind {
            case .mount:
                state.pane?.showPopover(size: meta.size, bounds: meta.bounds,preferredEdge: meta.preferredEdge, content: meta.content)
            case .promptStudio:
                state.promptStudioPane?.showPopover(size: meta.size, bounds: meta.bounds,preferredEdge: meta.preferredEdge, content: meta.content)
            }
        }
    }
    
    struct ClosePopup: GraniteReducer {
        typealias Center = EnvironmentService.Center
        
        struct Meta: GranitePayload {
            let kind: InteractionManager.Kind
        }
        
        @Payload var meta: Meta?
        
        func reduce(state: inout Center.State) {
            guard let meta = self.meta else { return }
            switch meta.kind {
            case .mount:
                state.pane?.closePopover()
            case .promptStudio:
                state.promptStudioPane?.closePopover()
            }
        }
    }
    
    struct Reset: GraniteReducer {
        typealias Center = EnvironmentService.Center
        
        func reduce(state: inout Center.State) {
            state.pane?.display {
                WindowComponent(WindowComponent.Kind.query,
                                size: WindowComponent.Kind.query.defaultSize)
            }
            
            state.isCommandToolbarActive = false
            state.isResponseActive = false
            state.isCommandActive = false
        }
    }
    
    struct CommandToolbarActivated: GraniteReducer {
        typealias Center = EnvironmentService.Center
        
        struct Meta: GranitePayload {
            let isActive: Bool
        }
        
        @Payload var meta: Meta?
        
        func reduce(state: inout Center.State) {
            guard let meta = self.meta else { return }
            
            if meta.isActive && state.isCommandToolbarActive == false {
                
                state.isCommandActive = false
                state.isCommandToolbarActive = true
                
                let addResponse: Bool = state.isResponseActive
                
                state.pane?.display {
                    WindowComponent(WindowComponent.Kind.toolbar,
                                    size: WindowComponent.Kind.toolbar.defaultSize)
                    
                    WindowComponent(WindowComponent.Kind.spacer)
                    
                    WindowComponent(WindowComponent.Kind.query,
                                    size: .size(0, 160))
                    
                    if addResponse {
                        WindowComponent(WindowComponent.Kind.divider)
                        
                        WindowComponent(WindowComponent.Kind.response)
                        
                        WindowComponent(WindowComponent.Kind.spacer)
                    }
                    
                    WindowComponent(WindowComponent.Kind.shortcutbar)
                }
            } else if meta.isActive == false {
                
                state.isCommandToolbarActive = false
                
                let addResponse: Bool = state.isResponseActive
                
                state.pane?.display {
                    WindowComponent(WindowComponent.Kind.query)
                    
                    if addResponse {
                        WindowComponent(WindowComponent.Kind.divider)
                        
                        WindowComponent(WindowComponent.Kind.response)
                        
                        WindowComponent(WindowComponent.Kind.spacer)
                        
                        WindowComponent(WindowComponent.Kind.shortcutbar)
                    }
                }
            }
            
            //TODO: hack to have state react
            state.lastUpdate = .init()
        }
    }
    
    struct CommandMenuActivated: GraniteReducer {
        typealias Center = EnvironmentService.Center
        
        struct Meta: GranitePayload {
            let isActive: Bool
        }
        
        @Payload var meta: Meta?
        
        func reduce(state: inout Center.State) {
            guard let meta = self.meta else { return }
            
            if state.isCommandToolbarActive /*&&
                meta.isActive == false &&
                state.isCommandActive == false*/ {
                return
            }
            
            if meta.isActive {
                state.pane?.display {
                    WindowComponent(WindowComponent.Kind.query)
                    WindowComponent(WindowComponent.Kind.command, size: WindowComponent.Kind.command.defaultSize)
                }
            } else {
                let addResponse = state.isResponseActive
                state.pane?.display {
                    WindowComponent(WindowComponent.Kind.query)
                    
                    if addResponse {
                        WindowComponent(WindowComponent.Kind.divider)
                        
                        WindowComponent(WindowComponent.Kind.response)
                        
                        WindowComponent(WindowComponent.Kind.spacer)
                        
                        WindowComponent(WindowComponent.Kind.shortcutbar)
                    }
                }
            }
            
            state.isCommandActive = meta.isActive
            
            //TODO: hack to have state react
            state.lastUpdate = .init()
        }
    }
    
    
    struct QueryWindowSizeUpdated: GraniteReducer {
        typealias Center = EnvironmentService.Center
        
        struct Meta: GranitePayload {
            let lineCount: Int
        }
        
        @Payload var meta: Meta?
        
        func reduce(state: inout Center.State) {
            guard let meta = self.meta else { return }
            
            let defaultSize = WindowComponent.Kind.query.defaultSize
            
            let baseHeight: CGFloat = defaultSize.height
            
            let fontDetails: Fonts.Details = .from(.defaultSize)
            
            var newHeight: CGFloat = baseHeight + (fontDetails.lineHeight * (meta.lineCount - 1)) + ((meta.lineCount - 1) * (fontDetails.boundingRectDiff / 2))
            
//            if meta.lineCount > 1 {
//                newHeight += fontDetails.actualHeight
//            }
            
            let queryWindowSize: CGSize = .init(defaultSize.width,
                                                min(
                                                 WindowComponent.Kind.query.size(.maxWindow).height, newHeight))
            
            let isToolbarActive: Bool = state.isCommandToolbarActive
            let addResponse: Bool = state.isResponseActive
            
            state.pane?.display {
                if isToolbarActive {
                    WindowComponent(WindowComponent.Kind.toolbar,
                                    size: WindowComponent.Kind.toolbar.size(.defaultWindow))
                    
                    WindowComponent(WindowComponent.Kind.spacer)
                }
                
                WindowComponent(WindowComponent.Kind.query, size: isToolbarActive && newHeight <= 160 ? .init(0, 160) : queryWindowSize)
                
                if addResponse {
                    WindowComponent(WindowComponent.Kind.divider)
                    
                    WindowComponent(WindowComponent.Kind.response)
                    
                    WindowComponent(WindowComponent.Kind.spacer)
                }
                
                if addResponse || isToolbarActive {
                    WindowComponent(WindowComponent.Kind.shortcutbar)
                }
            }
            
            //TODO: hack to have query window size react
            state.lastUpdate = .init()
        }
    }
    
    struct ResponseWindowSizeUpdated: GraniteReducer {
        typealias Center = EnvironmentService.Center
        
        struct Meta: GranitePayload {
            let lineCount: Int
            var responseHelpersActive: Bool = false
            var basedOnString: String? = nil
        }
        
        @Payload var meta: Meta?
        
        func reduce(state: inout Center.State) {
            guard let meta = self.meta else { return }
            
            let defaultSize = WindowComponent.Kind.response.defaultSize
            
            let baseHeight: CGFloat = defaultSize.height
            
            let fontDetails: Fonts.Details = .from(.defaultResponseSize)
            
            var newHeight: CGFloat = baseHeight + (fontDetails.lineHeight * (meta.lineCount - 1)) + ((meta.lineCount - 1) * (fontDetails.boundingRectDiff / 2))
            
            if meta.lineCount > 1 {
                newHeight += fontDetails.actualHeight
            }
            
            if let stringReference = meta.basedOnString {
                let height = stringReference.height(withConstrainedWidth: defaultSize.width - (WindowComponent.Style.defaultComponentOuterPadding + WindowComponent.Style.defaultComponentOuterPaddingContainerAware), font: Fonts.nsFont(.body, .bold)) + (16 * 2)// + top/bottom padding

                newHeight = height > newHeight ? height : newHeight
            }
            
            
            let responseWindowSize: CGSize = .init(defaultSize.width,
                                                   min(
                                                    WindowComponent.Kind.response.size(.maxWindow).height, newHeight))
            let isToolbarActive: Bool = state.isCommandToolbarActive
            
            state.pane?.display {
                if isToolbarActive {
                    WindowComponent(WindowComponent.Kind.toolbar,
                                    size: WindowComponent.Kind.toolbar.size(.defaultWindow))
                    
                    WindowComponent(WindowComponent.Kind.spacer)
                }
                
                WindowComponent(WindowComponent.Kind.query)
                
                WindowComponent(WindowComponent.Kind.divider)
                
                WindowComponent(WindowComponent.Kind.response,
                                size: /*(isToolbarActive || meta.responseHelpersActive) &&*/ newHeight <= 208 ? .init(0, 208) : responseWindowSize)
                
                WindowComponent(WindowComponent.Kind.spacer)
//
                WindowComponent(WindowComponent.Kind.shortcutbar)
            }
            
            state.isResponseActive = true
        }
    }
}
