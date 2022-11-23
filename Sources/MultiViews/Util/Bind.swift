import SwiftUI
import Combine

extension View {
    
    public func bind<T>(_ publisher: AnyPublisher<T, Never>, to binding: Binding<T>) -> some View {
        self.onReceive(publisher) { value in
            binding.wrappedValue = value
        }
    }
}
