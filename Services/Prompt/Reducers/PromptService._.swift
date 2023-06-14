import Granite

extension PromptService {
    struct Create: GraniteReducer {
        typealias Center = PromptService.Center
        
        struct Meta: GranitePayload {
            let prompt: CustomPrompt
        }
        
        @Payload var meta: Meta?
        
        func reduce(state: inout Center.State) {
            guard let meta = self.meta else { return }
            
            guard state.customPrompts[meta.prompt.customCommand] == nil else {
                return
            }
            
            state.customPrompts[meta.prompt.customCommand] = meta.prompt
        }
    }
    
    struct Modify: GraniteReducer {
        typealias Center = PromptService.Center
        
        struct Meta: GranitePayload {
            let prompt: CustomPrompt
        }
        
        @Payload var meta: Meta?
        
        func reduce(state: inout Center.State) {
            guard let meta = self.meta else { return }
            
            state.customPrompts[meta.prompt.customCommand] = meta.prompt
        }
    }
    
    struct Delete: GraniteReducer {
        typealias Center = PromptService.Center
        
        struct Meta: GranitePayload {
            let prompt: CustomPrompt
        }
        
        @Payload var meta: Meta?
        
        func reduce(state: inout Center.State) {
            guard let meta = self.meta else { return }
            
            state.customPrompts[meta.prompt.customCommand] = nil
        }
    }
}
