//
//  Tooltip.swift
//  
//
//  Created by Anton on 2023/05/07.
//

import SwiftUI

#if os(iOS)

@available(iOS 16.0, *)
public struct Tooltip: View {
    
    public struct Action: Identifiable {
        public var id: String { title }
        let title: String
        let isDestructive: Bool
        let callback: () -> ()
        public init(title: String, isDestructive: Bool = false, callback: @escaping () -> Void) {
            self.title = title
            self.isDestructive = isDestructive
            self.callback = callback
        }
    }
    
    let actions: [Action]
    
    let location: CGPoint
    
    let dismissed: () -> ()
    
    public init(actions: [Action], location: CGPoint, dismissed: @escaping () -> ()) {
        self.actions = actions
        self.location = location
        self.dismissed = dismissed
    }
    
    public var body: some View {
        TooltipView(actions: actions, location: location, dismissed: dismissed)
    }
}

@available(iOS 16.0, *)
struct Tooltip_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            ZStack {
                Color.clear
                Circle()
                    .frame(width: 30, height: 30)
                Tooltip(actions: [Tooltip.Action(title: "Mock", callback: { })],
                        location: CGPoint(x: geo.size.width / 2,
                                          y: geo.size.height / 2),
                        dismissed: {})
                
            }
        }
    }
}

#endif
