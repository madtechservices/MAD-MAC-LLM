//
//  WindowManager.VisualEffectView.swift
//  Nea
//
//  Created by PEXAVC on 5/7/23.
//

import Foundation
import SwiftUI
import Combine

struct PaneView: View {

    var body: some View {
        ZStack {
            VisualEffectBackground()
                .ignoresSafeArea()
                .zIndex(0)
                
            Mount()
                .ignoresSafeArea()
                .zIndex(2)
        }
        .frame(width: WindowComponent.Style.defaultWindowSize.width)
        .frame(minHeight: WindowComponent.Style.defaultWindowSize.height + WindowComponent.Style.defaultTitleBarHeight)
        //.preferredColorScheme(.light)
    }
}

struct PromptStudioPaneView: View {

    var body: some View {
        ZStack {
            VisualEffectBackground()
                .ignoresSafeArea()
                .zIndex(0)
                
            PromptStudio()
                .ignoresSafeArea()
                .zIndex(2)
        }
        .frame(width: WindowComponent.Kind.promptStudio.size(.defaultWindow).width,
               height: WindowComponent.Kind.promptStudio.size(.defaultWindow).height)
        //.preferredColorScheme(.light)
    }
}
