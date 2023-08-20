//
//  Created by Anton Heestand on 2021-02-09.
//

#if os(iOS)
import UIKit
#endif

public let iPhone: Bool = {
    #if os(iOS)
    return UIDevice.current.userInterfaceIdiom == .phone
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
    #else
    return false
    #endif
}()

public let visionPro: Bool = {
    #if os(xrOS)
    return true
    #else
    return false
    #endif
}()
