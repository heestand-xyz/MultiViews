//
//  Created by Anton Heestand on 2021-01-21.
//

#if os(iOS)

import UIKit
import SwiftUI

struct BlurView: UIViewRepresentable {

    @Environment(\.colorScheme) var colorScheme
    
    var style: UIBlurEffect.Style { colorScheme == .light ? .light : .dark }
    var effect: UIVisualEffect { UIBlurEffect(style: style) }
    
    func makeUIView(context: Self.Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: effect)
    }
    
    func updateUIView(_ fxView: UIVisualEffectView, context: Self.Context) {
        fxView.effect = effect
    }
    
}

#endif
