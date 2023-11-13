//
//  Created by Anton Heestand on 2021-02-09.
//

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
