//
//  Mount.Views.Locked.swift
//  Nea
//
//  Created by PEXAVC on 5/13/23.
//

import Granite
import GraniteUI
import SwiftUI

extension Mount {
    
    var lockedView: some View {
        HStack {
            Spacer()
            
            if session.isPurchasing {
                ProgressView()
                    .padding(.trailing, 8)
                
                Text("Purchasing")
                    .font(Fonts.live(.headline, .bold))
                    .foregroundColor(.foreground)
                    .environment(\.colorScheme, .dark)
                
            } else if SessionManager.IS_API_ACCESS_ENABLED && session.isLocked {
                AppBlurView(tintColor: Brand.Colors.purple.opacity(0.3)) {
                    Button {
                        config.center.$state.binding.isSettingsActive.wrappedValue = true
                        MenuBarManager.shared.showPopOver()
                    } label : {
                        Text("Set API Key")
                            .font(Fonts.live(.headline, .bold))
                            .foregroundColor(.foreground)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .environment(\.colorScheme, .dark)
            } else if session.isLocked {
                if session.isSubscribed == false || session.isLoggedIn == false {
                    AppBlurView(tintColor: Brand.Colors.purple.opacity(0.3)) {
                        
                        Button {
                            config.center.$state.binding.isAccountTabActive.wrappedValue = true
                            MenuBarManager.shared.showPopOver()
                        } label : {
                            Text(session.isLoggedIn ? "Subscribe" : "Log In")
                                .font(Fonts.live(.headline, .bold))
                                .foregroundColor(.foreground)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .environment(\.colorScheme, .dark)
                }
                
                Text("or")
                    .environment(\.colorScheme, .dark)

                AppBlurView(tintColor: Brand.Colors.purple.opacity(0.3)) {
                    Button {
                        InteractionManager.shared.observeHotkey(kind: .promptStudio)
                    } label : {
                        Text("Open Prompt Studio")
                            .font(Fonts.live(.headline, .bold))
                            .foregroundColor(.foreground)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .environment(\.colorScheme, .dark)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, WindowComponent.Style.defaultTitleBarHeight)
        .background(Brand.Colors.black.opacity(0.5))
    }
}
