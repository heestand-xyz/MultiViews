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
                .onChange(of: geometry.frame(in: coordinateSpace).origin) { _, newOrigin in
                    origin = newOrigin
                }
        }
    }
}

extension View {
    
    @available(*, deprecated, message: "Please use `readGeometry` in CoreGraphicsExtensions")
    public func read(origin: Binding<CGPoint>, in coordinateSpace: CoordinateSpace) -> some View {
        read(origin: Binding<CGPoint?>(get: {
            origin.wrappedValue
        }, set: { newOrigin in
            origin.wrappedValue = newOrigin ?? .zero
        }), in: coordinateSpace)
    }
    
    @available(*, deprecated, message: "Please use `readGeometry` in CoreGraphicsExtensions")
    public func read(origin: Binding<CGPoint?>, in coordinateSpace: CoordinateSpace) -> some View {
        self.background(OriginReader(origin: origin, in: coordinateSpace))
    }
}
