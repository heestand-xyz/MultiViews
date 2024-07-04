import SwiftUI

public struct StateView<Value, Content: View>: View {
    
    private let content: (Binding<Value>) -> Content
    
    @State private var value: Value
    
    public init(
        _ initialValue: Value,
        @ViewBuilder content: @escaping (Binding<Value>) -> Content
    ) {
        self.content = content
        _value = State(initialValue: initialValue)
    }
    
    public var body: some View {
        content($value)
    }
}
