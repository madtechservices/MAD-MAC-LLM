//
//  MenuBarManager.swift
//  Nea
//
//  Created by PEXAVC on 5/5/23.
//

import Foundation
import SwiftUI

class MenuBarManager: NSObject, NSMenuDelegate {
    static let shared: MenuBarManager = .init()
    
    var popover = NSPopover()
    var statusItem: NSStatusItem?
    var menu = NSMenu()
    
    var mountIsClosed: Bool = false
    
    var maintainPopover: Bool = false
    
    func setup() {
        statusItem = iconView

//        NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
//        statusItem?.button?.title = "Nea"
        
        statusItem?.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
        
        let contentView = Config()
        popover.contentSize = WindowComponent.Kind.config.defaultSize
        popover.contentViewController = NSHostingController(rootView: contentView)
        
        NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) {
            [weak self] event in
            
            let nc = NotificationCenter.default
            nc.post(name: Notification.Name("nyc.stoic.Nea.PaneKitClickedOutside"), object: nil)
            
            guard MenuBarManager.shared.maintainPopover == false else { return }
            self?.popover.performClose(event)
        }
    }
    
    func statusBarClicked(_ event: NSEvent) {
        if event.type ==  NSEvent.EventType.rightMouseUp {
            popover.performClose(self)
            statusItem?.popUpMenu(menu)
        } else {
            if  popover.isShown == false {
                showPopOver()
            } else {
                popover.performClose(self)
            }
        }
    }
    
    func showPopOver() {
        guard let statusBarButton = statusItem?.button else { return }
        print("{TEST} showing popover")
        popover.show(relativeTo: statusBarButton.bounds,
                     of: statusBarButton,
                     preferredEdge: .maxY)
    }
    
    var iconView: NSStatusItem {
        // Status bar icon SwiftUI view & a hosting view.
        //
        let iconSwiftUI = ZStack(alignment:.center) {
            
            Image("logo_menubar")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 16, maxHeight: 16,  alignment: .center)
        }
        
        // Adding content view to the status bar
        //
        let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        
        let iconView = NSHostingView(rootView: iconSwiftUI)
        iconView.frame = NSRect(x: 0, y: 0, width: 40, height: 22)
        
        // Adding the status bar icon
        //
        statusItem.button?.addSubview(iconView)
        statusItem.button?.frame = iconView.frame
        
        
        
        return statusItem
    }
}
