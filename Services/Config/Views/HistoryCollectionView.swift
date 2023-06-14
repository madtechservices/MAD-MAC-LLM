//
//  HistoryCollectionView.swift
//  Nea
//
//  Created by PEXAVC on 5/20/23.
//

import Foundation
import Granite
import SwiftUI

struct HistoryCollectionView: View {
    @GraniteAction<QueryHistory> var queryHistorySelected
    
    var history: [QueryHistory]
    
    @State var isHovering: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ScrollView([.vertical]) {
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 126))],
                          alignment: .leading,
                          spacing: 16) {
                    if history.isEmpty {
                        HStack {
                            Text("There's nothing in your history yet.")
                                .font(Fonts.live(.defaultSize, .bold))
                            
                            Spacer()
                            
                        }
                        .frame(width: 360)
                    } else {
                        
                        ForEach(history) { queryHistory in
                            
                            Button {
                                
                            } label: {
                                historyView(queryHistory)
                                    .onTapGesture {
                                        queryHistorySelected.perform(queryHistory)
                                    }
                            }
                            .buttonStyle(PlainButtonStyle())
                            .frame(width: 126, height: 126)
                        }
                    }
                    
                    Spacer()
                }
            }
        }.frame(minHeight: 240)
    }
    
    func historyView(_ queryHistory: QueryHistory) -> some View {
        
        let baseColor: Color
        
        if let hexColor = queryHistory.baseColor {
            baseColor = .init(hex: hexColor).opacity(0.45)
        } else {
            baseColor = Brand.Colors.black.opacity(0.3)
        }
        
        let command: String
        
        if let value = queryHistory.command {
            command = "/\(value.capitalized)"
        } else {
            command = "General"
        }
        
        return AppBlurView(size: .init(0, 126),
                    tintColor: baseColor) {
            
            ZStack {
                if queryHistory.isSystemPrompt {
                    Image("logo_granite")
                        .resizable()
                        .opacity(0.6)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                
                if isHovering == queryHistory.id {
                    RoundedRectangle(cornerRadius: 6)
                        .foregroundColor(.accentColor.opacity(0.9))
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        if let iconName = queryHistory.iconName {
                            AppBlurView(size: .init(24, 24),
                                        padding: .init(.zero),
                                        tintColor: Brand.Colors.black.opacity(0.3)) {
                                Image(systemName: iconName)
                                    .font(Fonts.live(.caption2, .bold))
                                    .foregroundColor(.foreground)
                                    .environment(\.colorScheme, .dark)
                                    .padding(.bottom, 2)
                            }
                            .aspectRatio(1, contentMode: .fit)
                            .frame(width: 24, height: 24)
                        }
                        
                        Text(command)
                            .font(Fonts.live(.caption2, .bold))
                        
                        Spacer()
                    }
                    .padding(.bottom, 8)
                    
                    Text("input: \(queryHistory.query)")
                        .lineLimit(1)
                        .font(Fonts.live(.caption, .bold))
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.bottom, 2)
                    
                    Text("output: \(queryHistory.response)")
                        .lineLimit(2)
                        .font(Fonts.live(.caption, .regular))
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.bottom, 8)
                    
                    Spacer()
                    
                    HStack {
                        Text("\(queryHistory.date.asString)")
                            .font(Fonts.live(.caption2, .bold))
                        
                        Spacer()
                    }
                }
                .padding(8)
            }.frame(width: 126, height: 126)
        }
        .frame(width: 126, height: 126)
        .environment(\.colorScheme, .dark)
        .onHover { isHovered in
            DispatchQueue.main.async { //<-- Here
                if isHovered {
                    self.isHovering = queryHistory.id
                } else if self.isHovering == queryHistory.id {
                    self.isHovering = ""
                }
                
                if self.isHovering == queryHistory.id {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }
        }
    }
}
