import Foundation
import SwiftUI

extension View {
    
    public func backgroundIf<Background : View>(_ condition : Bool, @ViewBuilder bg : () -> Background) -> some View {
        self.background(condition ? bg() : nil)
    }
    
}
