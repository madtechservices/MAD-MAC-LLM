//
//  CommantToolbar.FileSelection.swift
//  Nea
//
//  Created by PEXAVC on 5/15/23.
//

import Foundation
import SwiftUI
import Granite
import SandKit

extension CommandToolbar {
    func fileSelectionView(_ sc: any AnySubcommand) -> some View {
        
        let scValue = sand.state.subCommandSet?[sc.id]?.value
        
        let acceptedFileExtensions = scValue?.acceptedFileExtensions ?? []
        
        let baseEditorProperties: FileTextEditorView.Properties = .init(titleText: scValue?.fileDescription.capitalized ?? "Text Editor", maxTokenCount: scValue?.fileMaxTokenCount ?? SubcommandValue.defaultMaxTokenCount, isEditing: false, documentContents: "")
        
        if state.editorProperties == nil {
            center.$state.binding.editorProperties.wrappedValue = baseEditorProperties
        } else if state.editorProperties?.documentContents.isNotEmpty == true {
            center.$state.binding.editorProperties.wrappedValue?.isModifiable(true)
        }
        
        let fileProperties = center.state.editorProperties ?? baseEditorProperties
        let fileDocumentTokenCountLabel = "\(fileProperties.documentTokenCount) token\(fileProperties.documentTokenCount > 1 ? "s" : "")"
        
        let estimatedWidth = fileDocumentTokenCountLabel.count * 14
        
        //let fileDescriptor = sand.state.subCommandFileSet?[sc.id]?[scValue?.id ?? ""]
        
        return AppBlurView(padding: .init(fileProperties.documentTokenCount > 0 ? 8 : 0, 0),
                           tintColor: Brand.Colors.black.opacity(0.3)) {
            
                    PopupableView(.mount,
                                  size: .init(600, 600),
                                  edge: .maxY, {
                        
                        HStack(spacing: 8) {
                            if scValue != nil, fileProperties.documentTokenCount > 0 {
                                
                                
                                Text(fileDocumentTokenCountLabel)
                                   .lineLimit(1)
                                   .font(Fonts.live(.subheadline, .bold))
                                   .foregroundColor(.foreground)
                                   .environment(\.colorScheme, .dark)
                                   .padding(.leading, 8)
                                
                                Spacer()
                                
                                Divider()
                                
                            }
                           
                            IconView(systemName: "doc.fill.badge.plus",
                                    withBlur: false)
                                .frame(width: WindowComponent.Style.defaultElementSize.width, height: WindowComponent.Style.defaultElementSize.height)
                       }
                    }) {
                        FileTextEditorView(fileProperties)
                            .attach({ output in
                                if output.isEditing == false {
                                    center.$state.binding.editorProperties.wrappedValue = nil
                                }
                                InteractionManager.shared.closePopup(.init(kind: .mount))
                            }, at: \.closeEditor)
                            .attach({ output in
                                center.$state
                                    .binding
                                    .editorProperties
                                    .wrappedValue?
                                    .updateContents(output.documentContents,
                                                    tokenCount: output.documentTokenCount)
                                
                                //Update SandService
                                guard let contents = state.editorProperties?.documentContents else {
                                    return
                                }
                                sand
                                   .center
                                   .setSubCommandFileContents
                                   .send(SandService
                                       .SetSubCommandFileContents
                                       .Meta(id: sc.id,
                                             subcommandValueId: scValue?.id ?? "",
                                             contents: contents))
                                
                                InteractionManager.shared.closePopup(.init(kind: .mount))
                            }, at: \.confirmEditor)
                    }
                    .frame(height: WindowComponent.Style.defaultElementSize.height)
            
               }
               .frame(width: fileProperties.documentTokenCount <= 0 ? WindowComponent.Style.defaultElementSize.width : (estimatedWidth + WindowComponent.Style.defaultElementSize.width),
                      height: WindowComponent.Style.defaultElementSize.height)
               .alert("Only these file extensions are allowed: \(acceptedFileExtensions.joined(separator: ", "))", isPresented: center.$state.binding.showFileExtAlert) {
                   Button("OK", role: .cancel) { }
               }
        
    }
}
