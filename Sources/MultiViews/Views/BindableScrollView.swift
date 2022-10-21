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
    let detail: CGFloat
    let isMoving: Bool
    
    let axis: Axis
    let showsIndicators: Bool
    let content: () -> Content
    
    public init(offset: Binding<CGFloat>,
                detail: CGFloat,
                isMoving: Bool,
                axis: Axis = .vertical,
                showsIndicators: Bool = true,
                content: @escaping () -> Content) {
        _offset = offset
        self.detail = detail
        self.isMoving = isMoving
        self.axis = axis
        self.showsIndicators = showsIndicators
        self.content = content
    }
    
    @State private var frame: CGRect?
    
    private var origin: CGFloat {
        switch axis {
        case .horizontal:
            return frame?.minX ?? 0.0
        case .vertical:
            return frame?.minY ?? 0.0
        }
    }
    
    private var length: CGFloat {
        switch axis {
        case .horizontal:
            return frame?.size.width ?? 0.0
        case .vertical:
            return frame?.size.height ?? 0.0
        }
    }
    
    var globalIndex: Int {
        Int(-offset / detail)
    }
    
    var localIndex: Int {
        Int(-origin / detail)
    }
    
    private var count: Int {
        Int(length / detail)
    }
    
    @State private var id: UUID = UUID()
    
    private let prefix: String = "bindable-scroll-view"
    
    public var body: some View {
        
        ScrollViewReader { scrollViewProxy in
        
            let scrollAxis: Axis.Set = axis == .vertical ? .vertical : .horizontal
            ScrollView(scrollAxis, showsIndicators: showsIndicators) {
            
                content()
                    .read(frame: $frame, in: .named("\(prefix)_\(id)"))
                    .background {
                        
                        Group {
                            if axis == .vertical {
                                VStack(spacing: 0.0) {
                                    marks()
                                }
                            } else {
                                HStack(spacing: 0.0) {
                                    marks()
                                }
                            }
                        }
                        .drawingGroup()
                    }
            }
            .onChange(of: globalIndex) { globalIndex in
                print("--->", "globalIndex:", globalIndex)
                guard globalIndex != localIndex else { return }
                print("--->>>")
                scrollViewProxy.scrollTo("\(prefix)_\(id)_\(globalIndex)",
                                         anchor: axis == .vertical ? .top : .leading)
                print("--->>>>>>")
            }
            .onChange(of: localIndex) { localIndex in
                guard !isMoving
                else { return }
                print("---<", "localIndex:", localIndex)
                guard localIndex != globalIndex else { return }
                print("---<<<")
                offset = CGFloat(-localIndex) * detail
                print("---<<<<<<")
            }
//            .onChange(of: isMoving) { isMoving in
//                if !isMoving {
//                    offset = CGFloat(-localIndex) * detail
//                }
//            }
        }
        .coordinateSpace(name: "\(prefix)_\(id)")
    }
    
    @ViewBuilder
    private func marks() -> some View {
        
        ForEach(Array(0..<count), id: \.self) { index in
        
            Color.clear
                .frame(width: axis == .horizontal ? detail : nil,
                       height: axis == .vertical ? detail : nil)
                .id("\(prefix)_\(id)_\(index)")
        }
        
        Spacer(minLength: 0.0)
    }
}
