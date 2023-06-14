//
//  Brand.Font.swift
//  Nea
//
//  Created by PEXAVC on 5/11/23.
//

import Foundation
import SwiftUI

extension Font {
    static var defaultFont: Font {
        Fonts.live(.defaultSize, .bold)
    }
    
    static var defaultQueryFont: Font {
        Fonts.live(.defaultSize, .bold)
    }
    
    static var defaultResponseFont: Font {
        Fonts.live(.defaultResponseSize, .regular)
    }
    
    static var defaultSize: CGFloat {
        Fonts.FontSize.defaultSize.value
    }
}
