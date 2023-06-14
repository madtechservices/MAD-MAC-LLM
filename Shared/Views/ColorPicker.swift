//
//  ColorPicker.swift
//  Nea
//
//  Created by PEXAVC on 5/13/23.
//

import Foundation
import SwiftUI

fileprivate extension UInt8 {
    var hexa: String {
        let value = String(self, radix: 16, uppercase: true)
        return (self < 16 ? "0": "") + value
    }
}

struct ColorPicker: View {
    @GestureState fileprivate var hueState: DragState = .inactive
    @GestureState fileprivate var satBrightState: DragState = .inactive
    @State var hue: Double = 0.5 {
        didSet {
            hex = ColorPicker.toHex(h: hue, s: saturation, b: 1.0 - brightness)
        }
    }
    @State var saturation: Double = 0.5 {
        didSet {
            hex = ColorPicker.toHex(h: hue, s: saturation, b: 1.0 - brightness)
        }
    }
    @State var brightness: Double = 0.5 {
        didSet {
            hex = ColorPicker.toHex(h: hue, s: saturation, b: 1.0 - brightness)
        }
    }
    
    @Binding var hex: String
    
    var gridSize: CGSize = CGSize(width: 200, height: 160)
    var sliderSize: CGSize = CGSize(width: 180, height: 16)
    
    static func toHex<F: BinaryFloatingPoint>(h: F, s: F, b: F) -> String {
        var red, green, blue, i, f, p, q, t: F
        i = (h * 6).rounded(.down)
        f = h * 6 - i
        p = b * (1 - s)
        q = b * (1 - f * s)
        t = b * (1 - (1 - f) * s)
        switch h * 360 {
        case 0..<60, 360: red = b; green = t; blue = p
        case 60..<120: red = q; green = b; blue = p
        case 120..<180: red = p; green = b; blue = t
        case 180..<240: red = p; green = q; blue = b
        case 240..<300: red = t; green = p; blue = b
        case 300..<360: red = b; green = p; blue = q
        default: fatalError()
        }
        
        return ("#" + UInt8(red * 255).hexa + UInt8(green * 255).hexa + UInt8(blue * 255).hexa)
    }
    
    /// Prevent the draggable element from going over its limit
    func limitDisplacement(_ value: Double, _ limit: CGFloat, _ state: CGFloat) -> CGFloat {
        if CGFloat(value)*limit + state > limit {
            return limit
        } else if CGFloat(value)*limit + state < 0 {
            return 0
        } else {
            return CGFloat(value)*limit + state
        }
    }
    /// Prevent values like hue, saturation and brightness from being greater than 1 or less than 0
    func limitValue(_ value: Double, _ limit: CGFloat, _ state: CGFloat) -> Double {
        if value + Double(state/limit) > 1 {
            return 1
        } else if value + Double(state/limit) < 0 {
            return 0
        } else {
            return value + Double(state/limit)
        }
//        return max(0, min(1, Double(state/limit)))
    }
    
    /// Labels for each of the Hue, Saturation and Brightness
    var labels: some View {
        VStack {
            Text("Hue: \(limitValue(self.hue, sliderSize.width, hueState.translation.width))")
            Text("Saturation: \(limitValue(self.saturation, gridSize.width, satBrightState.translation.width))")
            Text("Brightness: \(1-limitValue(self.brightness, gridSize.height, satBrightState.translation.height))")
        }
    }
    
    
    var body: some View {
//        HStack {
//            ZStack {
//                RoundedRectangle(cornerRadius: 20).foregroundColor(Color(hue: limitValue(self.hue, sliderSize.width, hueState.translation.width),
//                                                                         saturation: limitValue(self.saturation, gridSize.width, satBrightState.translation.width),
//                                                                         brightness: 1-limitValue(self.brightness, gridSize.height, satBrightState.translation.height))).aspectRatio(1, contentMode: .fit)
//                labels
//            }
//            VStack {
//                satBrightnessGrid
//                hueSlider
//
//                }.frame(width: 500, height: 500).padding()
//        }.frame(idealWidth: 750, maxWidth: .infinity, idealHeight: 750, maxHeight: .infinity)
        VStack {
            ZStack {
                satBrightnessGrid
                    .frame(width: gridSize.width, height: gridSize.height)
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        
                        Text(hex)
                            .font(Fonts.live(.caption, .bold))
                            .foregroundColor(.foreground.opacity(0.75))
                            .padding(4)
                    }
                }.allowsHitTesting(false)
            }
            .frame(width: gridSize.width, height: gridSize.height)
            
