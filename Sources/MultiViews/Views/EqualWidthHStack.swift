//
//  Created by Anton Heestand on 2022-06-13.
//

import SwiftUI
import CoreGraphicsExtensions

@available(iOS 16.0, tvOS 16.0, macOS 13.0, *)
public struct EqualWidthHStack: Layout {
    
    public init() {}
    
    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        
        let maxSize = maxSize(subviews: subviews)
        
        let spacing = spacing(subviews: subviews)
        
        let totalSpacing = spacing.reduce(0.0, +)
        
        return CGSize(width: maxSize.width * CGFloat(subviews.count) + totalSpacing,
                      height: maxSize.height)
    }
    
    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        
        let maxSize = maxSize(subviews: subviews)
        
        let spacing = spacing(subviews: subviews)
        
        let sizeProposal = ProposedViewSize(width: maxSize.width, height: maxSize.height)
        
        var x = bounds.minX + maxSize.width / 2
        
        for index in subviews.indices {
            subviews[index].place(at: CGPoint(x: x, y: bounds.midY),
                                  anchor: .center,
                                  proposal: sizeProposal)
            x += maxSize.width + spacing[index]
        }
    }
    
    private func maxSize(subviews: Subviews) -> CGSize {
        let subviewSizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let maxSize: CGSize = subviewSizes.reduce(.zero, { result, size in
            CGSize(width: max(result.width, size.width),
                   height: max(result.height, size.height))
        })
        return maxSize
    }
    
    private func spacing(subviews: Subviews) -> [CGFloat] {
        subviews.indices.map { index in
            guard index < subviews.count - 1 else { return 0.0 }
            return subviews[index].spacing.distance(to: subviews[index + 1].spacing, along: .horizontal)
        }
    }
}
