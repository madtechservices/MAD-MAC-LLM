import Granite
import SwiftUI
import SandKit

extension CommandToolbar: View {
    public var view: some View {
        VStack {
            Spacer().frame(height: WindowComponent.Style.defaultComponentOuterPaddingContainerAware + WindowComponent.Style.defaultTitleBarHeight)
            
            ZStack(alignment: .trailing) {
                HStack(spacing: 8) {
                    leadingView
                    
                    Spacer()
                    
                    if prompt.hasSubcommand {
                        subcommandsView
                    }
                    
                    trailingView
                    
                }//HStack end, main container
                .frame(height: WindowComponent.Kind.toolbar.defaultSize.height)
                
            }//ZStack end
            .padding(.horizontal, WindowComponent.Style.defaultComponentOuterPadding)
            
            Divider()
                .padding(.horizontal,
                         WindowComponent.Style.defaultContainerOuterPadding)
            
            Spacer()
                .allowsHitTesting(false)
        }.overlayIf(state.toggleDropdown, alignment: .topTrailing) {
            AppBlurView(size: .init(136, 136),
                        padding: .init(.zero),
                        tintColor: Brand.Colors.black.opacity(0.3)) {
                subcommandSelectionView
            }
            .frame(width: 136)
            //`0` is the sc index
            .offset(x: -1*((WindowComponent.Style.defaultElementSize.height + 8) + (indexOfSCSelected * 136) + (indexOfSCSelected * 8)), y: (WindowComponent.Style.defaultElementSize.height - 4) + WindowComponent.Style.defaultComponentOuterPaddingContainerAware + WindowComponent.Style.defaultTitleBarHeight)
            .padding(.horizontal, WindowComponent.Style.defaultComponentOuterPadding)
        }
    }
}

extension CommandToolbar {
    var subcommandSelectionView: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 14)
            ScrollView([.vertical], showsIndicators: false) {
                TableView {
                    subcommandSelectionRows
                }.tableViewStyle(.init(rowHeight: WindowComponent.Style.defaultElementSize.height,
                                       showSeperators: false,
                                       paddingRow: .init(14),
                                       paddingTable: .init(0, 0)))
                .environment(\.colorScheme, .dark)
                
                Spacer().frame(height: 14)
            }
        }
    }
    
    var subcommandSelectionRows: [TableRow] {
        var list: [TableRow] = []
        
        for scv in subcommandValues {
            list.append(
                TableRow(text: .init("\(scv.id)", fontSize: .subheadline)) {
                    sand
                        .center
                        .setSubCommand
                        .send(SandService
                            .SetSubCommand
                            .Meta(id: state.scSelected,
                                  subcommandValueId: scv.id))
                    center.$state.binding.toggleDropdown.wrappedValue.toggle()
                }
            )
        }
        return list
    }
}

extension CommandToolbar {
    var leadingView: some View {
        Group {
            AppBlurView(tintColor: Brand.Colors.black.opacity(0.3)) {
                Text("/" + command.capitalized)
                    .font(Fonts.live(.headline, .bold))
                    .foregroundColor(.foreground)
                    .environment(\.colorScheme, .dark)
            }
            
            
//            AppBlurView(tintColor: (sand.state.tokenCount <= promptType.maxTokens ? Brand.Colors.green : Brand.Colors.red).opacity(0.75)) {
//                Text("\(sand.state.tokenCount)/\(promptType.maxTokens) token limit")
//                    .font(Fonts.live(.subheadline, .bold))
//                    .foregroundColor(.foreground)
//            }
        }
    }
    
    var subcommandsView: some View {
        ScrollView([.horizontal], showsIndicators: false) {
            HStack(spacing: 8) {
                Spacer()
                
                ForEach(prompt.subCommands, id: \.id) { sc in
                    if let conditional = sc.subCommandConditional,
                       sand.state.subCommandSet?[conditional]?.value.id == sc.id {
                        subCommandView(sc)
                    } else if sc.subCommandConditional == nil {
                        subCommandView(sc)
                    }
                }
            }
            .rotationEffect(.init(degrees: 180))
        }
        .rotationEffect(.init(degrees: 180))
        .frame(maxHeight: .infinity)
    }
    
    func subCommandView(_ sc: any AnySubcommand) -> some View {
        HStack(spacing: 8) {
            if sand.state.subCommandSet?[sc.id]?.value.acceptsFile == true {
                fileSelectionView(sc)
            }
            
            AppBlurView(padding: .init(14, 0),
                        tintColor: Brand.Colors.black.opacity(0.3)) {
                HStack {
                    Text(sand.state.subCommandSet?[sc.id]?.value.id ?? "")
                        .font(Fonts.live(.subheadline, .bold))
                        .foregroundColor(.foreground)
                        .environment(\.colorScheme, .dark)
                        .padding(.bottom, 2)
                    
                    Spacer()
                    
                    Image(systemName: "arrowtriangle.\((state.toggleDropdown && sc.id == state.scSelected) ? "up" : "down").fill")
                        .resizable()
                        .frame(width: 9, height: 5)
                        .font(Fonts.live(.subheadline, .bold))
                        .foregroundColor(.foreground)
                        .environment(\.colorScheme, .dark)
                        .animation(.default, value: state.toggleDropdown)
                }
            }
            .frame(width: 136, height: WindowComponent.Style.defaultElementSize.height)
            .onTapGesture {
                center.$state.binding.scSelected.wrappedValue = sc.id
                center.$state.binding.toggleDropdown.wrappedValue.toggle()
            }
        }
    }

    var trailingView: some View {
        IconView(systemName: prompt.iconName,
                 bgColor: prompt.baseColor.opacity(0.75),
                 withBlur: false,
                 withTexture: prompt.isSystemPrompt)
            .frame(width: WindowComponent.Style.defaultElementSize.height,
                   height: WindowComponent.Style.defaultElementSize.height)
    }
}
