//
//  Interaction.swift
//  Nea
//
//  Created by PEXAVC on 5/6/23.
//

import Granite
import Foundation
import SwiftUI
import Carbon

enum Interaction: GraniteModel {
    case bringToFront(InteractionManager.Kind)
}

class InteractionManager {
    static var shared: InteractionManager = .init()
    
    var popupObserver: ((EnvironmentService.ShowPopup.Meta<PopupView>) -> Void)?
    var closePopupObserver: ((EnvironmentService.ClosePopup.Meta) -> Void)?
    var hotkeyObserver: (() -> Void)?
    var promptStudioHotkeyObserver: (() -> Void)?
    var menubarShowHideMount: (() -> Void)?
    var hotKeyRef: EventHotKeyRef?
    var promptStudioHotkeyRef: EventHotKeyRef?
    var hotKeysRegistered: [UInt32: Kind] = [:]
    
    enum Kind: String, CaseIterable, GraniteModel {
        case mount
        case promptStudio
    }
    
    init() {
        
    }
    
    func setPopupObserver<S: EventExecutable, SC: EventExecutable>(_ reducer: S, closeReducer: SC) {
        popupObserver = { payload in
            reducer.send(payload)
        }
        
        closePopupObserver = { payload in
            closeReducer.send(payload)
        }
    }
    
    func setHotkeyObserver<S: EventExecutable>(_ reducer: S) {
        hotkeyObserver = {
            reducer.send()
        }
    }
    
    func setPromptStudioHotkeyObserver<S: EventExecutable>(_ reducer: S) {
        promptStudioHotkeyObserver = {
            reducer.send()
        }
    }
    
    func showPopup<Content: View>(_ kind: InteractionManager.Kind,
                                  size: CGSize,
                                  bounds: CGRect,
                                  edge: NSRectEdge,
                                  @ViewBuilder content : (@escaping () -> Content)) {
        popupObserver?(EnvironmentService
            .ShowPopup
            .Meta<PopupView>(kind: kind,
                             size: size,
                             bounds: bounds,
                             preferredEdge: edge) {
            PopupView(size: size) {
                content()
            }
        })
    }
    
    func closePopup(_ meta: EnvironmentService.ClosePopup.Meta) {
        closePopupObserver?(meta)
    }
    
    func observeHotkey(_ keyCode: UInt32? = nil, kind: Kind? = nil) {
        if let code = keyCode {
            if hotKeysRegistered[code] == .mount {
                hotkeyObserver?()
            } else if hotKeysRegistered[code] == .promptStudio {
                promptStudioHotkeyObserver?()
            }
        } else if let kind = kind {
            switch kind {
            case .mount:
                hotkeyObserver?()
            case .promptStudio:
                promptStudioHotkeyObserver?()
            }
        }
    }
}

extension InteractionManager {
    func registerHotkey(_ key: HotkeyOptions = .n, kind: Kind = .mount) {
        switch kind {
        case .mount:
            if self.hotKeyRef != nil {
                let status = UnregisterEventHotKey(hotKeyRef)
                NSLog("[InteractionManager] Un registered hotkey successfully")
            }
        case .promptStudio:
            if self.promptStudioHotkeyRef != nil {
                let status = UnregisterEventHotKey(promptStudioHotkeyRef)
                NSLog("[InteractionManager] Un registered prompt studio hotkey successfully")
            }
        }
        
        var hotKeyRef: EventHotKeyRef?
        let modifierFlags: UInt32 =
        getCarbonFlagsFromCocoaFlags(cocoaFlags: NSEvent.ModifierFlags.option)
        
        let keyCode = key.asANSI
        var gMyHotKeyID = EventHotKeyID()
        
        gMyHotKeyID.id = UInt32(keyCode)
        
        hotKeysRegistered[gMyHotKeyID.id] = kind
        
        // Not sure what "swat" vs "htk1" do.
        gMyHotKeyID.signature = OSType("swat".fourCharCodeValue)
        // gMyHotKeyID.signature = OSType("htk1".fourCharCodeValue)
        
        var eventType = EventTypeSpec()
        eventType.eventClass = OSType(kEventClassKeyboard)
        eventType.eventKind = OSType(kEventHotKeyReleased)
        // Install handler.
        
        NSLog("[InteractionManager] Registering")
        InstallEventHandler(GetApplicationEventTarget(), {
            (nextHanlder, theEvent, userData) -> OSStatus in
             var hkCom = EventHotKeyID()
            
             GetEventParameter(theEvent,
                               EventParamName(kEventParamDirectObject),
                               EventParamType(typeEventHotKeyID),
                               nil,
                               MemoryLayout<EventHotKeyID>.size,
                               nil,
                               &hkCom)
            
//            NSLog("Option + S Released!")
            
//            let nc = NotificationCenter.default
//            nc.post(name: Notification.Name("Activate"), object: nil)
            
            InteractionManager.shared.observeHotkey(hkCom.id)
            
            
            return noErr
            /// Check that hkCom in indeed your hotkey ID and handle it.
        }, 1, &eventType, nil, nil)
        
        // Register hotkey.
        let status = RegisterEventHotKey(UInt32(keyCode),
                                         modifierFlags,
                                         gMyHotKeyID,
                                         GetApplicationEventTarget(),
                                         0,
                                         &hotKeyRef)
        
        if status == noErr {
            switch kind {
            case .mount:
                self.hotKeyRef = hotKeyRef
                NSLog("[InteractionManager] Registered hotkey successfully")
            case .promptStudio:
                self.promptStudioHotkeyRef = hotKeyRef
                NSLog("[InteractionManager] Registered prompt studio hotkey successfully")
            }
        } else {
            NSLog("[InteractionManager] error \(status)")
        }
    }
    
