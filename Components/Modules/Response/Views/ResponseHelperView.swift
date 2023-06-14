//
//  ResponseHelperView.swift
//  Nea (iOS)
//
//  Created by PEXAVC on 5/17/23.
//

import Foundation
import SwiftUI
import Granite

protocol BasicHelper: Identifiable {
    var kind: HelperInfo.Kind { get }
}

extension BasicHelper {
    var id: String { kind.description }
}

struct HelperInfo: BasicHelper, GraniteModel {
    enum Kind: GraniteModel {
        case color(String)
        case link([String])
        
        var description: String {
            switch self {
            case .color(let hex):
                return "color:\(hex)"
            case .link(let urls):
                return "link:\(urls.count)"
            }
        }
    }
    
    let kind: Kind
    
    static func generate(from response: String) -> [HelperInfo] {
        var info: [HelperInfo] = []
        for match in response.match("#(([0-9a-fA-F]{2}){3,4}|([0-9a-fA-F]){3,4})") {
            if match.value.contains("#") {
                info.append(.init(kind: .color(match.value)))
            }
        }
        var links: [String] = []
        for match in response.match("(https?:\\/\\/(?:www\\.|(?!www))[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\\.[^\\s]{2,}|www\\.[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\\.[^\\s]{2,}|https?:\\/\\/(?:www\\.|(?!www))[a-zA-Z0-9]+\\.[^\\s]{2,}|www\\.[a-zA-Z0-9]+\\.[^\\s]{2,})") {
            var value = match.value
            if match.value.hasSuffix(".") {
                value = String(match.value.prefix(match.value.count - 1))
            }
            if value.hasSuffix("/") {
                value = String(value.prefix(value.count - 1))
            }
            if value.count > 3 && value.hasPrefix("/") == false {
                let link: String
                if value.contains("http://") {
                    link = value.replacingOccurrences(of: "http://", with: "https://")
                } else if value.contains("https://") == false {
                    link = "https://\(value)"
                } else {
                    link = value
                }
                links.append(link)
            }
        }
        if links.isNotEmpty {
            info.append(.init(kind: .link(links)))
        }
        
        return info
    }
}

struct ResponseHelperView: View {
    
    var helperInfo: [HelperInfo]
    
    var width: CGFloat {
        let hasLinks: Bool = helperInfo
            .first(where: {
                switch $0.kind {
                case .link:
                    return true
                default:
                    return false
                }
            }
        ) != nil
        
        if hasLinks {
            return 400
        } else {
            return 200
        }
    }
    
    @State var open: Bool = false
    
    var body: some View {
        GeometryReader { geo in
            HStack{
                Spacer()
                
                AppBlurView(size: .init(24, WindowComponent.Style.defaultElementSize.height),
                            padding: .init(8, 0),
                            tintColor: Brand.Colors.black.opacity(0.3)) {
                    Button {
                        open.toggle()
                    } label : {
                        Image(systemName: "arrow.\(open ? "right" : "left").square.fill")
                            .font(Fonts.live(.headline, .bold))
                            .foregroundColor(.foreground)
                            .environment(\.colorScheme, .dark)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .frame(width: 24, height: WindowComponent.Style.defaultElementSize.height)
                
                AppBlurView(size: .init(0, geo.size.height - WindowComponent.Style.defaultComponentOuterPaddingContainerAware * 2),
                            tintColor: Brand.Colors.black.opacity(0.3)) {
                    ScrollView([.vertical], showsIndicators: false) {
                        VStack(spacing: 16) {
                            ForEach(helperInfo) { info in
                                switch info.kind {
                                case .color(let hex):
                                    ColorView(hex: hex)
                                case .link(let links):
                                    if URL(string: links[0]) != nil {
                                        LinkView(links: links)
                                    }
                                }
                            }
                        }.padding(.vertical, 16)
                    }
                    .frame(width: open ? width : 0, height: geo.size.height - WindowComponent.Style.defaultComponentOuterPaddingContainerAware * 2)
                    //.padding(.leading, 4)
                }
                .offset(x: -8)
                .frame(width: open ? width : 0, height: geo.size.height - WindowComponent.Style.defaultComponentOuterPaddingContainerAware * 2)
                .opacity(open ? 1.0 : 0.0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(Animation.easeIn(duration: 0.3), value: open)
        }
    }
}

fileprivate struct ColorView: View {
    let hex: String
    var body: some View {
        VStack(spacing: 8) {
            Circle()
                .foregroundColor(Color(hex: hex))
                .frame(width: 120, height: 120)
            Text(hex)
                .foregroundColor(.foreground)
                .font(Fonts.live(.footnote, .bold))
        }
    }
}

fileprivate struct LinkView: View {
    @Environment(\.openURL) var openURL
    
    let links: [String]
    
    var link: String {
        links[linkIndex]
    }
    
    @State private var linkIndex: Int = 0
    
    @State private var action = WebViewAction.idle
    @State private var state = WebViewState.empty
    @State private var address = ""
    
    var body: some View {
        VStack(spacing: 8) {
            
            Text("Website Preview")
                .font(Fonts.live(.footnote, .bold))
                .foregroundColor(.foreground)
            
            GraniteWebView(action: $action,
                    state: $state,
                    restrictedPages: [],
                    htmlInState: true)
                .frame(height: 360)
                .cornerRadius(6)
                .padding(.horizontal, 16)
            
            HStack {
                VStack(alignment: .leading) {
                    ForEach(links.uniques, id: \.self) { link in
                        AppBlurView(padding: .init(16)) {
                            HStack(spacing: 8) {
                                Text(link.replacingOccurrences(of: "www.", with: "").prefix(24))
                                    .lineLimit(1)
                                    .font(Fonts.live(.subheadline, .bold))
                                    .foregroundColor(.foreground)
                                    .environment(\.colorScheme, .dark)
                                
                                Divider()
                                    .padding(.horizontal, 8)
                                
                                Button {
                                    if let url = URL(string: link) {
                                        action = .load(URLRequest(url: url))
                                    }
                                    
                                } label : {
                                    
                                    Image(systemName: "arrow.right.square")
                                        .font(Fonts.live(.headline, .bold))
                                        .foregroundColor(.foreground)
                                        .environment(\.colorScheme, .dark)
                                        .padding(.bottom, 2)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Divider()
                                    .padding(.horizontal, 8)
                                
                                Button {
                                    if let url = URL(string: link) {
                                        openURL(url)
                                    }
                                    
                                } label : {
                                    
                                    Image(systemName: "globe")
                                        .font(Fonts.live(.headline, .bold))
                                        .foregroundColor(.foreground)
                                        .environment(\.colorScheme, .dark)
                                        .padding(.bottom, 2)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                Spacer()
            }.padding(.horizontal, 16)
        }
        .onAppear {
            print("[Loading link] \(link)")
            if let url = URL(string: link) {
                action = .load(URLRequest(url: url))
            }
        }
    }
}
