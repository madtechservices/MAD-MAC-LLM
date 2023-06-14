//
//  AccountManager.swift
//  Nea
//
//  Created by PEXAVC on 5/12/23.
//

import Foundation
import Combine
import Granite

public class AccountKit {
    
    //[CAN REMOVE] example user object, possibly from Firebase
    public struct User {
        let uid: UUID = .init()
    }
    
    private(set) var id: String? = nil {
        didSet {
            isLoggedIn = id != nil
        }
    }
    
    @Published var isLoggedIn: Bool = false
    @Published var isSubscribed: Bool = false
    
    init() {
        self.id = nil
    }
    
    func load(_ user: User) {
        self.id = user.uid.uuidString
    }
    
    func isSubscribed(_ state: Bool) {
        self.isSubscribed = state
    }
    
    func logout() {
        self.id = nil
    }
}

public class AccountManager: ObservableObject {
    static let shared: AccountManager = .init()
    
    @SharedObject(SessionManager.id) var session: SessionManager
    
    internal var cancellables = Set<AnyCancellable>()
    
    let kit: AccountKit
    
    init() {
        kit = .init()
        observe()
    }
    
    private func observe() {
        kit.$isLoggedIn
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] newValue in
                
            print("[AccountManager] isLoggedIn Changed: \(newValue)")
            self?.objectWillChange.send()
            self?.session.isLoggedIn(newValue)
        }.store(in: &cancellables)
        
        kit.$isSubscribed
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] newValue in
                
            print("[AccountManager] isSubscribed Changed: \(newValue)")
            self?.objectWillChange.send()
            self?.session.isSubscribed(newValue)
        }.store(in: &cancellables)
    }
    
    public static func load(_ user: AccountKit.User) {
        AccountManager.shared.kit.load(user)
    }
    
    public static func logout() {
        AccountManager.shared.kit.logout()
    }
    
    public static var isLoggedIn: Bool {
        AccountManager.shared.kit.isLoggedIn
    }
    
    public static func disableLogin() {
        AccountManager.shared.kit.isLoggedIn = SessionManager.DISABLE_LOGIN
    }
    
    public static func isSubscribed(_ state: Bool) {
        AccountManager.shared.kit.isSubscribed(state)
    }
    
    public static func isPurchasing(_ state: Bool) {
        AccountManager.shared.session.isPurchasing(state)
    }
}
