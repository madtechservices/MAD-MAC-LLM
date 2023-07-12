/**
 *  MacEditorTextView
 *  Copyright (c) Thiago Holanda 2020-2021
 *  https://twitter.com/tholanda
 *
 *  MIT license
 */

import Combine
import SwiftUI
import Carbon

struct MacEditorTextView: NSViewRepresentable {
    @Binding var text: String
    var placeholderText: String = ""
    
    var autoCompleteText: Binding<[String]> = .constant([])
    
    var isEditable: Bool = true
    var font: NSFont?    = Fonts.nsFont(.defaultSize, .bold)
    var textColor: NSColor = Color.foreground.asNSColor
    
    var onEditingChanged: () -> Void       = {}
    var onCommit        : () -> Void       = {}
    var onTabComplete   : (String) -> Void = { _ in }
    var onTextChange    : (String) -> Void = { _ in }
    var lineCountUpdated   : (Int) -> Void = { _  in }
    var commandMenuActive   : (Bool) -> Void = { _  in }
    
    private var isCompletingText: Bool {
        autoCompleteText.isNotEmpty
    }
    
    @State private var lastLineCount: Int = 0
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: Context) -> CustomTextContainerView {
        let textView = CustomTextContainerView(
            text: text,
            isEditable: isEditable,
            font: font,
            textColor: textColor
        )
        textView.delegate = context.coordinator
        textView.setPlaceholder(placeholderText)
        context.coordinator.cDelegate = textView
        textView.layer?.backgroundColor = .clear
        
        return textView
    }
    
    func updateNSView(_ view: CustomTextContainerView, context: Context) {
        view.text = text
        view.selectedRanges = context.coordinator.selectedRanges
        
        if isEditable == false {
            let lineNumbers = view.textView.lineNumbers
            
            if lineNumbers != self.lastLineCount {
                DispatchQueue.main.async {
                    self.lastLineCount = lineNumbers
                    self.lineCountUpdated(max(self.lastLineCount, 1))
                }
            }
        }
        
        DispatchQueue.main.async {
            guard text.starts(with: "/") else {
                context.coordinator.cDelegate?.setPlaceholder(text.isEmpty ? placeholderText : "")
                return
            }
            context.coordinator.autoCompleteTextSuggestions = autoCompleteText.wrappedValue
        }
    }
}

// MARK: - Coordinator

extension MacEditorTextView {
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: MacEditorTextView
        
        weak var cDelegate: CustomTextViewDelegate?
        
        var lastSuggestion: String = ""
        var autoCompleteTextSuggestions: [String] = [] {
            didSet {
                if autoCompleteTextSuggestions.isNotEmpty {
                    isCommandMenuActive = true
                    autoComplete()
                } else if isCommandMenuActive {
                    isCommandMenuActive = false
                    lastSuggestion = ""
                    if parent.text.isEmpty {
                        cDelegate?.setPlaceholder(parent.placeholderText)
                    }
                }
            }
        }
        
        var selectedRanges: [NSValue] = []
        var lastLineCount: Int = 1
        
        var isCommandMenuActive: Bool = false
        var isCompletingText: Bool {
            autoCompleteTextSuggestions.isNotEmpty
        }
        
        init(_ parent: MacEditorTextView) {
            self.parent = parent
        }
        
        func textDidBeginEditing(_ notification: Notification) {
            guard parent.isEditable else { return }
            
            guard let textView = notification.object as? NSTextView else {
                return
            }
            
            self.parent.text = textView.string
            self.parent.onEditingChanged()
        }
        
        func textDidChange(_ notification: Notification) {
            guard parent.isEditable else { return }
            
            guard let textView = notification.object as? NSTextView else {
                return
            }
            
            self.parent.text = textView.string
            self.selectedRanges = textView.selectedRanges
            
            guard self.parent.isEditable else { return }
            
            let updateCommandActive: Bool = (textView.string.prefix(1) == "/" && isCommandMenuActive == false) || (isCommandMenuActive && textView.string.prefix(1) != "/")
            
            if updateCommandActive {
                isCommandMenuActive.toggle()
                self.parent.commandMenuActive(isCommandMenuActive)
            }
            
            if isCommandMenuActive {
                autoComplete()
            } else {
                let lineNumbers = textView.lineNumbers
                if lineNumbers != self.lastLineCount {
                    self.lastLineCount = lineNumbers
                    self.parent.lineCountUpdated(max(self.lastLineCount, 1))
                }
                
                if self.parent.text.isEmpty {
                    cDelegate?.setPlaceholder(parent.placeholderText)
                } else {
                    cDelegate?.setPlaceholder("")
                }
            }
        }
        
