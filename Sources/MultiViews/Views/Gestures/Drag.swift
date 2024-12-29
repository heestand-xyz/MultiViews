//
//  CancellableDragGesture.swift
//  
//
//  Created by Anton Heestand on 2024-07-04.
//

import SwiftUI

extension View {
    
    public func drag(
        minimumDistance: CGFloat = 10,
        coordinateSpace: CoordinateSpace = .local,
        onStart: @escaping (DragGesture.Value) -> (),
        onUpdate: @escaping (DragGesture.Value) -> (),
        onEnd: @escaping (DragGesture.Value?) -> ()
    ) -> some View {
        StateView(false) { isActivelyDragging in
            GestureStateView(false) { isDragging in
                self
                    .gesture(
                        DragGesture(minimumDistance: minimumDistance, coordinateSpace: coordinateSpace)
                            .updating(isDragging) { _, isDragging, _ in
                                isDragging = true
                            }
                            .onChanged { value in
                                if !isActivelyDragging.wrappedValue {
                                    isActivelyDragging.wrappedValue = true
                                    onStart(value)
                                }
                                onUpdate(value)
                            }
                            .onEnded { value in
                                isActivelyDragging.wrappedValue = false
                                onEnd(value)
                            }
                    )
                    .onChange(of: isDragging.wrappedValue) { _, isDragging in
                        let isCancelled = !isDragging && isActivelyDragging.wrappedValue
                        if isCancelled {
                            isActivelyDragging.wrappedValue = false
                            onEnd(nil)
                        }
                    }
            }
        }
    }
}
