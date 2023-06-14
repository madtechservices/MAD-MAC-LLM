//
//  PaneKit.Window.swift
//  Nea
//
//  Created by PEXAVC on 5/8/23.
//

import Foundation
import SwiftUI
import Combine
import Granite

extension PaneKit {
    class Window: NSObject, Identifiable, NSWindowDelegate {
        @SharedObject(WindowVisibilityManager.id) var windowVisibility: WindowVisibilityManager
        
        @Published var isPrepared: Bool = false
        
        private var main: AppWindow? = nil
        
        private(set) var lastUpdate: Date = .init()
        
        let size: CGSize
        let useMain: Bool
        let maxSize: CGSize
        let observeEvents: Bool
        private(set) var titleBarHeight: CGFloat = 0
        
        let pubClickedOutside = NotificationCenter.default
            .publisher(for: NSNotification.Name("nyc.stoic.Nea.PaneKitClickedOutside"))
        internal var cancellables = Set<AnyCancellable>()
        
        let id: String
        
        init(id: String,
             useMain: Bool,
             size: CGSize = .init(800, 48),
             maxSize: CGSize = .init(800, 750),
             observeEvents: Bool = false) {
            self.id = id
            self.useMain = useMain
            self.size = size
            self.maxSize = maxSize
            self.observeEvents = observeEvents
            super.init()
        }
        
        func build(title: String? = nil, center: Bool = false) {
            DispatchQueue.main.async { [weak self] in
                self?.main = AppWindow(self?.size ?? .zero, title: title, center: center)
                
                self?.main?.delegate = self
                
                self?.titleBarHeight = self?.main?.titlebarHeight ?? 0
                self?.isPrepared = true
                
                if self?.observeEvents == true {
                    self?.observe()
                }
                
                self?.lastUpdate = .init()
                print("[PaneKit.Window] Built \(self?.lastUpdate)")
            }
        }
        
        func windowWillClose(_ notification: Notification) {
            windowVisibility.close(id: self.id)
        }
        
        func setHost<Content: View>(_ controller: NSHostingController<Content>) {
            self.main?.contentViewController = controller
        }
        
        func setSize(_ size: CGSize) {
            let sizeAdjusted: CGSize = .init(min(maxSize.width, size.width), min(maxSize.height, size.height + (titleBarHeight + WindowComponent.Style.defaultTitleBarHeight)))
            DispatchQueue.main.async { [weak self] in
                self?.main?.setSize(sizeAdjusted, defaultSize: self?.size ?? .zero)
                self?.lastUpdate = .init()
            }
        }
        
        func toggle() {
            if windowVisibility.isVisible(id: self.id) {
                main?.close()
                windowVisibility.close(id: self.id)
            } else {
                main?.level = .floating
                main?.makeKeyAndOrderFront(nil)
                main?.level = .normal
                windowVisibility.open(id: self.id)
            }
        }
        
        func bringToFront() {
            main?.level = .floating
            main?.makeKeyAndOrderFront(nil)
            main?.level = .normal
            windowVisibility.open(id: self.id)
        }
        
        func observe() {
            pubClickedOutside.sink { [weak self] _ in
                guard self?.windowVisibility.isVisible(id: self?.id ?? "") == true else { return }
                
                DispatchQueue.main.async { [weak self] in
                    self?.main?.close()
                    self?.windowVisibility.close(id: self?.id ?? "")
                }
            }.store(in: &cancellables)
        }
        
        func retrieve() -> NSWindow? {
            self.main
        }
    }
}

//MARK: AppWindow class

class AppWindow: NSWindow {
    
    private var lastPoint: CGPoint? = nil
    
    init(_ size: CGSize, title: String? = nil, center: Bool = false) {
        
        let origin = AppWindow.originPoint(size, newSize: .zero, center: center)
        
        super.init(contentRect: .init(origin: origin, size: size),
                   styleMask: [.fullSizeContentView, .titled, .closable],
                   backing: .buffered,
                   defer: false)
        
        self.lastPoint = origin
        
        isReleasedWhenClosed = false
        hasShadow = true
        isOpaque = false
        
//        level = .floating
        backgroundColor = .clear
        
        standardWindowButton(.closeButton)?.isHidden = false
        standardWindowButton(.miniaturizeButton)?.isHidden = true
        standardWindowButton(.zoomButton)?.isHidden = true
        
        titlebarAppearsTransparent = true
        
        if let windowTitle = title {
            self.title = windowTitle
        }
//        titleVisibility = .hidden
    }
    
    static func originPoint(_ size: CGSize, newSize: CGSize, titleBarHeight: CGFloat = 28, currentMidPoint: CGPoint? = nil, center: Bool = false) -> CGPoint {
        guard let main = NSScreen.main else {
            return .zero
        }
        
        let startingContainer: CGSize = .init(size.width, size.height + titleBarHeight)
        let newContainer: CGSize = .init(newSize.width, newSize.height + titleBarHeight)
        
        let visibleFrame = main.visibleFrame
        let startWindowX = (currentMidPoint?.x) ?? ((visibleFrame.midX) - (startingContainer.width / 2))
        let startWindowY = (currentMidPoint?.y) ?? ((visibleFrame.midY) - (startingContainer.height / 2))
//        print("[AppWindow] originPoint: \(visibleFrame)")
        var startPoint: CGPoint = .init(startWindowX, startWindowY)
        
        if newSize != .zero {
            let diff = newContainer.height - startingContainer.height
            
            startPoint.y -= diff
        } else {
            startPoint.y -= visibleFrame.origin.y
        }
        
        if currentMidPoint == nil {
            if center {
                startPoint.y -= size.height / 2
            } else {
                startPoint.y += (visibleFrame.height / 3) / 2
            }
        }
        
        return startPoint
    }
    
    func newPoint(newSize: CGSize,
                  titleBarHeight: CGFloat = 28,
                  currentMidPoint: CGPoint? = nil) -> CGPoint {
        
        let startingContainer: CGSize = frame.size
        let newContainer: CGSize = .init(newSize.width, newSize.height)
        
        var startPoint: CGPoint = lastPoint ?? .zero
        
        if newSize != .zero {
            let diff = newContainer.height - startingContainer.height
            
            startPoint.y -= (diff)
        }
        
        lastPoint = startPoint
        
        return startPoint
    }
    
    func setSize(_ newSize: CGSize, defaultSize: CGSize) {
        lastPoint = frame.origin
        let origin: CGPoint = newPoint(newSize: newSize, titleBarHeight: self.titlebarHeight, currentMidPoint: lastPoint)
        print("[AppWindow] \(lastPoint ?? .zero) new: \(origin)")
        self.setFrame(.init(origin, newSize), display: true)
    }
}

extension NSWindow {
    var titlebarHeight: CGFloat {
        frame.height - contentLayoutRect.height
    }
}
