import Granite
import SwiftUI
import SandKit

extension Query: View {
    public var view: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                if session.isLocked {
                    MacEditorTextView(
                        text: .constant(""),
                        isEditable: false,
                        font: Fonts.nsFont(.defaultSize, .bold))
                        .overlay(Color.clear)
                } else {
                    MacEditorTextView(
                        text: sand.query.center.$state.binding.value,
                        placeholderText: " \(helperText)...",
                        autoCompleteText: sand.center.$state.binding.commandAutoComplete,
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
                            guard isCommandMenuActive == false else {
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
                            if isActive && sand.state.commandAutoComplete.isNotEmpty  {
                                return
                            }
                            
                            sand
                                .center
                                .activateCommands
                                .send()
                            
                        }
                    )
                    .alert(sand.state.lastError?.message ?? "", isPresented: sand.center.$state.binding.errorExists) {
                        Button("OK", role: .cancel) { }
                    }
                }
            }
            //Don't let helperView cover text
            .padding(.trailing, 24 + 16)
        }
        //There is a visual bug, which is why we choose to overlay rather than HStack
        //The visual bug is caused by the MountComponent being styled in a way
        //to have the relatively small window height to replicate spotlight search
        .overlay(helperView)
    }
}

extension Query {
    var helperView: some View {
        let canExecute: Bool = environment.state.isCommandActive == false &&  environment.state.isCommandActive == false && sand.query.state.value.isNotEmpty
        let iconName: String = canExecute ? "arrow.right.square.fill" : "command.square\(isCommandMenuActive ? ".fill" : "")"
        
        return VStack(alignment: .trailing) {
            Spacer()
            
            HStack {
                Spacer()
                
                if showHelperView {
                    AppBlurView(size: .init(24, WindowComponent.Style.defaultElementSize.height),
                                padding: .init(8, 0),
                                tintColor: Brand.Colors.black.opacity(0.3)) {
                        Button {
                            if canExecute {
                                sand.center.ask.send()
                            } else {
                                sand
                                    .center
                                    .activateCommands
                                    .send()
                            }
                        } label : {
                            Image(systemName: iconName)
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
            
            Spacer()
        }
    }
}
