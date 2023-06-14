import Granite
import SwiftUI
import SandKit

extension Response: View {
    public var view: some View {
        VStack(spacing: 0) {
//            Spacer().frame(height: 16)
            ZStack {
                if config.state.streamResponse == false && sand.state.isResponding {
                    LoadingView(bgColor: prompt?.baseColor ?? Brand.Colors.purple)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .offset(x: -WindowComponent.Style.defaultComponentOuterPaddingContainerAware)
                }
                
//                MarkdownView(markdown: sand.state.response,
//                             padding: .init(Fonts.Details.from(.defaultResponseSize).actualHeight,
//                                            0,
//                                            Fonts.Details.from(.defaultResponseSize).actualHeight,
//                                            0),
//                             isLazy: config.state.streamResponse) { lineCount in
//                    guard lineCount > 0 && config.state.streamResponse else { return }
//                    environment
//                        .center
//                        .responseWindowSize
//                        .send(
//                            EnvironmentService
//                                .ResponseWindowSizeUpdated
//                                .Meta(lineCount: lineCount))
//                }
//                .environment(\.font, Fonts.live(.defaultResponseSize, .regular))
//                .padding(.horizontal, 4)
////                .animation(
////                    .default,
////                    value: sand.state.response.count
////                )
//                .frame(maxWidth: .infinity,
//                       maxHeight: .infinity)
                
                Markdown(content: sand.center.$state.binding.response)
                    .markdownStyle(
                        MarkdownStyle(
                        padding: 0,
                        paddingTop: 0,
                        paddingBottom: 0,
                        paddingLeft: 0,
                        paddingRight: 0
                      ))
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                if sand.state.responseHelpers.isEmpty == false {
                    ResponseHelperView(helperInfo: sand.state.responseHelpers)
                }
            }
//            Spacer().frame(height: 16)
        }
    }
}

struct LoadingView: View {
    var bgColor: Color
    
    @Relay var config: ConfigService
    
    @State var timer: Timer?
    
    @State var percent: CGFloat = 0.0
    
    var body: some View {
        GeometryReader { proxy in
            
            ZStack(alignment: .leading) {
                bgColor
                    .opacity(0.25)
                    .frame(width: proxy.size.width * percent)
                    .frame(maxHeight: .infinity)
                    .animation(.default, value: percent)
                    .onAppear {
                        timer = Timer
                            .scheduledTimer(withTimeInterval: 3.randomBetween(4),
                                            repeats: true) { timer in
                                
                                percent += 0.05.randomBetween(percent >= 0.5 ? 0.07 : 0.25)
                                
                                if percent >= 1.0 {
                                    timer.invalidate()
                                }
                            }
                    }
                
                if percent >= 0.75 {
                    VStack {
                        Spacer()
                        HStack {
                            VStack(alignment: .leading) {
                                
                                Text("Taking too long?")
                                    .font(Fonts.live(.footnote, .bold))
                                
                                Text("• Depending on the complexity, responses can take 30+ seconds to generate.")
                                    .font(Fonts.live(.caption2, .bold))
                                
                                if config.state.isCustomAPIKeySet {
                                    Text("• Check if your engine settings has a valid engine id and if the engine id is available to your API key.")
                                        .font(Fonts.live(.caption2, .bold))
                                } else if config.state.streamResponse == false {
                                    Text("• Try streaming the response, enable it in settings. Although, sometimes service can be unreliable, trying again helps too.")
                                        .font(Fonts.live(.caption2, .bold))
                                }
                            }
                            Spacer()
                        }
                    }
                    .foregroundColor(.foreground)
                    .padding(8)
                    .opacity(0.75)
                }
            }
        }
    }
}
