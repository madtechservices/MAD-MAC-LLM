# Nea (macOS)

100% SwiftUI GPT/LLM Client with Prompt Engineering support. With Microsoft's Azure OpenAI functionality.

General Query View           |  Prompt Studio
:-------------------------:|:-------------------------:
![General Query](https://stoic-static-files.s3.us-west-1.amazonaws.com/neatia/demos/simple_query.gif)  | ![Prompt Studio](https://stoic-static-files.s3.us-west-1.amazonaws.com/neatia/demos/prompt_creation.gif)

**Development Roadmap**

![Roadmap](https://pexavc.com/993d6181cdb8d34dd532e78b38a3e21496df0163.png)

[Follow updates here](https://pexavc.com/nea-ios-macos.html)

**Table of Contents**
- [Requirements](#requirements)
- [Swift Packages & Credits](#swift-packages-&-credits)
- [Setting Up Azure OpenAI](#setting-up-azure-openai)
- [Persisting Chat Messages](#persisting-chat-messages)
- [Guide WIP](#guide)
- [FAQ](#FAQ)
- [More Previews](#more-previews)
- [TODO](#TODO)

## Requirements

- `macOS 12.4+`  ***Build passing*** 🟢

## Swift Packages & Credits

- [Granite](https://github.com/pexavc/Granite)
  - This app uses my own design pattern. A decoupling guide will be provided in the repo above. But, should be pretty straightforward overall.
- [VaultKit](https://github.com/pexavc/VaultKit)
- [SwiftGPT](https://github.com/SwiftedMind/GPTSwift) by [@SwiftedMind](https://github.com/SwiftedMind)
- [GPT3-Tokenizer](https://github.com/aespinilla/GPT3-Tokenizer) by [@aespinilla](https://github.com/aespinilla)
- [swiftui-markdown](https://github.com/jaywcjlove/swiftui-markdown) by [@jaywcjlove](https://github.com/jaywcjlove)
- [Ink](https://github.com/JohnSundell/Ink) by [@JohnSundell](https://github.com/JohnSundell)
- [LaunchAtLogin](https://github.com/sindresorhus/LaunchAtLogin) by [@sindresorhus](https://github.com/sindresorhus)
- [PureSwiftUI](https://github.com/CodeSlicing/pure-swift-ui) by [@Brett-Best](https://github.com/Brett-Best)

Locally Diverged
- [SandKit] is a private repo at the moment, diverged a localized version for use. It houses `SwiftGPT` and `swiftui-markdown` from above as well. This kit handles custom prompt/command routing for the applicatoin.

Removed
- [MarqueKit] is a private repo that handles encryption this has been removed and comments show where encryption can take place to safely store data like API Keys. 

## Setting Up Azure OpenAI
1. Enable Azure in Settings

![Enable in settings](README_Assets/5.png)

2. [In SandGPT, setup the config to match your Azure OpenAI Resource/Deployment/ApiKey](https://github.com/pexavc/Nea/tree/main/Services/Sand/Client/SandGPT.swift#L36-L40)

```swift
static var AZURE_CONFIG: ChatGPTAzure.Config {
    .init(apiKey: "...",
          apiVersion: "2023-05-15", //apiVersion not necessary for initialization
          resourceName: "...",
          deploymentName: "...")
}
```

## Persisting Chat Messages
> Repo will be updated to include this out of the box, front-end side, in the future.

Back in SandGPT: 
https://github.com/pexavc/Nea/blob/24fbcfbac23eb7f13b84cdee6307211596ee54d0/Services/Sand/Models/SandGPT.swift#L48

Simply build a flow to store the type `ChatMessage` prior to using the Swift Package.

```swift
private var messages: [ChatMessage] = []
    
func ask<E: EventExecutable>(_ prompt: String,
                             withSystemPrompt systemPrompt: String? = nil,
                             withConfig config: PromptConfig,
                             stream: Bool = false,
                             logMessages: Bool = false,
                             event: E) {
```

Append the user prompt with the role `user`.

```swift
self.messages.append(.init(role: .user, content: prompt)) //add user prompt
```

Append the chat-bot's response with the role `assistant`.
```swift
reply = try await client.ask(messages: self?.messages ?? [],
                                                         withConfig: config)
                            
DispatchQueue.main.async { [weak self] in
    self?.isResponding = false
}
    
if logMessages {
    self?.messages.append(.init(role: .assistant, content: reply))
}
    
event.send(Response(data: reply, isComplete: true, isStream: false))
```

The role `.system` is good for setting a persona prior to message collection.

```swift
self?.messages.append(.init(role: .system, content: "Act as..."))
```

Linking the reset() function in `SandGPT()` to clear messages is helpful too:

```swift
func reset(messages: Bool = false) {
    self.currentTask?.cancel()
    self.reqDebounceTimer?.invalidate()
    self.replyCompletedTimer?.invalidate()
    self.isResponding = false
    
    if messages {
        self.messages = []
    }
}
```    
                           

## Guide

### [PaneKit](https://github.com/pexavc/Nea/tree/main/Services/Environment/Models/PaneKit)
- Window resizing and size management occurs here.

Declaritevly update a single window's size whenever an action requires 

```swift
state.pane?.display {
    WindowComponent(WindowComponent.Kind.query)
    
    if addResponse {
        WindowComponent(WindowComponent.Kind.divider)
        
        WindowComponent(WindowComponent.Kind.response)
        
        WindowComponent(WindowComponent.Kind.spacer)
        
        WindowComponent(WindowComponent.Kind.shortcutbar)
    }
}
```

### [InteractionManager](https://github.com/pexavc/Nea/blob/main/Services/Environment/Models/InteractionManager.swift)
- Popups and Hotkey observation/registration

Example of Using PopupableView to easily trigger popups in any window instance.

```swift
PopupableView(.promptStudio,
              size: .init(200, 200),
              edge: .maxX, {
    RoundedRectangle(cornerRadius: 6)
        .frame(width: 60, height: 60)
        .foregroundColor(Color(hex: promptColor))
}) {
    ColorPicker(hex: $promptColor)
}
.frame(width: 60, height: 60)
```

## FAQ

### Why chat completions over completions for prompts?
- No specific reason besides, finding it to provide better results for my own needs.
- Completions endpoint capability will be added soon along with a toggle to switch between.

## More Previews

Advanced Tuning           |  Helper Tab
:-------------------------:|:-------------------------:
![2.png](README_Assets/4.png) | ![3.png](README_Assets/3.png)

Using Commands           |  Switching Commands
:-------------------------:|:-------------------------:
![Commands1](https://stoic-static-files.s3.us-west-1.amazonaws.com/neatia/demos/commands_1.gif) | ![Commands2](https://stoic-static-files.s3.us-west-1.amazonaws.com/neatia/demos/commands_2.gif)


## TODO

- [x] Clean up Azure OpenAI integration in SwiftGPT.
- [ ] Integrate Azure and chat history properly into main App. Cleanup README after.
- [ ] Completions support along with chat completions.