    func getCarbonFlagsFromCocoaFlags(cocoaFlags: NSEvent.ModifierFlags) -> UInt32 {
        let flags = cocoaFlags.rawValue
        var newFlags: Int = 0
        
        if ((flags & NSEvent.ModifierFlags.control.rawValue) > 0) {
            newFlags |= controlKey
        }
        
        if ((flags & NSEvent.ModifierFlags.command.rawValue) > 0) {
            newFlags |= cmdKey
        }
        
        if ((flags & NSEvent.ModifierFlags.shift.rawValue) > 0) {
            newFlags |= shiftKey;
        }
        
        if ((flags & NSEvent.ModifierFlags.option.rawValue) > 0) {
            newFlags |= optionKey
        }
        
        if ((flags & NSEvent.ModifierFlags.capsLock.rawValue) > 0) {
            newFlags |= alphaLock
        }
        
        return UInt32(newFlags);
    }
    
    enum HotkeyOptions: String, CaseIterable, Equatable, Codable {
        case a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z
        
        var asANSI: Int {
            switch self {
            case .a:
                return kVK_ANSI_A
            case .b:
                return kVK_ANSI_B
            case .c:
                return kVK_ANSI_C
            case .d:
                return kVK_ANSI_D
            case .e:
                return kVK_ANSI_E
            case .f:
                return kVK_ANSI_F
            case .g:
                return kVK_ANSI_G
            case .h:
                return kVK_ANSI_H
            case .i:
                return kVK_ANSI_I
            case .j:
                return kVK_ANSI_J
            case .k:
                return kVK_ANSI_K
            case .l:
                return kVK_ANSI_L
            case .m:
                return kVK_ANSI_M
            case .n:
                return kVK_ANSI_N
            case .o:
                return kVK_ANSI_O
            case .p:
                return kVK_ANSI_P
            case .q:
                return kVK_ANSI_Q
            case .r:
                return kVK_ANSI_R
            case .s:
                return kVK_ANSI_S
            case .t:
                return kVK_ANSI_T
            case .u:
                return kVK_ANSI_U
            case .v:
                return kVK_ANSI_V
            case .w:
                return kVK_ANSI_W
            case .x:
                return kVK_ANSI_X
            case .y:
                return kVK_ANSI_Y
            case .z:
                return kVK_ANSI_Z
            }
        }
    }
}

extension String {
    /// This converts string to UInt as a fourCharCode
    public var fourCharCodeValue: Int {
        var result: Int = 0
        if let data = self.data(using: String.Encoding.macOSRoman) {
            data.withUnsafeBytes({ (rawBytes) in
                let bytes = rawBytes.bindMemory(to: UInt8.self)
                for i in 0 ..< data.count {
                    result = result << 8 + Int(bytes[i])
                }
            })
        }
        return result
    }
}
