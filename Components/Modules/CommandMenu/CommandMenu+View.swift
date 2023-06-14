import Granite
import SwiftUI
import SandKit

extension CommandMenu: View {
    public var view: some View {
        VStack(spacing: 16) {
            gridView
            //tableView
            VStack(spacing: 8) {
                Divider()
                
                HStack {
                    Spacer()
                    addPromptView
                    Spacer()
                }
                
                Spacer()
            }
            .frame(height: WindowComponent.Style.defaultElementSize.height)
            .padding(.horizontal, WindowComponent.Style.defaultContainerOuterPadding)
            .padding(.bottom, WindowComponent.Style.defaultContainerOuterPadding)
        }
    }
    
    var gridView: some View {
        ScrollView([.vertical]) {
            Spacer().frame(height: 24)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))],
                      alignment: .center,
                      spacing: 16) {
                ForEach(basicPrompts, id: \.command.value) { prompt in
                    
                    Button {
                        sand
                            .center
                            .setCommand
                            .send(
                                SandService
                                    .SetCommand
                                    .Meta(value: prompt.command.value,
                                          reset: false))
                    } label: {
                        PromptPreviewView(prompt: prompt,
                                          size: .init(width: 170, height: 170),
                                          styleSize: .large,
                                          showCustomLabel: true)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .frame(width: 170, height: 170)
                }
            }
            .padding(.horizontal, WindowComponent.Style.defaultComponentOuterPaddingContainerAware)
            Spacer()
        }
        .padding(.horizontal, WindowComponent.Style.defaultContainerOuterPadding)
    }
    
    var tableView: some View {
        ScrollView([.vertical]) {
            Spacer()
            
            TableView {
                rows
            }.tableViewStyle(.init(rowHeight: WindowComponent.Style.commandMenuElementHeight,
                                   showSeperators: false,
                                   paddingRow: .init(WindowComponent.Style.defaultComponentOuterPaddingContainerAware, 0),
                                   paddingTable: .init(WindowComponent.Style.defaultContainerOuterPadding, 0)))
            .animation(.default, value: query.state.value.count)
            
            Spacer()
        }
    }
    
    var basicPrompts: [any BasicPrompt] {
        var cases: [String] = prompts.commands
        var sortedCases: [String] = []
        if query.state.value.hasPrefix("/") {
            let suggestions: [String] = query.state.value.suggestions(sand.state.commandAutoComplete).map { String($0.lowercased().suffix($0.count - 1)) }
            
            cases.removeAll(where: { suggestions.contains($0.lowercased()) })
            sortedCases = Array(suggestions.map { $0 }) + cases
        }
        
        return (sortedCases.isEmpty ? cases : sortedCases).compactMap({ prompts.prompt($0) })
    }
    
    var rows: [TableRow] {
        var list: [TableRow] = []
        
        for prompt in basicPrompts {
            let isLocked = prompt.isSystemPrompt == true && session.isSubscribed == false
            let labelText: LocalizedStringKey? = isLocked ? .init("subscribe") : (prompt.isSystemPrompt == true ? nil : .init("custom"))
            list.append(
                TableRow(kind: .label(isLocked ? Color.gray : Color.orange),
                         text: .init("/\(prompt.command.value.capitalized)...",
                                     subLeading: .init("\(prompt.description)"),
                                     trailing: labelText),
                         graphic: .init(prompt.iconName,
                                        leadingBGColor: prompt.baseColor,
                                        texture: prompt.isSystemPrompt == true)) {
                    sand
                        .center
                        .setCommand
                        .send(
                            SandService
                                .SetCommand
                                .Meta(value: prompt.command.value, reset: false))
                }
            )
        }
        return list
    }
    
    var addPromptView: some View {
        AppBlurView(padding: .init(16),
                    tintColor: Brand.Colors.black.opacity(0.3)) {
            Button {
                InteractionManager.shared.observeHotkey(kind: .promptStudio)
            } label : {
                HStack(spacing: 8) {
                    Text("Add Prompt Command")
                        .lineLimit(1)
                        .font(Fonts.live(.subheadline, .bold))
                        .foregroundColor(.foreground)
                        .environment(\.colorScheme, .dark)
                    
                    Divider()
                        .padding(.horizontal, 8)
                    
                    Image(systemName: "plus")
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

