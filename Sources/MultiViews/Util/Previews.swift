//
//  Previews.swift
//  
//
//  Created by Anton on 2023/04/22.
//

import Foundation

/// Xcode is Running for Previews
public let isRunningForPreviews: Bool = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
