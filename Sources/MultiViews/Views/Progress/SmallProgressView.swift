//
//  SwiftUIView.swift
//  
//
//  Created by Heestand, Anton Norman | Anton | GSSD on 2024-03-14.
//

import SwiftUI

public struct SmallProgressView: View {
    
    public init() {}
    
    public var body: some View {
#if os(macOS)
        ProgressView()
            .scaleEffect(0.5)
            .padding(-8)
#else
        ProgressView()
#endif
    }
}

#Preview {
    SmallProgressView()
}
