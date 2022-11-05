//
//  BindableScrollView.swift
//  
//
//  Created by Anton Heestand on 2022-10-21.
//

import SwiftUI

@available(iOS 15.0, macOS 12.0, *)
public struct StateScrollView<Content: View>: View {
    
    let isActive: Bool
    
    let axis: Axis
    let showsIndicators: Bool
    let content: () -> Content
    
    @State private var offset: CGFloat = 0.0

    public init(axis: Axis = .vertical,
                showsIndicators: Bool = true,
                isActive: Bool,
                content: @escaping () -> Content) {
        self.axis = axis
        self.showsIndicators = showsIndicators
        self.isActive = isActive
        self.content = content
    }
    
    public var body: some View {
        BindableScrollView(axis: axis,
                           showsIndicators: showsIndicators,
                           isActive: isActive,
                           isMoving: false,
                           offset: $offset,
                           content: content)
    }
}

// ............

@available(iOS 15.0, macOS 12.0, *)
public struct BindableScrollView<Content: View>: View {
    
    @Binding var offset: CGFloat
    let isActive: Bool
    let isMoving: Bool

    let axis: Axis
    let showsIndicators: Bool
    let content: () -> Content
    
    public init(axis: Axis = .vertical,
                showsIndicators: Bool = true,
                isActive: Bool = true,
                isMoving: Bool,
                offset: Binding<CGFloat>,
                content: @escaping () -> Content) {
        self.axis = axis
        self.showsIndicators = showsIndicators
        self.isActive = isActive
        self.isMoving = isMoving
        _offset = offset
        self.content = content
    }
    
    @State private var containerSize: CGSize?
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
            return containerSize?.width ?? 0.0
        case .vertical:
            return containerSize?.height ?? 0.0
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
     
        ZStack {
            
            if isActive {
                
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
                        scroll(to: offset, with: scrollViewProxy)
                    }
                    .onChange(of: contentOrigin) { contentOrigin in
                        guard !isMoving else { return }
                        guard contentOrigin != offset else { return }
                        offset = contentOrigin
                    }
                    .onAppear {
                        DispatchQueue.main.async {
                            scroll(to: offset, with: scrollViewProxy)
                        }
                    }
                }
                    
            } else {
                
                ZStack {
                    Color.clear
                        .overlay(alignment: .topLeading) {
                            content()
                                .offset(x: axis == .horizontal ? offset : 0.0,
                                        y: axis == .vertical ? offset : 0.0)
                        }
                        .clipped()
                }
            }
        }
        .read(size: $containerSize)
        .coordinateSpace(name: spaceIdentifier)
    }
    
    private func scroll(to offset: CGFloat, with scrollViewProxy: ScrollViewProxy) {
        guard containerLength > 0.0
        else { return }
        let fraction = offset / containerLength
        let anchor = UnitPoint(x: axis == .horizontal ? fraction : 0.0,
                               y: axis == .vertical ? fraction : 0.0)
        scrollViewProxy.scrollTo(contentIdentifier, anchor: anchor)
    }
}
