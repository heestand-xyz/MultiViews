//
//  File.swift
//  
//
//  Created by Anton Heestand on 2021-02-09.
//

#if os(iOS)
import UIKit
#endif

public let iPhone: Bool = {
    #if !os(macOS)
    return UIDevice.current.userInterfaceIdiom == .phone
    #else
    return false
    #endif
}()

public let iPad: Bool = {
    #if !os(macOS)
    return UIDevice.current.userInterfaceIdiom == .pad
    #else
    return false
    #endif
}()