        func autoComplete() {
            let text = self.parent.text
            let suggestions: [String] = text.suggestions(autoCompleteTextSuggestions)
            let suggestion = suggestions.first ?? (text.count == 1 ? ("/" + (autoCompleteTextSuggestions.first ?? "")) : "")
            self.lastSuggestion = suggestion
            cDelegate?.setPlaceholder(lastSuggestion)
        }
        
        func textDidEndEditing(_ notification: Notification) {
            guard parent.isEditable else { return }
            
            guard let textView = notification.object as? NSTextView else {
                return
            }
            
            self.parent.text = textView.string
        }
        
        func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            
            if commandSelector == #selector(NSResponder.insertNewline(_:)) {
                if let event = NSApplication.shared.currentEvent,
                   event.modifierFlags.contains(.shift) {
                    return isCommandMenuActive
                } else {
                    
                    if isCommandMenuActive == false {
                        self.parent.onCommit()
                    }
                    
                    return true
                }
            } else if commandSelector == #selector(NSResponder.insertTab(_:)),
                      isCommandMenuActive,
                      textView.string.hasPrefix("/") {
                self.parent.onTabComplete(textView.string.count > 1 ? textView.string : self.lastSuggestion)
                self.lastSuggestion = ""
                return true
            } else {
                return false
            }
        }
    }
}

// MARK: - CustomTextView

protocol CustomTextViewDelegate: class {
    func setPlaceholder(_ text: String)
}

final class CustomTextContainerView: NSView, CustomTextViewDelegate {
    private var isEditable: Bool
    private var font: NSFont?
    private var textColor: NSColor
    private var isCompletingText: Bool = false
    
    weak var delegate: NSTextViewDelegate?
    
    var text: String {
        didSet {
            textView.string = text
        }
    }
    
    var selectedRanges: [NSValue] = [] {
        didSet {
            guard selectedRanges.count > 0 else {
                return
            }
            
            textView.selectedRanges = selectedRanges
        }
    }
    
    private lazy var scrollView: NSScrollView = {
        let scrollView = NSScrollView()
        scrollView.drawsBackground = false
        scrollView.borderType = .noBorder
        scrollView.hasVerticalScroller = false
        scrollView.hasHorizontalRuler = false
        scrollView.autoresizingMask = [.width, .height]
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        
        return scrollView
    }()
    
    var textView: NSTextView {
        textViews.main
    }
    
    lazy var textViews: (main: NSTextView, placeholder: PassthroughNSTextView) = {
        let contentSize = scrollView.contentSize
        let textStorage = NSTextStorage()
        
        
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        
        let textContainer = NSTextContainer(containerSize: scrollView.frame.size)
        textContainer.widthTracksTextView = true
        textContainer.containerSize = NSSize(
            width: contentSize.width,
            height: CGFloat.greatestFiniteMagnitude
        )
        
        layoutManager.addTextContainer(textContainer)
        
        let textView                     = NSTextView(frame: .zero, textContainer: textContainer)
        textView.autoresizingMask        = .width
        textView.backgroundColor         = .clear//NSColor.textBackgroundColor
        textView.delegate                = self.delegate
        textView.drawsBackground         = true
        textView.font                    = self.font
        textView.isEditable              = self.isEditable
        textView.isHorizontallyResizable = false
        textView.isVerticallyResizable   = true
        textView.maxSize                 = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.minSize                 = NSSize(width: 0, height: contentSize.height)
        textView.textColor               = self.textColor
        textView.allowsUndo              = true
        textView.isRichText = false
        
        let defaultWindowHeight = WindowComponent.Style.defaultWindowSize.height
        let midPointY = defaultWindowHeight / 2
        
        textView.textContainerInset = .init(width: 0, height: midPointY - ((self.font?.pointSize ?? 0) / 4))
        
        let ptextContainer = NSTextContainer(containerSize: scrollView.frame.size)
        ptextContainer.widthTracksTextView = true
        ptextContainer.containerSize = NSSize(
            width: contentSize.width,
            height: CGFloat.greatestFiniteMagnitude
        )
        
        let ptextStorage = NSTextStorage()
        
        let playoutManager = NSLayoutManager()
        ptextStorage.addLayoutManager(playoutManager)
        playoutManager.addTextContainer(ptextContainer)
        
        let ptextView                     = PassthroughNSTextView(frame: .zero, textContainer: ptextContainer)
        ptextView.autoresizingMask        = .width
        ptextView.backgroundColor         = .clear//NSColor.textBackgroundColor
        ptextView.delegate                = nil
        ptextView.drawsBackground         = true
        ptextView.isEditable              = false
        ptextView.font                    = self.font
        ptextView.isHorizontallyResizable = false
        ptextView.isVerticallyResizable   = true
        ptextView.maxSize                 = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        ptextView.minSize                 = NSSize(width: 0, height: contentSize.height)
        ptextView.textColor               = self.textColor
        ptextView.alphaValue = 0.5
        ptextView.isSelectable = false
        
        ptextView.textContainerInset = .init(width: 0, height: midPointY - ((self.font?.pointSize ?? 0) / 4))
        
        textView.addSubview(ptextView)
        return (textView, ptextView)
    }()
    