            Spacer()
            HStack {
                Spacer()
                hueSlider
                    .frame(height: 16)
                Spacer()
            }
            Spacer()
        
        }.frame(width: 200, height: 200).padding()
        
    }
    
    
    // MARK: Hue Slider
    
    
    func makeHueColors(stepSize: Double) -> [Color] {
        stride(from: 0, to: 1, by: stepSize).map {
            Color(hue: $0, saturation: 1, brightness: 1)
        }
    }
    
    /// Creates the `Thumb` and adds the drag gesture to it.
    func generateHueThumb(proxy: GeometryProxy) -> some View {
        
        // This gesture sequence is also directly from apples "Composing SwiftUI Gestures"
        let longPressDrag = LongPressGesture(minimumDuration: 0.05)
            .sequenced(before: DragGesture())
            .updating($hueState) { value, state, transaction in
                switch value {
                // Long press begins.
                case .first(true):
                    state = .pressing
                // Long press confirmed, dragging may begin.
                case .second(true, let drag):
                    state = .dragging(translation: drag?.translation ?? .zero)
                // Dragging ended or the long press cancelled.
                default:
                    state = .inactive
                }
        }
        .onEnded { value in
            guard case .second(true, let drag?) = value else { return }
            
            self.hue = self.limitValue(self.hue, proxy.size.width, drag.translation.width)
            
        }
        
        
        // MARK: Customize Thumb Here
        // Add the gestures and visuals to the thumb
        return Circle().overlay(hueState.isDragging ? Circle().stroke(Color.white, lineWidth: 2) : nil)
            .foregroundColor(.white)
            .frame(width: 16, height: 16, alignment: .center)
            .position(x: limitDisplacement(self.hue, proxy.size.width, hueState.translation.width) , y: sliderSize.height/2)
            .animation(.interactiveSpring())
            .gesture(longPressDrag)
    }
    
    var hueSlider: some View {
        GeometryReader { (proxy: GeometryProxy) in
            LinearGradient(gradient: Gradient(colors: self.makeHueColors(stepSize: 0.05)),
                           startPoint: .leading, endPoint: .trailing).mask(Capsule()).frame(width: self.sliderSize.width, height: self.sliderSize.height).drawingGroup()
            .overlay(self.generateHueThumb(proxy: proxy))
        }
    }
    
    
    // MARK: Saturation and Brightness Grid
    
    
    func makeSatBrightColors(stepSize: Double) -> [Color] {
        stride(from: 0, to: 1, by: stepSize).map {
            Color(hue: limitValue(self.hue, self.sliderSize.width, hueState.translation.width),
                  saturation: $0,
                  brightness: 1-$0)
        }
    }
    
    /// Creates the `Handle` and adds the drag gesture to it.
    func generateSBHandle(proxy: GeometryProxy) -> some View {
        
        // This gesture sequence is also directly from apples "Composing SwiftUI Gestures"
        let longPressDrag = LongPressGesture(minimumDuration: 0.05)
            .sequenced(before: DragGesture())
            .updating($satBrightState) { value, state, transaction in
                switch value {
                // Long press begins.
                case .first(true):
                    state = .pressing
                // Long press confirmed, dragging may begin.
                case .second(true, let drag):
                    state = .dragging(translation: drag?.translation ?? .zero)
                // Dragging ended or the long press cancelled.
                default:
                    state = .inactive
                }
        }
        .onEnded { value in
            guard case .second(true, let drag?) = value else { return }
            
            self.saturation = max(0, min(1.0, drag.location.x / proxy.size.width))
            //self.limitValue(self.saturation, proxy.size.width, drag.translation.width)
            self.brightness = max(0, min(1.0, drag.location.y / proxy.size.height))
            //self.limitValue(self.brightness, proxy.size.height, drag.translation.height)
        }
        
        
        // MARK: Customize Handle Here
        // Add the gestures and visuals to the handle
        return Circle().overlay(satBrightState.isDragging ? Circle().stroke(Color.white, lineWidth: 2) : nil)
            .foregroundColor(.white)
            .frame(width: 16, height: 16, alignment: .center)
            .position(x: limitDisplacement(self.saturation, self.gridSize.width, self.satBrightState.translation.width) , y: limitDisplacement(self.brightness, self.gridSize.height, self.satBrightState.translation.height))
            .gesture(longPressDrag)
    }
    
    var satBrightnessGrid: some View {
        GeometryReader { (proxy: GeometryProxy) in
            LinearGradient(gradient: Gradient(colors: self.makeSatBrightColors(stepSize: 0.05)),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
            .frame(width: self.gridSize.width,
                   height: self.gridSize.height)
            .overlay(self.generateSBHandle(proxy: proxy))
        }
        .frame(width: self.gridSize.width,
               height: self.gridSize.height)
    }
}

/// Drag State describing the combination of a long press and drag gesture.
///  - seealso:
///  [Reference]: https://developer.apple.com/documentation/swiftui/gestures/composing_swiftui_gestures "Composing SwiftUI Gestures "
fileprivate enum DragState {
    case inactive
    case pressing
    case dragging(translation: CGSize)
    
    var translation: CGSize {
        switch self {
        case .inactive, .pressing:
            return .zero
        case .dragging(let translation):
            return translation
        }
    }
    
    var isActive: Bool {
        switch self {
        case .inactive:
            return false
        case .pressing, .dragging:
            return true
        }
    }
    
    var isDragging: Bool {
        switch self {
        case .inactive, .pressing:
            return false
        case .dragging:
            return true
        }
    }
}
