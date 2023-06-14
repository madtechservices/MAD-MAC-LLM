//
//  IconView.swift
//  Nea
//
//  Created by PEXAVC on 5/11/23.
//

import Foundation
import SwiftUI

struct IconView: View {
    
    let systemName: String
    var bgColor: Color? = nil
    var withBlur: Bool = false
    var withTexture: Bool = false
    
    
    var body: some View {
        if withBlur {
            AppBlurView(padding: .init(.zero),
                        tintColor: (bgColor ?? Brand.Colors.black).opacity(bgColor == nil ? 0.3 : 0.75)) {
                
                ZStack(alignment: .center) {
                    if withTexture {
                        
                        Image("logo_granite")
                            .resizable()
                            .opacity(0.6)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    
                    Image(systemName: systemName)
                        .font(Fonts.live(.headline, .bold))
                        .foregroundColor(.foreground)
                        .environment(\.colorScheme, .dark)
                        .padding(.bottom, 2)
                }
                .aspectRatio(1, contentMode: .fit)
            }
            .aspectRatio(1, contentMode: .fit)
        } else {
            
            ZStack(alignment: .center) {
                RoundedRectangle(cornerRadius: 6)
                    .foregroundColor(bgColor ?? .clear)
                    .frame(minWidth: WindowComponent.Style.defaultElementSize.height)
                    .frame(minHeight: WindowComponent.Style.defaultElementSize.height)
                
                if withTexture {
                    
                    Image("logo_granite")
                        .resizable()
                        .opacity(0.6)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                
                Image(systemName: systemName)
                    .font(Fonts.live(.headline, .bold))
                    .foregroundColor(.foreground)
                    .environment(\.colorScheme, .dark)
                    .padding(.bottom, 2)
            }
            .aspectRatio(1, contentMode: .fit)
        }
    }
}
