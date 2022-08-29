//
//  AspectRatioView.swift
//  Video Editor
//
//  Created by Anton Heestand on 2022-08-29.
//

import SwiftUI

public struct AspectRatioView<Content: View>: View {
    
    let aspectRatio: CGFloat
    let contentMode: ContentMode

    let content: () -> Content
    
    public init(aspectRatio: CGFloat,
                contentMode: ContentMode,
                content: @escaping () -> Content) {
        
        self.aspectRatio = aspectRatio
        self.contentMode = contentMode
        
        self.content = content
    }
    
    public var body: some View {
        GeometryReader { geometry in
            content()
                .aspectRatio(aspectRatio, contentMode: contentMode)
                .offset({
                    
                    guard contentMode == .fill
                    else { return .zero }
                    
                    let size: CGSize = geometry.size
                    let _aspectRatio = size.width / size.height
                    
                    let x: CGFloat = {
                        if aspectRatio > _aspectRatio {
                            return -(size.width * (aspectRatio / _aspectRatio) - size.width) / 2
                        }
                        return 0.0
                    }()
                    
                    let y: CGFloat = {
                        if aspectRatio < _aspectRatio {
                            return -(size.height * (_aspectRatio / aspectRatio) - size.height) / 2
                        }
                        return 0.0
                    }()
                    
                    return CGSize(width: x, height: y)
                }())
        }
        .clipped()
    }
}
