//
//  PaneKit.Display.swift
//  Nea
//
//  Created by PEXAVC on 5/8/23.
//

import Foundation

extension PaneKit {
    public func display(@WindowComponentBuilder components : @escaping () -> [WindowComponent]) {
        var width: CGFloat = 0
        var height: CGFloat = 0
        
        print("[PaneKit] ---------------------- Display")
        
        for component in components() {
            var size: CGSize
            
            if let componentSize = component.size {
                size = componentSize
            } else {
                size = componentStorage[component] ?? component.defaultSize
            }
            
            size.width += component.addSize.width
            size.height += component.addSize.height
            
            componentStorage[component] = size
            
            width = max(width, size.width)
            height += size.height
            
            print("[PaneKit] Size for: {\(component.id)} // \(size)")
        }
        
        print("[PaneKit] ------------------------------")
        
        window.setSize(.init(width: width, height: height))
        
        self.lastUpdate = .init()
    }
}
