//
//  Account.Subscribe.swift
//  Nea
//
//  Created by PEXAVC on 5/5/23.
//

import Granite
import AuthenticationServices
import VaultKit

extension AccountService {
    struct Subscribe: GraniteReducer {
        typealias Center = AccountService.Center
        
        struct Meta: GranitePayload {
            var product: VaultProduct?
        }
        
        @Payload var meta: Meta?
        
        func reduce(state: inout Center.State) {
            guard let meta = self.meta else { return }
            guard let product = meta.product else { return }
            
            VaultManager.purchase(product)
        }
    }
    
    struct CheckSubscriptionStatus: GraniteReducer {
        typealias Center = AccountService.Center
        
        func reduce(state: inout Center.State) {
            VaultManager.restore()
        }
    }
}
