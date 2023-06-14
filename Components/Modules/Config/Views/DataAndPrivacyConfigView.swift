//
//  DataAndPrivacyConfigView.swift
//  Nea
//
//  Created by PEXAVC on 5/14/23.
//

import Foundation
import SwiftUI
import Granite

struct DataAndPrivacyConfigView: View {
    @Environment(\.openURL) var openURL
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Data & Privacy")
                    .font(Fonts.live(.title2, .bold))
                    .foregroundColor(.foreground)
                
                Spacer()
            }
            .padding(.bottom, 8)
            
            ScrollView([.vertical]) { 
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Backend-less")
                            .font(Fonts.live(.headline, .bold))
                            .foregroundColor(.foreground)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    
                    Text("Nea stores nothing (ONLY LOCALLY (Delete the app to remove anything you think might be statefully stored (like custom prompts))).")
                        .font(Fonts.live(.subheadline, .regular))
                        .foregroundColor(.foreground)
                }
                .padding(.bottom, 8)
                
                VStack(alignment: .leading, spacing: 8) {
                    
                    HStack {
                        Text("Backend-less?")
                            .font(Fonts.live(.headline, .bold))
                            .foregroundColor(.foreground)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    
                    Text("The only API Nea accesses is ChatGPT.")
                        .font(Fonts.live(.subheadline, .regular))
                        .foregroundColor(.foreground)
                }
                .padding(.bottom, 8)
                
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("They still use user inputs for training, right?")
                            .font(Fonts.live(.headline, .bold))
                            .foregroundColor(.foreground)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    
                    Text("NOT from API usage. (As of 05/18/2023)")
                        .font(Fonts.live(.subheadline, .regular))
                        .foregroundColor(.foreground) + Text(" Read this statement by OpenAI themselves. And yes, Nea DOES NOT and WILL NOT opt in to share data.")
                        .foregroundColor(.accentColor)
                }
                .onTapGesture {
                    if let url = URL(string: "https://openai.com/policies/api-data-usage-policies") {
                        openURL(url)
                    }
                }
                .padding(.bottom, 8)
                
                Group {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("It still says they retain for 30 days for \"abuse\"?")
                                .font(Fonts.live(.headline, .bold))
                                .foregroundColor(.foreground)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        
                        Text("Yes it's the only risk unfortunately. Doubtful it will be used, sensitively they must notify you if so ")
                            .font(Fonts.live(.subheadline, .regular))
                            .foregroundColor(.foreground)/* + Text(" Read (H.R.2701), (Search for the mention of \"30 days\"")
                            .foregroundColor(.accentColor)*/
                        
                        Text("Soon enough, Nea will have a collection of offline models for you to use without internet connection (besides downloading the model itself).\n\n")
                    }
//                    .onTapGesture {
//                        if let url = URL(string: "https://www.congress.gov/bill/118th-congress/house-bill/2701/text/ih?overview=closed&format=txt") {
//                            openURL(url)
//                        }
//                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("If you still prefer OpenAI's chat")
                                .font(Fonts.live(.subheadline, .regular))
                                .foregroundColor(.foreground) + Text(", use this link to learn how to opt out of data usage/collection. (As of 05/18/2023)")
                                .foregroundColor(.accentColor)
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .onTapGesture {
                        if let url = URL(string: "https://help.openai.com/en/articles/7039943-data-usage-for-consumer-services-faq") {
                            openURL(url)
                        }
                    }
                }
            }
            
            Group {
                Spacer()
                
                AppBlurView(tintColor: Brand.Colors.purple.opacity(0.45)) {
                    
                    HStack(spacing: 8) {
                        Button(action: {
                            if let url = URL(string: "mailto:aurelius@stoic.nyc") {
                                openURL(url)
                            }
                        }) {
                            
                            Text("Still have concerns?")
                                .font(Fonts.live(.headline, .bold))
                                .foregroundColor(.foreground)
                        }.buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(16)
    }
}
