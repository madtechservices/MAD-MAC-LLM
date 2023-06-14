//
//  Mount.Views.Symbols.swift
//  Nea
//
//  Created by PEXAVC on 5/6/23.
//

import Granite
import GraniteUI
import SwiftUI

extension Mount {
    var leadingSymbolView: some View {
        HStack {
            Spacer()
            
            HStack {
                Text("Enter")
                    .font(Fonts.live(.headline, .bold))
                
                Image(systemName: "return.left")
                    .frame(width: 20)
            }
            .frame(height: 20)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Rectangle()
                    .foregroundColor(Brand.Colors.marble)
                    .cornerRadius(4)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Rectangle()
                            .foregroundColor(Brand.Colors.marbleV2)
                            .cornerRadius(4)
                    )
            )
            .cornerRadius(4)
            
            .foregroundColor(Brand.Colors.black)
        }
        .padding(.bottom, 20)
        .allowsHitTesting(false)
    }
}
