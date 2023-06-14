import Granite
import SwiftUI
import AuthenticationServices
import SandKit

extension Config: View {
    
    public var view: some View {
        VStack {
            if session.isLoggedIn {
                mainView
            } else {
                signInView
                    .toolbar {
                    ToolbarItem(placement: .principal) {
                        Button {
                        } label: {
                            Label {
                                Text("General")
                            } icon: {
                                Image (systemName: "gearshape")
                            }//custom label style
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var mainView: some View {
        NavigationView {
            List {
                Group {
                    
                    if SessionManager.IS_API_ACCESS_ENABLED {
                        Text("\(config.state.isCustomAPIKeySet ? "Personal API" : "Set API Key")")
                            .font(Fonts.live(.footnote, .bold))
                            .padding(.vertical, 4)
                            .foregroundColor(config.state.isCustomAPIKeySet ? Color.orange : Color.purple)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .strokeBorder(config.state.isCustomAPIKeySet ? Color.orange : Color.purple, lineWidth: 2)
                                    .padding(.horizontal, -6)
                            )
                            .padding(.horizontal, 6)
                            .onTapGesture {
                                config.center.$state.binding.isSettingsActive.wrappedValue = true
                            }
                    }
                    
                    HStack(spacing: 4) {
                        Label(windowVisibility.isVisible(id: InteractionManager.Kind.mount.rawValue) ? "Hide" : "Show",
                              systemImage: windowVisibility.isVisible(id: InteractionManager.Kind.mount.rawValue) ? "eye.slash" : "eye")
                        Text("(⌥ + \(config.state.mountHotkey.rawValue.capitalized))")
                            .font(Fonts.live(.caption2, .bold))
                        Spacer()
                    }
                    .frame(width: 160)
                    .onTapGesture {
                        let nc = NotificationCenter.default
                        nc.post(name: Notification.Name("nyc.stoic.Nea.ShowHideMount"), object: nil)
                    }
                }
                
                Spacer()
                
                Group{
                    Text("General")
                    NavigationLink(destination:
                                    AccountConfigView()
                        .attach( { queryHistorySelected in
                            sand.center.restore.send(SandService.Restore.Meta(history: queryHistorySelected))
                        }, at: \.queryHistorySelected)
                        .attach(account.center.subscribe, at: \.subscribe),
                                   isActive: config.center.$state.binding.isAccountTabActive) {
                        Label("Account", systemImage: "person")
                    }
                    
                    NavigationLink(destination: GeneralConfigView(), isActive: config.center.$state.binding.isSettingsActive) {
                        Label("Settings", systemImage: "gear")
                    }
                }
                Spacer()
                
                
                Group {
                    Text("Customize")
                    NavigationLink(destination: PromptConfigView()) {
                        HStack(spacing: 4) {
                            Label("Prompts", systemImage: "note.text")
                            
                            Text("(⌥ + \(config.state.promptStudioHotkey.rawValue.capitalized))")
                                .font(Fonts.live(.caption2, .bold))
                            Spacer()
                        }
                        .frame(width: 160)
                    }
                    
                    NavigationLink(destination: ShortcutConfigView()) {
                        Label("Shortcuts", systemImage: "option")
                    }
                }
                Spacer()
                
                Group {
                    Text("Info")
                    NavigationLink(destination: DataAndPrivacyConfigView(), isActive: config.center.$state.binding.isDataPrivacyTabActive) {
                        Label("Data & Privacy", systemImage: "lock.shield")
                    }
                    NavigationLink(destination: AboutConfigView()) {
                        Label("About", systemImage: "questionmark.circle")
                    }
                }
                Spacer()
                
                //Divider also looks great!
                Divider()
                Group {
                    if SessionManager.DISABLE_LOGIN == false {
                        Label("Logout", systemImage: "togglepower")
                            .onTapGesture(account.center.logout)
                    }
                    
                    Text("Quit")
                        .onTapGesture { NSApp.terminate(self) }
                }
            }
            .listStyle(SidebarListStyle())
            //Set Sidebar Width (and height)
            .frame(minWidth: 160, idealWidth: 250, maxWidth: 300)
        }
    }
    
    var signInView: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 16) {
                    LogoView()
                        .frame(width: 120, height: 120)
                    
                    AppBlurView(size: .init(width: 0, height: 80),
                                tintColor: Brand.Colors.black.opacity(0.3)) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Nea")
                                .font(Fonts.live(.title2, .bold))
                                .foregroundColor(.foreground)
                            
                            Text("New sight.")
                                .font(Fonts.live(.headline, .regular))
                                .foregroundColor(.foreground)
                        }
                    }
                    .environment(\.colorScheme, .dark)
                    
                    Spacer()
                }
                .padding(.top, WindowComponent.Style.defaultComponentOuterPadding)
                .padding(.horizontal, WindowComponent.Style.defaultComponentOuterPadding)
                
//                AppBlurView(size: .init(0, 200),
//                            tintColor: Brand.Colors.black.opacity(0.3)) {
//                    VStack(alignment: .leading, spacing: 8) {
//                        Text("Nea turns the world of AI chat bots into an easy to access shortcut on your Mac.\n\n(⌥ + N) and get an answer that could jump start a workflow, remove writer's block, or help with that job hunt.\n")
//                            .font(Fonts.live(.headline, .regular))
//                            .foregroundColor(.foreground)
//
//                        Text("Sign-in and pick a membership plan to get started.")
//                            .font(Fonts.live(.headline, .regular))
//                            .foregroundColor(.foreground)
//                    }
//                }
//                .environment(\.colorScheme, .dark)
                
                Text("Sign in")
                    .font(Fonts.live(.headline, .bold))
                    .foregroundColor(.foreground)
                    .padding(.horizontal, WindowComponent.Style.defaultComponentOuterPadding)
                
                SignInWithAppleButton(.signIn) { request in
                    request.requestedScopes = [ .email, .fullName ]
                    request.nonce = account.sha256(account.randomNonceString())
                    MenuBarManager.shared.maintainPopover = true
                } onCompletion: { result in
                    switch result {
                    case .success(let authResults):
                        account.center.login.send(AccountService.Login.Meta(authResults: authResults))
                    default:
                        break
                    }
                    
                    MenuBarManager.shared.maintainPopover = false
                }
                .padding(.horizontal, WindowComponent.Style.defaultComponentOuterPadding)
                .padding(.bottom, WindowComponent.Style.defaultComponentOuterPadding)
            }
            
//            VStack {
//                MarqueeTextView(
//                    text: Prompts.allCases.map({ "/"+$0.rawValue.capitalized+"..." }).joined(separator: "   "),
//                    fontSize: .headline,
//                    fontWeight: .bold,
//                    leftFade: 16,
//                    rightFade: 16,
//                    startDelay: 3
//                )
//                .frame(width: 360)
//                Spacer()
//            }
//            .rotationEffect(.degrees(90))
        }
    }
}
