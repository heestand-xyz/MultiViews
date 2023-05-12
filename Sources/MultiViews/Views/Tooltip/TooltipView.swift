//
//  TooltipView.swift
//
//
//  Created by Anton on 2023/05/07.
//

#if os(iOS)

import UIKit
import SwiftUI

@available(iOS 16.0, *)
struct TooltipView: UIViewRepresentable {
    
    let actions: [Tooltip.Action]
    
    let location: CGPoint
    
    let dismissed: () -> ()
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIView()
        let menuInteraction = UIEditMenuInteraction(delegate: context.coordinator)
        view.addInteraction(menuInteraction)
        let config = UIEditMenuConfiguration(identifier: nil, sourcePoint: location)
        DispatchQueue.main.async {
            menuInteraction.presentEditMenu(with: config)
        }
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(actions: actions, dismissed: dismissed)
    }
    
    class Coordinator: NSObject, UIEditMenuInteractionDelegate {
        
        let actions: [Tooltip.Action]
        let dismissed: () -> ()
        
        init(actions: [Tooltip.Action], dismissed: @escaping () -> ()) {
            self.actions = actions
            self.dismissed = dismissed
        }
        
        func editMenuInteraction(_ interaction: UIEditMenuInteraction, menuFor configuration: UIEditMenuConfiguration, suggestedActions: [UIMenuElement]) -> UIMenu? {
            var elements: [UIMenuElement] = []
            for action in actions {
                let element = UIAction(title: action.title, attributes: action.isDestructive ? .destructive : []) { _ in
                    action.callback()
                }
                elements.append(element)
            }
            return UIMenu(children: elements)
        }
        
        func editMenuInteraction(_ interaction: UIEditMenuInteraction, willDismissMenuFor configuration: UIEditMenuConfiguration, animator: UIEditMenuInteractionAnimating) {
            dismissed()
        }
    }
}

#endif
