//
//  Created by Anton Heestand on 2021-02-05.
//

import SwiftUI

public extension View {
    func `if`<Content: View>(_ this: Bool,
                             _ contentIf: (Self) -> (Content),
                             else contentElse: ((Self) -> (Content))? = nil) -> AnyView {
        if this {
            return AnyView(contentIf(self))
        } else {
            return contentElse != nil ? AnyView(contentElse!(self)) : AnyView(self)
        }
    }
}

public extension View {
    func unwrap<T, Content: View>(_ this: T?,
                                _ contentIf: (Self, T) -> (Content)) -> AnyView {
        if let unwrapped: T = this {
            return AnyView(contentIf(self, unwrapped))
        } else {
            return AnyView(self)
        }
    }
}
