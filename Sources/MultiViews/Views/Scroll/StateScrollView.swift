import SwiftUI

@available(iOS 16.0, macOS 13.0, *)
public struct StateScrollView<Content: View>: View {
    
    let isActive: Bool
    
    let axis: Axis
    let showsIndicators: Bool
    let content: () -> Content
    
    public init(axis: Axis = .vertical,
                showsIndicators: Bool = true,
                isActive: Bool,
                @ViewBuilder content: @escaping () -> Content) {
        self.axis = axis
        self.showsIndicators = showsIndicators
        self.isActive = isActive
        self.content = content
    }
    
    public var body: some View {
        let scrollAxis: Axis.Set = axis == .vertical ? .vertical : .horizontal
        ScrollView(scrollAxis, showsIndicators: showsIndicators) {
            content()
        }
        .scrollDisabled(!isActive)
    }
}
