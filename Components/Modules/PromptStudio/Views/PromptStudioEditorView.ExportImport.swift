//
//  PromptStudioEditorView.ExportImport.swift
//  Nea
//
//  Created by PEXAVC on 5/18/23.
//

import Foundation
import SwiftUI

extension PromptStudioEditorView {
    var exportButtonView: some View {
        AppBlurView(padding: .init(16),
                    tintColor: Brand.Colors.black.opacity(0.3)) {
            Button {
                
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                
                if let data = try? encoder.encode(asCustomPrompt) {
                    
                    //Encryption occurs here in the Live version
                    
                    print("[PromptStudioEditorView] encoded: \(data.count)")
                    
                    //4. Save
                    let panel = NSSavePanel()
                    panel.nameFieldLabel = "Save prompt as:"
                    panel.nameFieldStringValue = "\(self.promptCommand).neatia"
                    panel.canCreateDirectories = true
                    panel.allowedContentTypes = [.init(exportedAs: "nyc.stoic.Nea-neatia-custom-prompt-v1.0")]
                    panel.begin { response in
                        if response == NSApplication.ModalResponse.OK,
                           let fileURL = panel.url {
                            
                            try? data.write(to: fileURL)
                        }
                    }
                }
                
            } label : {
                HStack(spacing: 8) {
                    Text("Export")
                        .lineLimit(1)
                        .font(Fonts.live(.subheadline, .bold))
                        .foregroundColor(.foreground)
                        .environment(\.colorScheme, .dark)
                    
                    Divider()
                        .padding(.horizontal, 8)
                    
                    Image(systemName: "arrow.up.square")
                        .font(Fonts.live(.title3, .bold))
                        .foregroundColor(.foreground)
                        .environment(\.colorScheme, .dark)
                        .padding(.bottom, 2)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    var importButtonView: some View {
        AppBlurView(padding: .init(16),
                    tintColor: Brand.Colors.black.opacity(0.3)) {
            Button {
                let panel = NSOpenPanel()
                panel.allowsMultipleSelection = false
                panel.canChooseDirectories = false
                panel.canCreateDirectories = false
                panel.allowedContentTypes = [.init(exportedAs: "nyc.stoic.Nea-neatia-custom-prompt-v1.0"), .init(importedAs: "nyc.stoic.Nea-neatia-custom-prompt-v1.0")]
                if panel.runModal() == .OK {
                    if let url = panel.url {
                        
                        if let data = try? Data(contentsOf: url) {
                            
                            //Decryption occurs here in the Live version
                            
                            let decoder = JSONDecoder()
                            if let customPrompt = try? decoder.decode(CustomPrompt.self,
                                                                      from: data) {
                                
                                update(customPrompt)
                                
                                print("[PromptStudioEditor] Decoded and updated custom prompt")
                            }
                        }
                    }
                }
                
            } label : {
                HStack(spacing: 8) {
                    Text("Import")
                        .lineLimit(1)
                        .font(Fonts.live(.subheadline, .bold))
                        .foregroundColor(.foreground)
                        .environment(\.colorScheme, .dark)
                    
                    Divider()
                        .padding(.horizontal, 8)
                    
                    Image(systemName: "arrow.down.square")
                        .font(Fonts.live(.title3, .bold))
                        .foregroundColor(.foreground)
                        .environment(\.colorScheme, .dark)
                        .padding(.bottom, 2)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}
