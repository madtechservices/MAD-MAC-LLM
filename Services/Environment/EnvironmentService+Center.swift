import Granite
import SwiftUI

extension EnvironmentService {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            var pane: PaneKit<PaneView>? = nil
            var promptStudioPane: PaneKit<PromptStudioPaneView>? = nil
            
            var lastInteraction: Interaction? = nil {
                didSet {
                    print("[EnvironmentService] Last interaction: \(String(describing: lastInteraction))")
                }
            }
            
            var isResponseActive: Bool = false /*{
                WindowManager.Manager.shared.windowSizes[.response] != nil
            }*/
            
            var isCommandActive: Bool = false
            var isCommandToolbarActive: Bool = false
            
            var isDisabled: Bool = false
            
            //This required, since PaneKit changes are actually not observed in Granite States. Most likely because they are of class/NSObject types
            var lastUpdate: Date = .init()
        }
        
        @Event var boot: Boot.Reducer
        @Event var interact: Interact.Reducer
        @Event var reset: Reset.Reducer
        @Event var hotkeyDetected: HotkeyDetected.Reducer
        
        @Event var commandToolbarActivated: CommandToolbarActivated.Reducer
        @Event var commandMenuActivated: CommandMenuActivated.Reducer
        
        @Event var queryWindowSize: QueryWindowSizeUpdated.Reducer
        @Event var responseWindowSize: ResponseWindowSizeUpdated.Reducer
        
        @Store public var state: State
    }
}

extension EnvironmentService {
    func sizeFor(_ kind: WindowComponent.Kind) -> CGSize {
        self.state.pane?.componentStorage[WindowComponent(kind)] ?? kind.defaultSize
    }
    
    var titleBarHeight: CGFloat {
        self.state.pane?.window.titleBarHeight ?? 0
    }
}
