//
//  Created by Anton Heestand on 2021-01-21.
//

#if os(macOS)
import AppKit
#else
import UIKit
#endif
import SwiftUI

#if os(macOS)
typealias MPVisualEffectView = NSVisualEffectView
#else
typealias MPVisualEffectView = UIVisualEffectView
#endif

public struct MVBlurView: ViewRepresentable {
    
    @Environment(\.colorScheme) var colorScheme
    
    public init() {}
    
    #if os(iOS)
    public var style: UIBlurEffect.Style { colorScheme == .light ? .light : .dark }
    public var effect: UIVisualEffect { UIBlurEffect(style: style) }
    #endif
    
    public func makeView(context: Self.Context) -> MPView {
        #if os(macOS)
        return MPVisualEffectView()
        #else
        return MPVisualEffectView(effect: effect)
        #endif
    }
    
    public func updateView(_ view: MPView, context: Self.Context) {
        #if !os(macOS)
        (view as! MPVisualEffectView).effect = effect
        #endif
    }
    
}
