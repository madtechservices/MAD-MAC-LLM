//
//  Fonts.swift
//  * stoic (iOS)
//
//  Created by PEXAVC on 12/20/20.
//

import Foundation
import SwiftUI

extension NSFont {
    var actualHeight: CGFloat {
        let mainFont: CGFloat = self.pointSize
        let boundingRectDiff: CGFloat = (self.boundingRectForFont.height - mainFont)
        return self.boundingRectForFont.height//mainFont + boundingRectDiff
    }
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: NSFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
    
        return ceil(boundingBox.height)
    }
}

public struct Fonts {
    public static func live(_ size: FontSize, _ weight: FontWeight) -> Font {
        .system(size: size.value, weight: weight.textWeight)
//        .system(size.textStyle, design: nil, weight: weight.textWeight)
//        return Font.custom(
//            "\(FontType.menlo.rawValue)-\(weight.rawValue)",
//            size: size.value,
//            relativeTo: size.textStyle)
    }
    
    
    public static func nsFont(_ size: FontSize, _ weight: FontWeight) -> NSFont {
        NSFont.systemFont(ofSize: size.value, weight: weight.textWeightNS)
        
    }
    
    struct Details {
        let boundingRect: NSRect
        let boundingRectDiff: CGFloat
        let lineHeight: CGFloat
        let actualHeight: CGFloat
        
        static func from(_ size: FontSize, weight: FontWeight = .regular) -> Details {
            let value = size.value
            let font = Fonts.nsFont(size, weight)
            let boundingRect = font.boundingRectForFont
            let lineHeight = value
            let diff = boundingRect.height - lineHeight
            
            return .init(boundingRect: boundingRect,
                         boundingRectDiff: diff,
                         lineHeight: lineHeight,
                         actualHeight: font.actualHeight)
        }
    }
    
    public enum FontSize: String, CaseIterable {
        case largeTitle
        case title
        case title2
        case title3
        case headline
        case body
        case callout
        case subheadline
        case footnote
        case caption
        case caption2
        
        static var defaultSize: FontSize {
            .headline
        }
        
        static var defaultResponseSize: FontSize {
            .headline
        }
        
        var value: CGFloat {
            switch self {
            case .largeTitle:
                return 34
            case .title:
                return 28
            case .title2:
                return 22
            case .title3:
                return 20
            case .headline:
                return 16
            case .body:
                return 17
            case .callout:
                return 16
            case .subheadline:
                return 14
            case .footnote:
                return 12
            case .caption:
                return 12
            case .caption2:
                return 11
            }
        }
        
        var textStyle: Font.TextStyle {
            switch self {
            case .largeTitle:
                return .largeTitle
            case .title:
                return .title
            case .title2:
                return .title2
            case .title3:
                return .title3
            case .headline:
                return .headline
            case .body:
                return .body
            case .callout:
                return .callout
            case .subheadline:
                return .subheadline
            case .footnote:
                return .footnote
            case .caption:
                return .caption
            case .caption2:
                return .caption2
            }
        }
        
        var textStyleNS: NSFont.TextStyle {
            switch self {
            case .largeTitle:
                return .largeTitle
            case .title:
                return .title1
            case .title2:
                return .title2
            case .title3:
                return .title3
            case .headline:
                return .headline
            case .body:
                return .body
            case .callout:
                return .callout
            case .subheadline:
                return .subheadline
            case .footnote:
                return .footnote
            case .caption:
                return .caption1
            case .caption2:
                return .caption2
            }
        }
    }
    
    public enum FontWeight: String {
        case bold = "Bold"
        case boldItalic = "BoldItalic"
        case regular = "Regular"
        case italic = "Italic"
        
        var textWeight: Font.Weight {
            switch self {
            case .bold:
                return .bold
            default:
                return .regular
            }
        }
        
        var textWeightNS: NSFont.Weight {
            switch self {
            case .bold:
                return .bold
            default:
                return .regular
            }
        }
    }
    
    public enum FontType: String {
        case menlo = "Menlo"
    }
}


