//
//  BindableScrollView.swift
//  
//
//  Created by Anton Heestand on 2022-10-21.
//

import SwiftUI

@available(iOS 15.0, macOS 12.0, *)
public struct BindableScrollView<Content: View>: View {
    
    @Binding var offset: CGFloat
    let isMoving: Bool
    
    let axis: Axis
    let showsIndicators: Bool
    let content: () -> Content
    
    public init(offset: Binding<CGFloat>,
                isMoving: Bool,
                axis: Axis = .vertical,
                showsIndicators: Bool = true,
                content: @escaping () -> Content) {
        _offset = offset
        self.isMoving = isMoving
        self.axis = axis
        self.showsIndicators = showsIndicators
        self.content = content
    }
    
    @State private var containerFrame: CGRect?
    @State private var contentFrame: CGRect?

    private var contentOrigin: CGFloat {
        switch axis {
        case .horizontal:
            return contentFrame?.minX ?? 0.0
        case .vertical:
            return contentFrame?.minY ?? 0.0
        }
    }
    
    private var containerLength: CGFloat {
        switch axis {
        case .horizontal:
            return containerFrame?.size.width ?? 0.0
        case .vertical:
            return containerFrame?.size.height ?? 0.0
        }
    }
    
    private var contentLength: CGFloat {
        switch axis {
        case .horizontal:
            return contentFrame?.size.width ?? 0.0
        case .vertical:
            return contentFrame?.size.height ?? 0.0
        }
    }
    
    @State private var id: UUID = UUID()
    
    private let prefix: String = "bindable-scroll-view"
    
    private var spaceIdentifier: String {
        "\(prefix)_\(id)_space"
    }
    
    private var contentIdentifier: String {
        "\(prefix)_\(id)_content"
    }
    
    public var body: some View {
        
        ScrollViewReader { scrollViewProxy in
        
            let scrollAxis: Axis.Set = axis == .vertical ? .vertical : .horizontal
            ScrollView(scrollAxis, showsIndicators: showsIndicators) {
            
                content()
                    .read(frame: $contentFrame, in: .named(spaceIdentifier))
                    .background(alignment: .topLeading) {
                        Color.clear
                            .id(contentIdentifier)
                            .frame(width: 0.0,
                                   height: 0.0)
                    }
            }
            .onChange(of: offset) { offset in
                guard isMoving else { return }
                guard offset != contentOrigin else { return }
                let fraction = offset / containerLength
                let anchor = UnitPoint(x: axis == .horizontal ? fraction : 0.0,
                                       y: axis == .vertical ? fraction : 0.0)
                scrollViewProxy.scrollTo(contentIdentifier, anchor: anchor)
            }
            .onChange(of: contentOrigin) { origin in
                guard !isMoving else { return }
                guard origin != offset else { return }
                offset = origin
            }
        }
        .read(frame: $containerFrame, in: .local)
        .coordinateSpace(name: spaceIdentifier)
    }
}
