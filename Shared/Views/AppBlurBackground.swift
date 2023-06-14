import Foundation
import SwiftUI

//MARK: Visual Effect

struct VisualEffectMaterialKey: EnvironmentKey {
    typealias Value = NSVisualEffectView.Material?
    static var defaultValue: Value = nil
}

struct VisualEffectBlendingKey: EnvironmentKey {
    typealias Value = NSVisualEffectView.BlendingMode?
    static var defaultValue: Value = nil
}

struct VisualEffectEmphasizedKey: EnvironmentKey {
    typealias Value = Bool?
    static var defaultValue: Bool? = nil
}

extension EnvironmentValues {
    var visualEffectMaterial: NSVisualEffectView.Material? {
        get { self[VisualEffectMaterialKey.self] }
        set { self[VisualEffectMaterialKey.self] = newValue }
    }
    
    var visualEffectBlending: NSVisualEffectView.BlendingMode? {
        get { self[VisualEffectBlendingKey.self] }
        set { self[VisualEffectBlendingKey.self] = newValue }
    }
    
    var visualEffectEmphasized: Bool? {
        get { self[VisualEffectEmphasizedKey.self] }
        set { self[VisualEffectEmphasizedKey.self] = newValue }
    }
}


struct VisualEffectBackground: NSViewRepresentable {
    let overlayColor: Color
    private let material: NSVisualEffectView.Material
    private let blendingMode: NSVisualEffectView.BlendingMode
    private let isEmphasized: Bool
    
    init(
        overlayColor: Color = Color.white.opacity(0.1),
        material: NSVisualEffectView.Material = .fullScreenUI,
        blendingMode: NSVisualEffectView.BlendingMode = .behindWindow,
        emphasized: Bool = true) {
        self.overlayColor = overlayColor
        self.material = material
        self.blendingMode = blendingMode
        self.isEmphasized = emphasized
    }
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        
        let overlayView = NSView()
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.wantsLayer = true
        overlayView.layer?.backgroundColor = overlayColor.cgColor
        view.addSubview(overlayView)
        
        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
        
        // Not certain how necessary this is
        view.autoresizingMask = [.width, .height]
        
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = context.environment.visualEffectMaterial ?? material
        nsView.blendingMode = context.environment.visualEffectBlending ?? blendingMode
        nsView.isEmphasized = context.environment.visualEffectEmphasized ?? isEmphasized
    }
}

extension View {
    func visualEffect(
        material: NSVisualEffectView.Material,
        blendingMode: NSVisualEffectView.BlendingMode = .behindWindow,
        emphasized: Bool = false
    ) -> some View {
        background(
            VisualEffectBackground(
                material: material,
                blendingMode: blendingMode,
                emphasized: emphasized
            )
        )
    }
}

extension VisualEffectBackground {
    
    static var button : VisualEffectBackground {
        .init()
    }
    
}

struct AppBlurView<Content>: View where Content: View {
    
    let size: CGSize
    let padding: EdgeInsets
    let cornerRadius: CGFloat
    var tintColor: Color
    let content: () -> Content

    init(size: CGSize = WindowComponent.Style.defaultElementSize,
         padding: EdgeInsets = .init(top: 0,
                                     leading: 16,
                                     bottom: 0,
                                     trailing: 16),
         cornerRadius: CGFloat = 6.0,
         tintColor: Color = .background,
         @ViewBuilder content: @escaping () -> Content) {
        self.size = size
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.tintColor = tintColor
        self.content = content
    }

    var body: some View {
        content()
            .frame(minWidth: size.width)
            .frame(height: size.height)
            .background(
                VisualEffectBackground(overlayColor: tintColor)
                    .cornerRadius(cornerRadius)
                    .padding(.horizontal, -(padding.leading)))
            .padding(.horizontal, padding.leading)
    }
}

