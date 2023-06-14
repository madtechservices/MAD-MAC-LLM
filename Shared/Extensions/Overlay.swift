import Foundation
import SwiftUI

extension View {
    
    @ViewBuilder
    func overlayFullScreenGradient(_ shouldOverlay: Bool = true) -> some View {
        if shouldOverlay {
            self.overlay(
                LinearGradient(stops: [
                    .init(color: AppStyle.Colors.Surface.background.opacity(0.2), location: 0.0),
                    .init(color: AppStyle.Colors.Surface.background.opacity(0.1), location: 0.05),
                    .init(color: AppStyle.Colors.Surface.background.opacity(0), location: 0.3),
                    .init(color: AppStyle.Colors.Surface.background.opacity(0), location: 0.55),
                    .init(color: AppStyle.Colors.Surface.background.opacity(0.3), location: 1.0)],
                               startPoint: .top,
                               endPoint: .bottom)
                , alignment: .center)
        } else {
            self
        }
    }
    
    @ViewBuilder
    func overlayBottomGradient(_ shouldOverlay: Bool = true) -> some View {
        if shouldOverlay {
            self.overlay(
                LinearGradient(stops: [
                    .init(color: AppStyle.Colors.Surface.background.opacity(0), location: 0.55),
                    .init(color: AppStyle.Colors.Surface.background.opacity(0.7), location: 1.0)],
                               startPoint: .top,
                               endPoint: .bottom)
                , alignment: .center)
        } else {
            self
        }
    }
    
    @ViewBuilder
    func overlayStroke(cornerRadius: CGFloat = 8,
                       bottomCornerRadius: CGFloat? = nil,
                       strokeWidth: CGFloat = 1) -> some View {
        self.overlay(
            RoundedCornersPathShape(tl: cornerRadius,
                                    tr: cornerRadius,
                                    bl: bottomCornerRadius ?? cornerRadius,
                                    br: bottomCornerRadius ?? cornerRadius)
                .stroke(lineWidth: strokeWidth)
                .fill(AppStyle.Colors.Surface.foreground.opacity(0.1))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        , alignment: .center)
    }
    
    @ViewBuilder
    func applyShadow(_ shouldAddShadow: Bool = true) -> some View {
        self.shadow(color: shouldAddShadow ? Color.black.opacity(0.66) : .clear, radius: 8, x: 0, y: 2)
    }
}

