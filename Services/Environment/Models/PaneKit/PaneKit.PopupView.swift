//
//  PaneKit.PopupView.swift
//  Nea
//
//  Created by PEXAVC on 5/13/23.
//

import Foundation
import SwiftUI

struct PopupView: View {

    let size: CGSize
    let content: AnyView

    init<Content: View>(size: CGSize,
                        @ViewBuilder content: @escaping () -> Content) {
        self.size = size
        self.content = AnyView(content())
    }

    var body: some View {
        ZStack {
            VisualEffectBackground()
            content
        }
        .frame(width: size.width, height: size.height)
    }
}

struct PopupableView<Content: View, TargetContent: View>: View {
    
    let kind: InteractionManager.Kind
    let size: CGSize
    let edge: NSRectEdge
    
    let content: (() -> Content)
    let targetContent: (() -> TargetContent)

    init(_ kind: InteractionManager.Kind,
         size: CGSize,
         edge: NSRectEdge,
         @ViewBuilder _ content: @escaping () -> Content,
         @ViewBuilder _ targetContent: @escaping () -> TargetContent) {
        self.kind = kind
        self.size = size
        self.edge = edge
        
        self.content = content
        self.targetContent = targetContent
    }

    var body: some View {
        GeometryReader { geo in
            content()
                .onTapGesture {
                InteractionManager
                    .shared
                    .showPopup(
                        kind,
                        size: size,
                        bounds: geo.frame(in: .global),
                        edge: edge) {
                    targetContent()
                }
            }
        }
    }
}
