//
//  SizeReader.swift
//  
//
//  Created by Anton Heestand on 2022-07-31.
//

import SwiftUI

public struct SizeReader: View {
    
    @Binding var size: CGSize?
    
    public init(size: Binding<CGSize?>) {
        _size = size
    }
    
    public var body: some View {
        GeometryReader { geometry in
            Color.clear
                .onAppear {
                    size = geometry.size
                }
                .onChange(of: geometry.size) { size in
                    self.size = size
                }
                .onDisappear {
                    size = nil
                }
        }
    }
}

extension View {
    
    public func read(size: Binding<CGSize?>) -> some View {
        self.background(SizeReader(size: size))
    }
}
