//
//  SwiftUIView.swift
//  
//
//  Created by Anton Heestand on 2024-03-14.
//

import SwiftUI

/// Small on macOS, else regular.
/// Bigger than ``MiniProgressView``
public struct SmallProgressView: View {
    
    public init() {}
    
    public var body: some View {
        ProgressView()
#if os(macOS)
            .controlSize(.small)
#endif
    }
}
