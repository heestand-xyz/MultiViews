//
//  Created by Anton Heestand on 2021-02-09.
//

import CoreGraphics
#if !os(macOS)
import UIKit
#endif

public let iPhone: Bool = {
    #if os(iOS)
    return UIDevice.current.userInterfaceIdiom == .phone
    #else
    return false
    #endif
}()

public let iPhoneSE: Bool = {
    #if os(iOS)
    return iPhone && UIScreen.main.bounds.size == CGSize(width: 375, height: 667)
    #else
    return false
    #endif
}()

public let iPhoneMini: Bool = {
    #if os(iOS)
    return iPhone && UIScreen.main.bounds.width <= 375
    #else
    return false
    #endif
}()

public let iPad: Bool = {
    #if os(iOS)
    return UIDevice.current.userInterfaceIdiom == .pad
    #else
    return false
    #endif
}()

public let mac: Bool = {
    #if os(macOS)
    return true
    #elseif targetEnvironment(macCatalyst)
    return UIDevice.current.userInterfaceIdiom == .mac
    #else
    return false
    #endif
}()

public let vision: Bool = {
    #if os(visionOS)
    return UIDevice.current.userInterfaceIdiom == .vision
    #else
    return false
    #endif
}()
