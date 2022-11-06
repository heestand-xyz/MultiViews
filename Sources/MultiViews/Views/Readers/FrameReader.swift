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
    
    public init(frame: Binding<CGRect?>, in coordinateSpace: CoordinateSpace) {
        _frame = frame
        self.coordinateSpace = coordinateSpace
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
        }
    }
}

extension View {
    
    public func read(frame: Binding<CGRect?>, in coordinateSpace: CoordinateSpace) -> some View {
        self.background(FrameReader(frame: frame, in: coordinateSpace))
    }
    
    public func frame(_ frame: CGRect?) -> some View {
        self.frame(width: frame?.width ?? 0.0,
                   height: frame?.height ?? 0.0)
            .offset(x: frame?.minX ?? 0.0,
                    y: frame?.minY ?? 0.0)
    }
}
