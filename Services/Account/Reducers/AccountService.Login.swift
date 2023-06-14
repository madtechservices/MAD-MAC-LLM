import Granite
import AuthenticationServices
//import FirebaseAuth

extension AccountService {
    struct CheckLoginStatus: GraniteReducer {
        typealias Center = AccountService.Center
        
        @Event var subscriptionCheck: CheckSubscriptionStatus.Reducer
        
        func reduce(state: inout Center.State) {
            guard SessionManager.DISABLE_LOGIN == false else {
                AccountManager.disableLogin()
                return
            }
            
            //[CAN REMOVE]
            //Where Login "Could" occur
//            if let user = Auth.auth().currentUser {
//                AccountManager.load(user)
//            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    MenuBarManager.shared.showPopOver()
                }
//            }
        }
    }
    
    struct Login: GraniteReducer {
        typealias Center = AccountService.Center
        
        struct Meta: GranitePayload {
            var authResults: ASAuthorization? = nil
        }
        
        @Payload var meta: Meta?
        
        @Event var complete: LoginComplete.Reducer
        
        func reduce(state: inout Center.State) {
            guard let meta = self.meta,
                  let authResults = meta.authResults else {
                return
            }
            
            if let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential {
                
                guard let appleIDToken = appleIDCredential.identityToken else {
                    return
                }
                
                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                    return
                }
                
                //[CAN REMOVE] Firebase Credential Example
//                let credential = OAuthProvider.credential(withProviderID: "apple.com",
//                                                          idToken: idTokenString,
//                                                          rawNonce: state.nonce)
//
//
//                Auth.auth().signIn(with: credential) { (authResult, error) in
//                    if (error != nil) {
//                        print(error?.localizedDescription as Any)
//                    } else {
//                        complete.send(LoginComplete.Meta(authDataResult: authResult))
//                    }
//                }
            }
        }
    }
    
    struct LoginComplete: GraniteReducer {
        typealias Center = AccountService.Center
        
        struct Meta: GranitePayload {
            //var authDataResult: AuthDataResult? = nil
        }
        
        @Event var subscriptionCheck: CheckSubscriptionStatus.Reducer
        
        @Payload var meta: Meta?
        
        func reduce(state: inout Center.State) {
            //[CAN REMOVE] possible authData result from firebase
            //guard let result = self.meta?.authDataResult else { return }
            
            //AccountManager.load(result.user)
            
            subscriptionCheck.send()
        }
    }
}
