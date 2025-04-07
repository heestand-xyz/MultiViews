//
//  ColorDecodingError.swift
//  MultiViews
//
//  Created by Anton Heestand on 2025-04-07.
//


//
//  Color+Codable.swift
//  Scroll Crop
//
//  Created by Anton Heestand on 2025-04-07.
//

#if os(macOS)
import AppKit
#else
import UIKit
#endif
import SwiftUI

enum ColorDecodingError: Error {
    case wrongType
}

extension Color {
    
    public func encode() throws -> Data {
        let mpColor = MPColor(self)
        return try NSKeyedArchiver.archivedData(
            withRootObject: mpColor,
            requiringSecureCoding: true
        )
    }

    public static func decode(from data: Data) throws -> Color {
        guard let mpColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: MPColor.self, from: data) else {
            throw ColorDecodingError.wrongType
        }
#if os(macOS)
        return Color(nsColor: mpColor)
#else
        return Color(uiColor: mpColor)
#endif
    }
}
