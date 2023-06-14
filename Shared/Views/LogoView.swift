//
//  LogoView.swift
//  Nea
//
//  Created by PEXAVC on 5/12/23.
//

import SwiftUI

struct LogoView: View {
    @State private var isAnimating = false
    
    var foreverAnimation: Animation {
        Animation.linear(duration: 84.0)
            .repeatForever(autoreverses: false)
    }
    
    var body: some View {
        Image("logo")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .rotationEffect(Angle(degrees: self.isAnimating ? 360 : 0.0))
            .animation(foreverAnimation, value: isAnimating)
            .onAppear { self.isAnimating = true }
    }
}
