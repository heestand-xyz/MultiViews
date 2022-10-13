//
//  OriginReader.swift
//  
//
//  Created by Anton Heestand on 2022-07-31.
//

import SwiftUI

public struct OriginReader: View {
    
    @Binding var origin: CGPoint?
    let coordinateSpace: CoordinateSpace
    
    public init(origin: Binding<CGPoint?>, in coordinateSpace: CoordinateSpace) {
        _origin = origin
        self.coordinateSpace = coordinateSpace
    }
    
    public var body: some View {
        GeometryReader { geometry in
            Color.clear
                .onAppear {
                    origin = geometry.frame(in: coordinateSpace).origin
                }
                .onChange(of: geometry.frame(in: coordinateSpace).origin) { newOrigin in
                    origin = newOrigin
                }
                .onDisappear {
                    origin = nil
                }
        }
    }
}

extension View {
    
    public func read(origin: Binding<CGPoint?>, in coordinateSpace: CoordinateSpace) -> some View {
        self.background(OriginReader(origin: origin, in: coordinateSpace))
    }
}
