import Granite
import SwiftUI

extension PromptStudio: View {
    public var view: some View {
        Group {
            switch state.intent {
            case .collection:
                PromptStudioCollectionView()
                    .attach({
                        center.$state.binding.intent.wrappedValue = .create
                    }, at: \.createPrompt)
                    .attach({ prompt in
                        center.$state.binding.intent.wrappedValue = .edit(prompt)
                    }, at: \.editPrompt)
            case .create:
                PromptStudioEditorView()
                    .attach({
                        center.$state.binding.intent.wrappedValue = .collection
                    }, at: \.closeCreatePrompt)
            case .edit(let prompt):
                PromptStudioEditorView(prompt)
                    .attach({
                        center.$state.binding.intent.wrappedValue = .collection
                    }, at: \.closeCreatePrompt)
            }
        }
    }
}
