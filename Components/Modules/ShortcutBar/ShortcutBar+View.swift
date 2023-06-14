import Granite
import SwiftUI
import SandKit
import Ink
import Cocoa
import WebKit

extension ShortcutBar: View {
    public var view: some View {
        VStack {
            Spacer()
                .allowsHitTesting(false)
            
            HStack {
                IconView(systemName: "arrow.clockwise",
                         bgColor: Brand.Colors.black.opacity(0.3),
                         withBlur: true)
                .frame(width: 40, height: 32)
                .onTapGesture {
                    sand.center.reset.send()
                    environment.center.reset.send()
                }
                
                Spacer()
                
                if (sand.state.isResponding && sand.state.response.isEmpty == false) {
                    ProgressView()
                        .scaleEffect(.init(width: 0.75, height: 0.75))
                } else if sand.state.response.isEmpty == false {
                    copyToClipboardView
                    downloadButtonView
                }
            }
            .frame(height: WindowComponent.Kind.shortcutbar.defaultSize.height)
            .padding(.bottom, WindowComponent.Style.defaultContainerOuterPadding / 2)
        }
    }
}

extension ShortcutBar {
    var copyToClipboardView: some View {
        
        AppBlurView(padding: .init(top: 16,
                                   leading: 16,
                                   bottom: 16,
                                   trailing: 16),
                    tintColor: Brand.Colors.black.opacity(0.3)) {
            Button {
                guard sand.state.response.isEmpty == false else { return }
                
                center.$state.binding.lastCopiedText.wrappedValue = sand.state.response
                let pasteboard = NSPasteboard.general
                pasteboard.declareTypes([.string], owner: nil)
                pasteboard.setString(state.lastCopiedText, forType: .string)
                
            } label : {
                HStack(spacing: 8) {
                    Text(state.lastCopiedText == sand.state.response ? "Copied" : "Copy To Clipboard")
                        .lineLimit(1)
                        .font(Fonts.live(.subheadline, .bold))
                        .foregroundColor(.foreground)
                        .environment(\.colorScheme, .dark)
                    
                    Divider()
                        .padding(.horizontal, 8)
                    
                    IconView(systemName: "doc.on.clipboard\(state.lastCopiedText == sand.state.response ? ".fill" : "")")
                        .frame(width: 24,
                               height: WindowComponent.Style.defaultElementSize.height)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    var downloadButtonView: some View {
        AppBlurView(padding: .init(16),
                    tintColor: Brand.Colors.black.opacity(0.3)) {
            Button {
                guard sand.state.response.isEmpty == false else { return }
                let markdown: String = sand.state.response
                let parser = MarkdownParser()
                let result = parser.parse(markdown)
                
                let panel = NSSavePanel()
                panel.nameFieldLabel = "Save generation as:"
                panel.nameFieldStringValue = "nea-\(Date().asStringWithTime).pdf"
                panel.canCreateDirectories = true
                panel.begin { response in
                    if response == NSApplication.ModalResponse.OK,
                       let fileURL = panel.url {
                        createPDF(htmlString: result.html, url: fileURL)
                    }
                }
                
            } label : {
                HStack(spacing: 8) {
                    Text("Download PDF")
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
    
    public func createPDF(htmlString: String, url: URL) {
        let webView = WebView()
        webView.mainFrame.loadHTMLString(htmlString, baseURL: nil)
        let when = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: when) {
            let printOpts: [NSPrintInfo.AttributeKey : Any] = [NSPrintInfo.AttributeKey.jobDisposition : NSPrintInfo.JobDisposition.save, NSPrintInfo.AttributeKey.jobSavingURL : url]
            let printInfo: NSPrintInfo = NSPrintInfo(dictionary: printOpts)
            printInfo.paperSize = NSMakeSize(595.22, 841.85)
            printInfo.topMargin = 10.0
            printInfo.leftMargin = 10.0
            printInfo.rightMargin = 10.0
            printInfo.bottomMargin = 10.0
            let printOp: NSPrintOperation = NSPrintOperation(view: webView.mainFrame.frameView.documentView, printInfo: printInfo)
            printOp.showsPrintPanel = false
            printOp.showsProgressPanel = false
            printOp.run()
        }
    }
}
