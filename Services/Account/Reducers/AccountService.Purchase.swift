//
//  Account.Subscribe.swift
//  Nea
//
//  Created by PEXAVC on 5/5/23.
//

import Granite
import VaultKit

extension AccountService {
    struct Purchase: GraniteReducer {
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
}
