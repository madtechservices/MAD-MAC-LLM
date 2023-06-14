import Granite
import SwiftUI
import SandKit

extension Query: View {
    public var view: some View {
        VStack(spacing: 0) {
            //            Spacer().frame(height: Fonts.nsFont(.headline, .bold).actualHeight)
            
            ZStack(alignment: .top) {
                if session.isLocked {
                    MacEditorTextView(
                        text: .constant(""),
                        isEditable: false,
                        font: Fonts.nsFont(.defaultSize, .bold))
                        .overlay(Color.clear)
                } else {
                    MacEditorTextView(
                        text: query.center.$state.binding.value,
                        autoCompleteText: sand.center.$state.binding.commandAutoComplete,
                        isCommandMenuActive: center.$state.binding.isCommandMenuActive,
                        font: Fonts.nsFont(.defaultSize, .bold),
                        onEditingChanged: {
                            center.$state.binding.wrappedValue.isEditing = true
                        },
                        onCommit: {
                            guard environment.center.state.isCommandActive == false else {
                                return
                            }
                            
                            sand.center.ask.send()
                        },
                        onTabComplete: { value in
                            //Check for environment commands
                            if value.hasPrefix("/"),
                               let first = value.lowercased().newlinesSanitized.suggestions(sand.state.commandAutoComplete).first,
                               let envCommand = prompts.environmentCommand(first.lowercased().replacingOccurrences(of: "/", with: "")) {
                                switch envCommand {
                                case .reset:
                                    sand.center.reset.send()
                                    environment.center.reset.send()
                                }
                                
                            //Normal command set flow
                            } else if value.newlinesSanitized.isNotEmpty {
                                sand
                                    .center
                                    .setCommand
                                    .send(
                                        SandService
                                            .SetCommand
                                            .Meta(value: value, reset: false))
                            }
                            
                        },
                        lineCountUpdated: { lineCount in
                            guard state.isCommandMenuActive == false else {
                                return
                            }
                            
                            environment
                                .center
                                .queryWindowSize
                                .send(
                                    EnvironmentService
                                        .QueryWindowSizeUpdated
                                        .Meta(lineCount: lineCount))
                        },
                        commandMenuActive: { isActive in
                            center.$state.binding.isCommandMenuActive.wrappedValue = isActive
                            
                            sand
                                .center
                                .activateCommands
                                .send(
                                    SandService
                                        .ActivateCommands
                                        .Meta(isActive: isActive))
                        }
                    )
                    .alert(sand.state.lastError?.message ?? "", isPresented: sand.center.$state.binding.errorExists) {
                        Button("OK", role: .cancel) { }
                    }
                }
                
                if query.state.value.isEmpty {
                    
                    MacEditorTextView(
                        text: .constant(helperText + "..."),
                        isEditable: false,
                        font: Fonts.nsFont(.headline, .regular)
                    )
                    .padding(.leading, 4)
                    .opacity(0.5)
                    .allowsHitTesting(false)
                }
                
//                if SandGPTTokenizerManager.tokenCount > 0 &&
//                    SandGPTTokenizerManager.shared.pause == false {
//                    
//                    VStack {
//                        Spacer()
//                        
//                        HStack {
//                            
//                            Text("\(SandGPTTokenizerManager.shared.tokenCount)/\(maxTokenCount)")
//                                .font(Fonts.live(.caption, .bold))
//                                .foregroundColor((SandGPTTokenizerManager.tokenCount <= maxTokenCount ? Brand.Colors.green : Brand.Colors.red).opacity(0.55))
//                            
//                            Spacer()
//                        }
//                        
//                        Spacer()
//                            .frame(height: WindowComponent.Style.defaultContainerOuterPadding)
//                    }
//                    .allowsHitTesting(false)
//                }
                
            }
        }.overlay(helperView)
    }
}

extension Query {
    var helperView: some View {
        VStack(alignment: .trailing) {
            Spacer()
            
            HStack {
                Spacer()
                
                if query.state.value.isEmpty &&
                   sand.state.isCommandSet == false {
                    AppBlurView(size: .init(24, WindowComponent.Style.defaultElementSize.height),
                                padding: .init(8, 0),
                                tintColor: Brand.Colors.black.opacity(0.3)) {
                        Button {
                            center.$state.binding.isCommandMenuActive.wrappedValue = state.isCommandMenuActive ? false : true
                            sand
                                .center
                                .activateCommands
                                .send(
                                    SandService
                                        .ActivateCommands
                                        .Meta(isActive: state.isCommandMenuActive))
                        } label : {
                            Image(systemName: "command.square\(state.isCommandMenuActive ? ".fill" : "")")
                                .font(Fonts.live(.headline, .bold))
                                .foregroundColor(.foreground)
                                .environment(\.colorScheme, .dark)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .frame(width: 24, height: WindowComponent.Style.defaultElementSize.height)
                    .padding(.trailing, 8)
                } else if query.state.value.isNotEmpty &&
                            environment.state.isCommandActive == false  &&
                            sand.state.isResponding == false {
                    AppBlurView(size: .init(24, WindowComponent.Style.defaultElementSize.height),
                                padding: .init(8, 0),
                                tintColor: Brand.Colors.black.opacity(0.3)) {
                        Button {
                            sand.center.ask.send()
                        } label : {
                            Image(systemName: "arrow.right.square.fill")
                                .font(Fonts.live(.headline, .bold))
                                .foregroundColor(.foreground)
                                .environment(\.colorScheme, .dark)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .frame(width: 24, height: WindowComponent.Style.defaultElementSize.height)
                    .padding(.trailing, 8)
                } else {
                    EmptyView()
                        .allowsHitTesting(false)
                }
            }
            //TODO: hacky, all related to the fact that sand service used to monitor queries
            .onChange(of: sand.center.$state.binding.commandSet.wrappedValue) { newValue in
                if newValue == nil && state.isCommandMenuActive {
                    center.$state.binding.isCommandMenuActive.wrappedValue = false
                }
            }
            
            Spacer()
        }
    }
}
