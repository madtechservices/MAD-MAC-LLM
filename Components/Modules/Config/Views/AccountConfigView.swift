//
//  AccountConfigView.swift
//  Nea
//
//  Created by PEXAVC on 5/5/23.
//

import Foundation
import SwiftUI
import Granite
import GraniteUI
import VaultKit

struct AccountConfigView: View {
    @GraniteAction<Void> var subscribe
    @GraniteAction<Void> var logout
    @GraniteAction<QueryHistory> var queryHistorySelected
    @Environment(\.openURL) var openURL
    
    @SharedObject(SessionManager.id) var session: SessionManager
    
    @Relay var account: AccountService
    @Relay var config: ConfigService
    
    @State var selectedOption: VaultProduct? = VaultManager.shared.productFor(VaultProducts.Renewable.monthly)
    
    @State var reducedPricing: Bool = false
    
    @State var viewSubscription: Bool = true
    
    var body: some View {
        VStack(alignment: .leading) {
            if (VaultManager.isSubscribed || viewSubscription == false || SessionManager.IS_API_ACCESS_ENABLED) {
                standardView
            } else {
                paywallView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(16)
    }
    
    var standardView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Account")
                    .font(Fonts.live(.title2, .bold))
                    .foregroundColor(.foreground)
                
                Spacer()
                
                if VaultManager.isSubscribed == false && SessionManager.IS_API_ACCESS_ENABLED == false {
                    AppBlurView(tintColor: Brand.Colors.yellow.opacity(0.45)) {
                        Button(action: {
                            viewSubscription = true
                        }) {
                            Text("Subscribe")
                                .font(Fonts.live(.headline, .bold))
                                .foregroundColor(.foreground)
                        }.buttonStyle(PlainButtonStyle())
                    }
                    .environment(\.colorScheme, .dark)
                } else if SessionManager.IS_API_ACCESS_ENABLED == false {
                    AppBlurView(tintColor: VaultManager.isSubscribed ? Brand.Colors.purple.opacity(0.45) : Brand.Colors.black.opacity(0.3)) {
                        Text(VaultManager.isSubscribed ? "Subscribed" : "Free")
                            .font(Fonts.live(.headline, .bold))
                            .foregroundColor(.foreground)
                    }
                    .environment(\.colorScheme, .dark)
                }
            }
            .padding(.bottom, 8)
            
            if let purchase = VaultManager.currentPurchase {
                purchaseStats(purchase)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 8)
            }
            
