import Granite
import SandKit
import Foundation

struct CommandToolbar: GraniteComponent {
    @Command var center: Center
    
    @Relay var sand: SandService
    @Relay var prompts: PromptService
    
    var prompt: any BasicPrompt {
        prompts.prompt(sand.state.commandSet) ?? Prompts.Empty()
    }
    
    var command: String {
        sand.state.commandSet ?? "UNKNOWN"
    }
    
    var conditionalsNotVisible: Int {
        prompt.subCommands
            .filter({ $0.subCommandConditional != nil })
            .filter({ sand.state.subCommandSet?[$0.subCommandConditional ?? ""]?.value.id != $0.id })
            .count
    }
    
    var indexOfSCSelected: CGFloat {
        if let index = prompt.subCommands.firstIndex(where: { $0.id == state.scSelected }) {
            let revisedIndex = ((prompt.subCommands.count - 1) - index) - conditionalsNotVisible
            return CGFloat(revisedIndex)
        } else {
            return 0
        }
    }
    
    var subcommandValues: [SubcommandValue] {
        print("[CommandToolbar] selected sc: \(state.scSelected)")
        if let subcommand = prompt.subcommandFor(id: state.scSelected),
           let setSubCommand = sand.state.subCommandSet?[subcommand.id]?.value.id {
            print("[CommandToolbar] value set: \(setSubCommand)")
            return subcommand.values.filter { $0.id != setSubCommand }
        } else {
            return []
        }
    }
}
