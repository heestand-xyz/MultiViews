//
//  SquareImageView.swift
//  ChannelMix
//
//  Created by Anton Heestand on 2022-08-12.
//

import SwiftUI

public struct MPSquareImageView: View {
    
    let image: MPImage
    let contentMode: ContentMode
    
    public init(image: MPImage, contentMode: ContentMode) {
        self.image = image
        self.contentMode = contentMode
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.clear
                Image(multiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .offset(x: {
                        guard contentMode == .fill else { return 0.0 }
                        guard image.size.width > image.size.height else { return 0.0 }
                        let imageAspect = image.size.width / image.size.height
                        return (-geometry.size.width * (imageAspect - 1.0)) / 2
                    }(), y: {
                        guard contentMode == .fill else { return 0.0 }
                        guard image.size.width < image.size.height else { return 0.0 }
                        let imageAspect = image.size.width / image.size.height
                        return (-geometry.size.height * ((1.0 / imageAspect) - 1.0)) / 2
                    }())
            }
        }
        .aspectRatio(1.0, contentMode: .fit)
        .clipped()
    }
}
