//
//  GeneralConfigView.swift
//  Nea
//
//  Created by PEXAVC on 5/5/23.
//

import Foundation
import SwiftUI
import Granite
import ServiceManagement
import VaultKit

struct GeneralConfigView: View {
    @Environment(\.openURL) var openURL
    
    @Relay var config: ConfigService
    @Relay var account: AccountService
    
    @SharedObject(SessionManager.id) var session: SessionManager
    
    @State var apiKey: String = ""
    
    @State var useAzure: Bool = false
    
    init() {
        self.useAzure = config.state.engineClass == .azure
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Group {
                HStack {
                    Text("Settings")
                        .font(Fonts.live(.title2, .bold))
                        .foregroundColor(.foreground)
                    
                    Spacer()
                }
                .padding(.bottom, 8)
                
                Text("Behavior")
                    .font(Fonts.live(.headline, .bold))
                    .foregroundColor(.foreground)
                
                HStack {
                    Toggle("Start on launch", isOn: config.center.$state.binding.launchAtLogin)
                    
                    Spacer()
                }
                
                if useAzure == false {
                    HStack {
                        Toggle("Stream response", isOn: config.center.$state.binding.streamResponse)
                        
                        Spacer()
                    }
                }
                
                Text("Engine Class")
                    .font(Fonts.live(.headline, .bold))
                    .foregroundColor(.foreground)
                    .padding(.top, 8)
                
                HStack {
                    Toggle("Azure", isOn: $useAzure)
                    
                    Spacer()
                }
                .padding(.bottom, 8)
                .onChange(of: self.useAzure) { state in
                    if state {
                        config.center.$state.binding.engineClass.wrappedValue = .azure
                    } else {
                        config.center.$state.binding.engineClass.wrappedValue = .openai
                    }
                    
                    session.isCustomAPI(state || config.state.isCustomAPIKeySet)
                }
            }
            
            
//            Text("Accessibility")
//                .font(Fonts.live(.headline, .bold))
//                .foregroundColor(.foreground)
//
//            HStack {
//                Toggle("Visual guide", isOn: config.center.$state.binding.showVisualGuide)
//
//                Spacer()
//            }
//            .padding(.bottom, 8)
            TuningView(updateCustomConfigDirectly: true,
                       config: config.state.customPromptConfig)
            .padding(.top, 8)
            
            Spacer()
            
            if SessionManager.IS_API_ACCESS_ENABLED &&
                config.state.isCustomAPIKeySet == false &&
                useAzure == false {
                
                Text("Custom API Key for OpenAI's ChatGPT")
                    .font(Fonts.live(.headline, .bold))
                    .foregroundColor(.foreground)
                AppBlurView(size: .init(width: 0, height: 60),
                            tintColor: Brand.Colors.black.opacity(0.3)) {
                    MacEditorTextView(
                        text: $apiKey,
                        isEditable: true,
                        font: Fonts.nsFont(.defaultSize, .bold))
                }
                .frame(height: 60)
                
                AppBlurView(tintColor: Brand.Colors.black.opacity(0.3)) {
                    Button(action: {
                        config
                            .center
                            .setAPIKey
                            .send(ConfigService.SetCustomAPIKey.Meta(key: apiKey))
                    }) {
                        Text("Set API Key")
                            .font(Fonts.live(.headline, .bold))
                            .foregroundColor(.foreground)
                    }.buttonStyle(PlainButtonStyle())
                }
                .environment(\.colorScheme, .dark)
                .padding(.bottom, 8)
            }
            
            if config.state.isCustomAPIKeySet && useAzure == false {
                AppBlurView(tintColor: Brand.Colors.red.opacity(0.3)) {
                    
                    Button(action: {
                        config
                            .center
                            .removeAPIKey
                            .send()
                    }) {
                        Text("Delete API Key")
                            .font(Fonts.live(.headline, .bold))
                            .foregroundColor(.foreground)
                    }.buttonStyle(PlainButtonStyle())
                }
                .environment(\.colorScheme, .dark)
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(16)
    }
    
    
}
