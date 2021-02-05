//
//  Created by Anton Heestand on 2021-02-05.
//

import SwiftUI

extension View {
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

//struct If<Content: View, SubContent: View>: View {
//    let this: Bool
//    let contentIf: (SubContent) -> (Content)
//    let contentElse: (SubContent) -> (Content)
//    let content: () -> (SubContent)
//    init(_ this: Bool,
//         _ contentIf: @escaping (SubContent) -> (Content),
//         else contentElse: @escaping (SubContent) -> (Content),
//         content: @escaping () -> (SubContent)) {
//        self.this = this
//        self.contentIf = contentIf
//        self.contentElse = contentElse
//        self.content = content
//    }
//    var body: some View {
//        if this {
//            contentIf(content())
//        } else {
//            contentElse(content())
//        }
//    }
//}