            if let subscription = VaultManager.currentSubscription {
                subscriptionStats(subscription)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 8)
            }
            
            if VaultManager.currentSubscription != nil || VaultManager.currentPurchase != nil {
                Divider()
            }
            
            HStack {
                Text("History")
                    .font(Fonts.live(.headline, .bold))
                    .foregroundColor(.foreground)
                
                Spacer()
                
                Toggle("Store (Local)",
                       isOn: config.center.$state.binding.storeHistory)
                
                if config.state.history.isNotEmpty {
                    AppBlurView(tintColor: Brand.Colors.black.opacity(0.3)) {
                        
                        HStack(spacing: 8) {
                            Button {
                                config.center.$state.binding.history.wrappedValue = []
                            } label: {
                                
                                Text("Clear")
                                    .font(Fonts.live(.headline, .bold))
                                    .foregroundColor(.foreground)
                            }.buttonStyle(PlainButtonStyle())
                            .environment(\.colorScheme, .dark)
                        }
                    }
                }
            }
            
            if config.state.storeHistory {
                HistoryCollectionView(history: config.state.history.reversed())
                    .attach(queryHistorySelected, at: \.queryHistorySelected)
            }
            
            Spacer()
        }
    }
    
    var paywallView: some View {
        Group {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Subscribe")
                        .font(Fonts.live(.title2, .bold))
                        .foregroundColor(.foreground)
                    
                    Spacer()
                    
                    AppBlurView(tintColor: Brand.Colors.black.opacity(0.3)) {
                        Button(action: {
                            viewSubscription = false
                        }) {
                            Text("Back")
                                .font(Fonts.live(.headline, .bold))
                                .foregroundColor(.foreground)
                        }.buttonStyle(PlainButtonStyle())
                    }
                    .environment(\.colorScheme, .dark)
                }
                
                HStack {
                    Text("Base features")
                        .font(Fonts.live(.headline, .bold))
                        .foregroundColor(.foreground)
                    
                    Spacer()
                }
                
                AppBlurView(size: .init(0, 60),
                            tintColor: Brand.Colors.black.opacity(0.3)) {
                    VStack(alignment: .leading, spacing: 8) {
                        
                        Text("• Custom prompt command creation, editing, and sharing in Prompt Studio.")
                            .font(Fonts.live(.subheadline, .regular))
                            .foregroundColor(.foreground)
                    }
                }
                .frame(height: 60)
                .environment(\.colorScheme, .dark)
                .padding(.bottom, 8)
                
                HStack {
                    Text("Subscription features")
                        .font(Fonts.live(.headline, .bold))
                        .foregroundColor(.foreground)
                    
                    Spacer()
                }
                
                AppBlurView(size: .init(0, 120),
                            tintColor: Brand.Colors.black.opacity(0.3)) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("• ChatGPT Client general & prompt command usage.")
                            .font(Fonts.live(.subheadline, .regular))
                            .foregroundColor(.foreground)
                        
                        Text("• Nea engineered prompts and tuning. They update or new ones get added weekly.")
                            .font(Fonts.live(.subheadline, .regular))
                            .foregroundColor(.foreground)
                        
                        Text("• Extended featureset for custom prompts in Prompt Studio.")
                            .font(Fonts.live(.subheadline, .regular))
                            .foregroundColor(.foreground)
                    }
                }
                .frame(height: 120)
                .environment(\.colorScheme, .dark)
                .padding(.bottom, 8)
                
                Group {
                    Spacer()
                    Text("Subscription Plans")
                        .font(Fonts.live(.headline, .bold))
                        .foregroundColor(.foreground)
                        .padding(.bottom, 8)
                    
                    HStack(spacing: 8) {
                        ForEach(VaultManager.productsFor(VaultProducts.Renewable.allCases).ordered) { product in
                            
                            optionView(product)
                        }
                    }
                    .padding(.bottom, 8)
                    
                    if session.isPurchasing {
                        HStack {
                            ProgressView()
                                .padding(.trailing, 8)
                            
                            Text("Purchasing")
                                .font(Fonts.live(.headline, .bold))
                                .foregroundColor(.foreground)
                            
                            Spacer()
                        }
                    } else {
                        AppBlurView(tintColor: Brand.Colors.yellow.opacity(0.45)) {
                            
                            HStack(spacing: 8) {
                                
                                Button(action: {
                                    account
                                        .center
                                        .subscribe
                                        .send(AccountService.Subscribe.Meta(product: selectedOption))
                                }) {
                                    Text("Subscribe")
                                        .font(Fonts.live(.headline, .bold))
                                        .foregroundColor(.foreground)
                                    
                                    Divider()
                                    
                                    Text(selectedOption?.metadata.displayPrice ?? "")
                                        .font(Fonts.live(.subheadline, .bold))
                                        .foregroundColor(.foreground) + //Text(selectedOption?.metadata.isRenewable == true ? "/mo" : "")
                                    Text(selectedOption?.metadata.displaySubscriptionPeriod ?? "")
                                        .font(Fonts.live(.footnote, .regular))
                                        .foregroundColor(.foreground) +
                                    Text(selectedOption?.metadata.displayPromo.isEmpty == true ? "" : " " + (selectedOption?.metadata.displayPromo ?? ""))
                                        .font(Fonts.live(.footnote, .regular))
                                        .foregroundColor(.foreground)
                                }.buttonStyle(PlainButtonStyle())
                            }
                        }
                        .environment(\.colorScheme, .dark)
                    }
                    
                    HStack(spacing: 4) {
                        Text("Privacy Policy")
                            .foregroundColor(.accentColor)
                            .onTapGesture {
                                if let url = URL(string: "") {
                                    openURL(url)
                                }
                            }
                        
                        Text("and")
                            .foregroundColor(.foreground)
                        
                        
                        Text("Terms of Use")
                            .foregroundColor(.accentColor)
                            .onTapGesture {
                                if let url = URL(string: "") {
                                    openURL(url)
                                }
                            }
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    
                }
            }
        }
    }
    
    func optionView(_ product: VaultProduct) -> some View {
        AppBlurView(tintColor: Brand.Colors.black.opacity(0.3)) {
            HStack(spacing: 8) {
                Text(sanitizeDisplayName(product.metadata.displayName))
                    .font(Fonts.live(.headline, .bold))
                    .foregroundColor(.foreground)
                
                if selectedOption == product {
                    Image(systemName: "checkmark")
                        .frame(width: 12, height: 12)
                        .foregroundColor(.foreground)
                }
            }
        }
        .environment(\.colorScheme, .dark)
        .onTapGesture {
            selectedOption = product
        }
    }
    
    func sanitizeDisplayName(_ value: String) -> String {
        return value.replacingOccurrences(of: " Subscription", with: "").replacingOccurrences(of: " Reduced", with: "")
    }
}

extension AccountConfigView {
    func purchaseStats(_ currentPurchase: VaultActiveProduct) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Lifetime API Access")
                    .font(Fonts.live(.headline, .bold))
                    .padding(.vertical, 4)
                    .foregroundColor(Color.orange)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .strokeBorder(Color.orange, lineWidth: 2)
                            .padding(.horizontal, -6)
                    )
                    .padding(.horizontal, 6)
                
                Spacer()
            }
        }
    }
    
    func subscriptionStats(_ currentPurchase: VaultActiveProduct) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Subscription Status")
                    .font(Fonts.live(.headline, .bold))
                    .foregroundColor(.foreground)
                
                Spacer()
            }
            .padding(.bottom, 8)
            
            VStack(alignment: .leading, spacing: 8) {
                if let date = currentPurchase.expirationDate {
                    Text("Expiration Date: ")
                        .font(Fonts.live(.subheadline, .bold))
                        .foregroundColor(.foreground) + Text(date.asString)
                        .font(Fonts.live(.subheadline, .regular))
                        .foregroundColor(.foreground)
                }
                
                Text("Purchase Date: ")
                    .font(Fonts.live(.subheadline, .bold))
                    .foregroundColor(.foreground) + Text(currentPurchase.purchaseDate.asString)
                    .font(Fonts.live(.subheadline, .regular))
                    .foregroundColor(.foreground)
                
                Text("Renews: ")
                    .font(Fonts.live(.subheadline, .bold))
                    .foregroundColor(.foreground) + Text("\(currentPurchase.isRenewable ? "Yes" : "No")")
                    .font(Fonts.live(.subheadline, .regular))
                    .foregroundColor(.foreground)
            }
        }
    }
}
