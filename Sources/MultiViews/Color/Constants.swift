//
//  Created by Anton Heestand on 2021-02-05.
//

import CoreGraphics
import SwiftUI

public extension CGFloat {
    
    static var onePixel: CGFloat {
        #if os(macOS)
        return 1.0 / 2.0
        #elseif os(iOS) || os(tvOS)
        return 1.0 / UIScreen.main.scale
        #elseif os(visionOS)
        return 1.0 / 3.0
        #endif
    }

}

public extension Color {
    
    static let nearClear: Color = Color(.displayP3, white: 0.5, opacity: 0.001)
    
}
