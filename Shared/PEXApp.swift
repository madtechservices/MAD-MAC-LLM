//
//  PEXApp.swift
//  Shared
//
//  Created by PEXAVC on 7/18/22.
//

import SwiftUI
import Combine
import Granite
import VaultKit

@main
struct PEXApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @Relay var environment: EnvironmentService
    @Relay var account: AccountService
    
    let pubShowHideMount = NotificationCenter.default
        .publisher(for: NSNotification.Name("nyc.stoic.Nea.ShowHideMount"))
    
    let pubShowHidePromptStudio = NotificationCenter.default
        .publisher(for: NSNotification.Name("nyc.stoic.Nea.ShowHidePromptStudio"))
    
    let pubDidFinishLaunching = NotificationCenter.default
        .publisher(for: NSNotification.Name("nyc.stoic.Nea.DidFinishLaunching"))

    internal var cancellables = Set<AnyCancellable>()
    
    init() {
        pubShowHideMount.sink { _ in
            InteractionManager.shared.observeHotkey(kind: .mount)
        }.store(in: &cancellables)
        
        pubShowHidePromptStudio.sink { _ in
            InteractionManager.shared.observeHotkey(kind: .promptStudio)
        }.store(in: &cancellables)
        
        VaultManager.shared.$isSubscribed
            .removeDuplicates()
            .sink { newValue in
            AccountManager.isSubscribed(newValue)
        }.store(in: &cancellables)
        
        VaultManager.shared.$isPurchasing
            .removeDuplicates()
            .sink { newValue in
            AccountManager.isPurchasing(newValue)
        }.store(in: &cancellables)
    }
    
    var body: some Scene {
        WindowGroup {
            Home()
                .onReceive(pubDidFinishLaunching) { _ in
                    
                    environment.center.boot.send()
                    account.center.checkLogin.send()
                    
                    //TODO: DEV
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        InteractionManager.shared.observeHotkey(kind: .mount)
                    }
                }
                .onChange(of: AccountManager.isLoggedIn) { newState in
                    print("[MAIN] isLoggedIn \(newState)")
                }
                .onChange(of: VaultManager.isSubscribed) { newState in
                    print("[MAIN] isSubscribed \(newState)")
                }
        }
    }
}

extension TimeZone {
    var formattedName: String {
        let start = localizedName(for: .generic, locale: .current) ?? "Unknow"
        return "\(start) - \(identifier)"
    }
}
