//
//  Created by Anton Heestand on 2020-12-06.
//

#if os(macOS)
import AppKit
#else
import UIKit
#endif
import SwiftUI

var iOS: Bool {
    #if os(iOS)
    return true
    #else
    return false
    #endif
}
var tvOS: Bool {
    #if os(tvOS)
    return true
    #else
    return false
    #endif
}
var watchOS: Bool {
    #if os(watchOS)
    return true
    #else
    return false
    #endif
}
var macOS: Bool {
    #if os(macOS)
    return true
    #else
    return false
    #endif
}
