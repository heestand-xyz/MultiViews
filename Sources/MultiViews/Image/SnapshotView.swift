#if os(iOS) || os(visionOS)

import SwiftUI

public typealias SnapshotAction = (@escaping () -> UIImage) -> ()

public struct SnapshotView<Content: View>: UIViewRepresentable {
    
    private let action: SnapshotAction
    private let content: () -> Content
    
    public init(action: @escaping SnapshotAction,
                content: @escaping () -> Content) {
        self.action = action
        self.content = content
    }
    
    public func makeUIView(context: Context) -> UISnapshotView<Content> {
        UISnapshotView(action: action,
                       content: content)
    }
    
    public func updateUIView(_ uiView: UISnapshotView<Content>, context: Context) {}
}

public class UISnapshotView<Content: View>: UIView {
    
    private let action: SnapshotAction
    private let content: () -> Content
    
    public init(action: @escaping SnapshotAction,
                content: @escaping () -> Content) {
        self.action = action
        self.content = content
        super.init(frame: .zero)
        setup()
        action(snapshot)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        let hosting = UIHostingController(rootView: content())
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(hosting.view)
        NSLayoutConstraint.activate([
            hosting.view.topAnchor.constraint(equalTo: topAnchor),
            hosting.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: trailingAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    private func snapshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: bounds.size)
        return renderer.image { ctx in
            drawHierarchy(in: bounds, afterScreenUpdates: true)
        }
    }
}

#endif
