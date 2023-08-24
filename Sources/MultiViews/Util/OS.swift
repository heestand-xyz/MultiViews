//
//  Created by Anton Heestand on 2020-12-06.
//

#if os(macOS)
import AppKit
#else
import UIKit
#endif
import SwiftUI

public var iOS: Bool {
    #if os(iOS)
    return true
    #else
    return false
    #endif
}
public var tvOS: Bool {
    #if os(tvOS)
    return true
    #else
    return false
    #endif
}
public var watchOS: Bool {
    #if os(watchOS)
    return true
    #else
    return false
    #endif
}
public var macOS: Bool {
    #if os(macOS)
    return true
    #else
    return false
    #endif
}
public var visionOS: Bool {
    #if os(visionOS)
    return true
    #else
    return false
    #endif
}

public var iOS15: Bool {
    if #available(iOS 15.0, *) {
        return true
    }
    return false
}
public var macOS12: Bool {
    if #available(macOS 12.0, *) {
        return true
    }
    return false
}
