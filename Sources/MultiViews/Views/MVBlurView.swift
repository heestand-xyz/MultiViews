//
//  Created by Anton Heestand on 2021-01-21.
//

#if os(iOS)

import UIKit
import SwiftUI

public struct MVBlurView: UIViewRepresentable {

    @Environment(\.colorScheme) var colorScheme
    
    public var style: UIBlurEffect.Style { colorScheme == .light ? .light : .dark }
    public var effect: UIVisualEffect { UIBlurEffect(style: style) }
    
    public func makeUIView(context: Self.Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: effect)
    }
    
    public func updateUIView(_ fxView: UIVisualEffectView, context: Self.Context) {
        fxView.effect = effect
    }
    
}

#endif
