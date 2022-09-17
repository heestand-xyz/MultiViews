//
//  SwiftUIView.swift
//  
//
//  Created by Anton Heestand on 2022-09-16.
//

import SwiftUI

public struct FillView<Content: View>: View {
    
    let content: () -> Content
    
    public init(content: @escaping () -> Content) {
        
        self.content = content
    }
    
    public var body: some View {
        FlexView(contentMode: .fill, content: content)
    }
}
