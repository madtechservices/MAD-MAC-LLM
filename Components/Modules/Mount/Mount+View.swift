import Granite
import GraniteUI
import SwiftUI
import SandKit

extension Mount: View {
    var queryHeight: CGFloat {
        environment.sizeFor(.query).height + (environment.titleBarHeight / 2)
    }
    
    var responseHeight: CGFloat {
        environment.sizeFor(.response).height + (environment.titleBarHeight / 2)
    }
    
    var backgroundView: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: WindowComponent.Style.defaultTitleBarHeight)
            
            if environment.state.isCommandActive {
                VisualEffectBackground(overlayColor: Color.background)
                    .cornerRadius(8)
            } else {
                VisualEffectBackground(overlayColor: Color.background)
                    .cornerRadius(8)
                    .frame(maxHeight: queryHeight + (environment.state.isCommandToolbarActive ? WindowComponent.Kind.toolbar.defaultSize.height + WindowComponent.Style.defaultComponentOuterPaddingContainerAware : 0))
                
                if environment.state.isResponseActive {
                    Spacer()
                        .frame(height: WindowComponent.Kind.divider.defaultSize.height)
                    
                    VisualEffectBackground(overlayColor: Color.background)
                        .cornerRadius(8)
                        .foregroundColor(.background)
                        .frame(maxHeight: responseHeight)
                }
                
                if environment.state.isResponseActive ||
                   environment.state.isCommandToolbarActive {
                    
                    Spacer()
                }
            }
        }
        .overlay(TokenCountView())
        .padding(WindowComponent.Style.defaultContainerOuterPadding)
    }
    
    var mainView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer().frame(height: WindowComponent.Style.defaultTitleBarHeight)
            
            Spacer().frame(height: WindowComponent.Style.defaultContainerOuterPadding)
            
            if environment.state.isCommandToolbarActive {
                Spacer()
                    .frame(height: WindowComponent.Kind.toolbar.defaultSize.height + WindowComponent.Style.defaultComponentOuterPaddingContainerAware)
            }
            
            Query()
                .frame(maxHeight: queryHeight)
                .padding(.horizontal,
                         WindowComponent.Style.defaultComponentOuterPadding)
                .backgroundIf(config.state.showVisualGuide) {
                    Color.clear
                        .border(.yellow, width: 2)
                        .allowsHitTesting(false)
                }
            
            
            if  environment.state.isResponseActive ||
                environment.state.isCommandActive ||
                environment.state.isCommandToolbarActive {
                
                Spacer().frame(height: WindowComponent.Kind.divider.defaultSize.height)
                
                if environment.state.isCommandActive {
                    Divider()
                        .padding(.horizontal,
                                 WindowComponent.Style.defaultContainerOuterPadding)
                }
                
                ZStack {
                    if environment.state.isResponseActive {
                        Response()
                            .frame(maxHeight: responseHeight)
                            .opacity(environment.state.isCommandActive ? 0.0 : 1.0)
                            .padding(.horizontal,
                                     WindowComponent.Style.defaultComponentOuterPadding)
                            .backgroundIf(config.state.showVisualGuide) {
                                Color.clear
                                    .border(.red, width: 2)
                                    .allowsHitTesting(false)
                            }
                            .overlayIf(sand.state.isResponding && sand.state.response.isEmpty) {
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundColor(Brand.Colors.black.opacity(0.45))
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .padding(.horizontal, WindowComponent.Style.defaultContainerOuterPadding)
                                ProgressView()
                            }
                    }
                    
                    if environment.state.isCommandActive {
                        CommandMenu()
                            .frame(
                                maxHeight: WindowComponent.Kind.command.defaultSize.height)
                            .backgroundIf(config.state.showVisualGuide) {
                                Color.clear
                                    .border(.blue, width: 2)
                                    .allowsHitTesting(false)
                            }
                    }
                }
            }
            
            Spacer()
        }
    }
    
    var toolbarViews: some View {
        Group {
            if environment.state.isCommandToolbarActive {
                CommandToolbar()
                    .frame(minHeight: WindowComponent.Kind.toolbar.defaultSize.height)
                //Moved inside component for divider's padding
//                    .padding(.horizontal,
//                             WindowComponent.Style.defaultComponentOuterPadding)
                    .backgroundIf(config.state.showVisualGuide) {
                        Color.clear
                            .border(.green, width: 2)
                            .allowsHitTesting(false)
                    }
            }
            
            if  (environment.state.isResponseActive ||
                environment.state.isCommandToolbarActive) &&
                environment.state.isCommandActive == false {
                
                ShortcutBar()
                    .frame(minHeight: WindowComponent.Kind.shortcutbar.defaultSize.height)
                    .padding(.horizontal, WindowComponent.Style.defaultContainerOuterPadding)
                    .backgroundIf(config.state.showVisualGuide) {
                        Color.clear
                            .border(.orange, width: 2)
                            .allowsHitTesting(false)
                    }
            }
        }
    }
    
    public var view: some View {
        ZStack {
            backgroundView
            
            mainView
            
            toolbarViews
            
            //TODO: Session.isLocked applied to IAP states too, remove such logic in the future
            if session.isLocked {
                lockedView
            }
        }
    }
}


