//
//  FrameReader.swift
//  
//
//  Created by Anton Heestand on 2022-07-31.
//

import SwiftUI

public struct FrameReader: View {
    
    @Binding var frame: CGRect?
    let coordinateSpace: CoordinateSpace
    let clear: Bool
    
    public init(frame: Binding<CGRect?>,
                in coordinateSpace: CoordinateSpace,
                clear: Bool) {
        _frame = frame
        self.coordinateSpace = coordinateSpace
        self.clear = clear
    }
    
    public var body: some View {
        GeometryReader { geometry in
            Color.clear
                .onAppear {
                    frame = geometry.frame(in: coordinateSpace)
                }
                .onChange(of: geometry.frame(in: coordinateSpace)) { newFrame in
                    frame = newFrame
                }
                .onDisappear {
                    if clear {
                        frame = nil                        
                    }
                }
        }
    }
}

extension View {
    
    @available(*, deprecated, message: "Please use `readGeometry` in CoreGraphicsExtensions")
    public func read(frame: Binding<CGRect>, in coordinateSpace: CoordinateSpace) -> some View {
        read(frame: Binding<CGRect?>(get: {
            frame.wrappedValue
        }, set: { newFrame in
            frame.wrappedValue = newFrame ?? CGRect(origin: .zero, size: CGSize(width: 1.0, height: 1.0))
        }), in: coordinateSpace, clear: false)
    }
    
    @available(*, deprecated, message: "Please use `readGeometry` in CoreGraphicsExtensions")
    public func read(frame: Binding<CGRect?>, in coordinateSpace: CoordinateSpace, clear: Bool = false) -> some View {
        background(FrameReader(frame: frame, in: coordinateSpace, clear: clear))
    }
    
    @available(*, deprecated)
    public func frame(_ frame: CGRect?) -> some View {
        self.frame(width: frame?.width ?? 0.0,
                   height: frame?.height ?? 0.0)
            .offset(x: frame?.minX ?? 0.0,
                    y: frame?.minY ?? 0.0)
    }
}
