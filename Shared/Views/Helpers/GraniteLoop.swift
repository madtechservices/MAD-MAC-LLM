//
//  GraniteLoop.swift
//  stoic (iOS)
//
//  Created by PEXAVC on 3/6/21.
//

import Foundation
import SwiftUI

func GraniteLoop<C: Collection, V: View>(_ list: C, content: (C.Element) -> V) -> AnyView
{
    guard let element = list.first else { return AnyView(EmptyView()) }
    return AnyView(Group {
        content(element)
        GraniteLoop(list.dropFirst(), content: content)
    })
}
