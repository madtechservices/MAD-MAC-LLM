//
//  PromptStudioCollectionView.swift
//  Nea
//
//  Created by PEXAVC on 5/13/23.
//

import Foundation
import Granite
import SwiftUI

struct PromptStudioCollectionView: View {
    var preview: Bool = false
    
    @SharedObject(WindowVisibilityManager.id) var windowVisibility: WindowVisibilityManager
    
    @Relay var service: PromptService
    
    @GraniteAction<Void> var createPrompt
    @GraniteAction<CustomPrompt> var editPrompt
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 8) {
                if preview == false {
                    HStack {
                        Text("Collection")
                            .font(Fonts.live(.title2, .bold))
                            .foregroundColor(.foreground)
                        
                        Spacer()
                    }
                    .padding(.bottom, 8)
                }
                
                ScrollView([.vertical]) {
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 126))],
                              alignment: .leading,
                              spacing: 16) {
                        
                        if preview == false {
                            addView
                        }
                        
                        if service.state.customPrompts.isEmpty && preview {
                            HStack {
                                Text("Open the studio to create custom commands/prompts. Helping you customize your experience and repeat tasks effeciently.")
                                    .font(Fonts.live(.defaultSize, .bold))
                                
                                Spacer()
                                
                            }
                            .frame(width: 360)
                        } else {
                            
                            ForEach(Array(service.state.customPrompts.values)) { prompt in
                                
                                Button {
                                    if preview {
                                        guard windowVisibility.isVisible(id: InteractionManager.Kind.promptStudio.rawValue) == false else { return }
                                        
                                        let nc = NotificationCenter.default
                                        nc.post(name: Notification.Name("nyc.stoic.Nea.ShowHidePromptStudio"), object: nil)
                                    } else {
                                        editPrompt.perform(prompt)
                                    }
                                } label: {
                                    PromptPreviewView(prompt: prompt)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .frame(width: 126, height: 126)
                            }
                        }
                        
                        Spacer()
                    }
                }
            }
            .padding(.top, WindowComponent.Style.defaultComponentOuterPaddingContainerAware)
        }.padding(preview ? 0 : 16)
    }
    
    var addView: some View {
        Button {
            createPrompt.perform()
        } label: {
            AppBlurView(size: .init(0, 126)) {
                Image(systemName: "plus")
                    .font(Fonts.live(.largeTitle, .bold))
                    .frame(width: 126, height: 126)
            }
            .frame(width: 126, height: 126)
        }
        .buttonStyle(PlainButtonStyle())
        .frame(width: 126, height: 126)
    }
}
