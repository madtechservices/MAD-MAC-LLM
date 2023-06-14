//
//  FileTextEditorView.swift
//  Nea
//
//  Created by PEXAVC on 5/14/23.
//

import Foundation
import SwiftUI
import Granite
import GPT3_Tokenizer

struct FileTextEditorView: View {
    @GraniteAction<FileTextEditorView.Output> var closeEditor
    @GraniteAction<FileTextEditorView.Output> var confirmEditor
    
    struct Properties: GraniteModel {
        let titleText: String
        let maxTokenCount: Int
        var isEditing: Bool
        var documentContents: String
        var documentTokenCount: Int = 0
        
        mutating func isModifiable(_ state: Bool) {
            isEditing = state
        }
        
        mutating func updateContents(_ contents: String, tokenCount: Int) {
            documentContents = contents
            documentTokenCount = tokenCount
        }
    }
    
    struct Output: GraniteModel {
        let documentContents: String
        let documentTokenCount: Int
        let maxTokenCount: Int
        let isEditing: Bool
    }
    
    var titleText: String
    var maxTokenCount: Int
    var isEditing: Bool = false
    
    @State var documentContents: String = ""
    @State var showError: Bool = false
    
    let tokenizer: GPT3Tokenizer = .init()
    
    var currentOutput: Output {
        .init(documentContents: documentContents,
              documentTokenCount: documentTokenCount,
              maxTokenCount: maxTokenCount,
              isEditing: isEditing)
    }
    
    init(_ properties: Properties) {
        self.titleText = properties.titleText
        self.maxTokenCount = properties.maxTokenCount
        self.isEditing = properties.isEditing
        self.documentContents = properties.documentContents
    }
    
    var isValid: Bool {
        documentContents.isNotEmpty &&
        documentTokenCount <= maxTokenCount
    }
    
    var documentTokenCount: Int {
        //SandGPT.shared.gpt3Tokenizer.encoder.enconde(text: promptBody).count
        tokenizer.encoder.enconde(text: documentContents).count
    }
    
    var errorMessage: String {
        if documentTokenCount > maxTokenCount {
            return "Reduce the token count of your instructions to \(maxTokenCount) tokens or less."
        }
        
        var string: String = ""
        
        var issues: [String] = []
        
        if documentContents.isEmpty {
            issues.append("You still need to add a document")
        }
        
        string += issues.joined(separator: issues.count > 2 ? ", " : " ")
        
        return string
    }
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(titleText)
                        .font(Fonts.live(.title2, .bold))
                        .foregroundColor(.foreground)
                    
                    Spacer()
                    
                    AppBlurView(tintColor: Brand.Colors.black.opacity(0.3)) {
                        Button(action: {
                            closeEditor.perform(currentOutput)
                        }) {
                            Text("Close")
                                .font(Fonts.live(.headline, .bold))
                                .foregroundColor(.foreground)
                        }.buttonStyle(PlainButtonStyle())
                    }
                    .environment(\.colorScheme, .dark)
                    .padding(.top, 4)
                }
                .padding(.bottom, 8)
                
//                Text("Contents")
//                    .font(Fonts.live(.headline, .bold))
//                    .foregroundColor(.foreground)
                
                ZStack {
                    AppBlurView(size: .init(0, 440)) {
                        MacEditorTextView(
                            text: $documentContents,
                            isEditable: true,
                            font: Fonts.nsFont(.defaultSize, .bold))
                    }
                    .frame(height: 440)
                    
                    VStack {
                        Spacer()
                        
                        HStack {
                            Spacer()
                            
                            Text("\(documentTokenCount)/\(maxTokenCount)")
                                .font(Fonts.live(.caption, .bold))
                                .foregroundColor((documentTokenCount <= maxTokenCount ? Brand.Colors.green : Brand.Colors.red).opacity(0.55))
                            
                        }
                        
                        Spacer()
                            .frame(height: WindowComponent.Style.defaultContainerOuterPadding)
                    }
                    .padding(8)
                    .allowsHitTesting(false)
                }
                .frame(height: 440)
                
                if showError {
                    HStack {
                        Spacer()
                        Text(errorMessage)
                            .font(Fonts.live(.footnote, .bold))
                            .foregroundColor(Brand.Colors.red)
                        Spacer()
                    }
                } else {
                    Spacer()
                }
                
                HStack(spacing: 16) {
                    Spacer()
                    
                    AppBlurView(tintColor: Brand.Colors.purple.opacity(0.45)) {
                        Button(action: {
                            if isValid {
                                confirmEditor.perform(currentOutput)
                            } else {
                                showError = true
                            }
                        }) {
                            Text(isEditing ? "Update" : "Save")
                                .font(Fonts.live(.headline, .bold))
                                .foregroundColor(.foreground)
                        }.buttonStyle(PlainButtonStyle())
                    }
                    .environment(\.colorScheme, .dark)
                    
                    Spacer()
                }
                .padding(.bottom, 8)
                
                Spacer()
            }
            .padding(.vertical, WindowComponent.Style.defaultComponentOuterPaddingContainerAware)
        }
        .padding(16)
//        .alert(errorMessage, isPresented: $showError) {
//            Button("OK", role: .cancel) { }
//        }
    }
}
