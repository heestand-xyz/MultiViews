import SwiftUI

public struct GestureStateView<Value, Content: View>: View {
    
    private let content: (GestureState<Value>) -> Content
    
    @GestureState private var value: Value
    
    public init(
        _ initialValue: Value,
        @ViewBuilder content: @escaping (GestureState<Value>) -> Content
    ) {
        self.content = content
        _value = GestureState(initialValue: initialValue)
    }
    
    public var body: some View {
        content($value)
    }
}
