//
//  PromptsConfigView.swift
//  Nea
//
//  Created by PEXAVC on 5/11/23.
//

import Foundation
import SwiftUI
import Granite

struct PromptConfigView: View {
    @SharedObject(WindowVisibilityManager.id) var windowVisibility: WindowVisibilityManager
    @Relay var config: ConfigService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Prompts")
                    .font(Fonts.live(.title2, .bold))
                    .foregroundColor(.foreground)
                
                Spacer()
            }
            .padding(.bottom, 8)
            
            PromptStudioCollectionView(preview: true)
            
            Spacer()
            
            AppBlurView(tintColor: Brand.Colors.purple.opacity(0.45)) {
                
                HStack(spacing: 8) {
                    
                    Button(action: {
                        let nc = NotificationCenter.default
                        nc.post(name: Notification.Name("nyc.stoic.Nea.ShowHidePromptStudio"), object: nil)
                    }) {
                        
                        Text("\(windowVisibility.isVisible(id: InteractionManager.Kind.promptStudio.rawValue) ? "Hide" : "Open") Studio")
                            .font(Fonts.live(.headline, .bold))
                            .foregroundColor(.foreground)
                    }.buttonStyle(PlainButtonStyle())
                }
            }
            .environment(\.colorScheme, .dark)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(16)
    }
}
