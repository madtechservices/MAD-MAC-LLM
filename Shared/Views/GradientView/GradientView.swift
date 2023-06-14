//
//  Gradient.swift
//  * stoic
//
//  Created by PEXAVC on 1/14/21.
//

import Foundation
import SwiftUI

public struct GradientView: View {
    
    let width: CGFloat
    let height: CGFloat
    let cornerRadius: CGFloat
    let colors: [Color]
    let direction: UnitPoint
    
    public init(colors: [Color] = [Brand.Colors.yellow, Brand.Colors.purple],
                cornerRadius: CGFloat = 12,
                direction: UnitPoint = .leading) {
        
        self.width = .infinity
        self.height = .infinity
        self.cornerRadius = cornerRadius
        self.colors = colors
        self.direction = direction
    }
    
    public init(width: CGFloat,
                height: CGFloat,
                colors: [Color] = [Brand.Colors.yellow, Brand.Colors.purple],
                cornerRadius: CGFloat = 12,
                direction: UnitPoint = .leading) {
        
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
        self.colors = colors
        self.direction = direction
    }
    
    public var body: some View {
        Rectangle()
            .frame(minWidth: 0,
                   idealWidth: width,
                   maxWidth: width,
                   minHeight: 0,
                   idealHeight: height,
                   maxHeight: height,
                   alignment: .center)
            .padding()
            .foregroundColor(.clear)
            .background(LinearGradient(
                            gradient: Gradient(colors: colors),
                            startPoint: direction,
                            endPoint: endPoint))
            .cornerRadius(cornerRadius)
    }
    
    var endPoint: UnitPoint {
        switch direction {
        case .leading:
            return .trailing
        case .trailing:
            return .leading
        case .topLeading:
            return .bottomTrailing
        case .bottomLeading:
            return .topTrailing
        case .topTrailing:
            return .bottomLeading
        case .bottomTrailing:
            return .topLeading
        case .top:
            return .bottom
        case .bottom:
            return .top
        default:
            return .bottom
            
        }
    }
}

extension View {
    func applyGradient(selected: Bool, colors: [Color]) -> some View {
        return self
            .foregroundColor(Brand.Colors.white)
            .background(
                Passthrough {
                    if selected {
                        GradientView(colors: colors,
                                     cornerRadius: 6.0,
                                     direction: .topLeading).overlay (
                                        
                                        Brand.Colors.black
                                            .opacity(0.57)
                                            .cornerRadius(4.0)
                                            .shadow(color: .black, radius: 2, x: 1, y: 1)
                                            .padding(.top, 4)
                                            .padding(.leading, 4)
                                            .padding(.trailing, 4)
                                            .padding(.bottom, 4)
                                        
                                        
                                     )
                            .padding(.top, -8)
                            .padding(.leading, -8)
                            .padding(.trailing, -8)
                            .padding(.bottom, -8)
                            .shadow(color: Color.black, radius: 2.0, x: 1.0, y: 2.0)
                    }
                }
            )
    }
}
