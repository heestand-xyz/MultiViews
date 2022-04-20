//
//  Created by Anton Heestand on 2021-05-05.
//

import Foundation

public struct ViewRep: ViewRepresentable {
    
    let view: MPView
    
    public init(view: MPView) {
        self.view = view
    }
    
    public func makeView(context: Context) -> MPView {
        view
    }
    
    public func updateView(_ view: MPView, context: Context) {}
}