    // MARK: - Init
    init(text: String, isEditable: Bool, font: NSFont?, textColor: NSColor = .labelColor) {
        self.font       = font
        self.isEditable = isEditable
        self.text       = text
        self.textColor = textColor
        
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycle
    
    override func viewWillDraw() {
        super.viewWillDraw()
        
        setupScrollViewConstraints()
        setupTextView()
    }
    
    func setupScrollViewConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor)
        ])
    }
    
    func setupTextView() {
        scrollView.documentView = textView
    }
    
    func setPlaceholder(_ text: String) {
        if self.text.count == 1 && self.text.starts(with: "/") {
            textView.moveToEndOfDocument(nil)
        }
        textViews.placeholder.string = text
    }
}

class PassthroughNSTextView: NSTextView {
    override func hitTest(_ point: NSPoint) -> NSView? {
        return nil
    }
}

//MARK: Line count detection
extension NSTextView {
    var lineNumbers: Int {
        let textView = self
        if let layoutManager = textView.layoutManager,
           let container = textView.textContainer {
            let visibleGlyphRange = layoutManager.glyphRange(forBoundingRect: textView.visibleRect, in: container)
            
            var glyphIndexForStringLine = visibleGlyphRange.location
            
            let firstVisibleGlyphCharacterIndex = layoutManager.characterIndexForGlyph(at: visibleGlyphRange.location)
            
            let newLineRegex = try? NSRegularExpression(pattern: "\n", options: [])
        
            var lineNumber = newLineRegex?.numberOfMatches(in: textView.string, options: [], range: NSMakeRange(0, firstVisibleGlyphCharacterIndex)) ?? 0
            
            //                print("[MacEditorTextView] start: \(lineNumber)")
            //
            //                print("[MacEditorTextView] glyph: \(glyphIndexForStringLine), visible: \(NSMaxRange(visibleGlyphRange))")
            
            var actualLineNumbers = 0
            while glyphIndexForStringLine < NSMaxRange(visibleGlyphRange) {
                
                // Range of current line in the string.
                let characterRangeForStringLine = (textView.string as NSString).lineRange(
                    for: NSMakeRange( layoutManager.characterIndexForGlyph(at: glyphIndexForStringLine), 0 )
                )
                let glyphRangeForStringLine = layoutManager.glyphRange(forCharacterRange: characterRangeForStringLine, actualCharacterRange: nil)
                
                var glyphIndexForGlyphLine = glyphIndexForStringLine
                var glyphLineCount = 0
                
                while ( glyphIndexForGlyphLine < NSMaxRange(glyphRangeForStringLine) ) {
                    
                    var effectiveRange = NSMakeRange(0, 0)
                    let lineRect = layoutManager.lineFragmentRect(forGlyphAt: glyphIndexForGlyphLine, effectiveRange: &effectiveRange, withoutAdditionalLayout: true)
                    
                    glyphLineCount += 1
                    glyphIndexForGlyphLine = NSMaxRange(effectiveRange)
                }
                
                glyphIndexForStringLine = NSMaxRange(glyphRangeForStringLine)
                
                lineNumber += 1
                
                actualLineNumbers += glyphLineCount
            }
            
            return actualLineNumbers
        } else {
            return 0
        }
    }
}
