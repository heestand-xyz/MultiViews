//
//  TooltipView.swift
//
//
//  Created by Anton on 2023/05/07.
//

#if os(iOS) || os(xrOS)

import UIKit
import SwiftUI

@available(iOS 16.0, *)
struct TooltipView: UIViewRepresentable {
    
    let items: [Tooltip.Item]
    
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
        Coordinator(items: items, dismissed: dismissed)
    }
    
    class Coordinator: NSObject, UIEditMenuInteractionDelegate {
        
        let items: [Tooltip.Item]
        let dismissed: () -> ()
        
        init(items: [Tooltip.Item], dismissed: @escaping () -> ()) {
            self.items = items
            self.dismissed = dismissed
        }
        
        func editMenuInteraction(_ interaction: UIEditMenuInteraction, menuFor configuration: UIEditMenuConfiguration, suggestedActions: [UIMenuElement]) -> UIMenu? {
            func elements(items: [Tooltip.Item]) -> [UIMenuElement] {
                var uiElements: [UIMenuElement] = []
                for item in items {
                    switch item {
                    case .action(let action):
                        let uiAction = UIAction(title: action.title, attributes: action.isDestructive ? .destructive : []) { _ in
                            action.callback()
                        }
                        uiElements.append(uiAction)
                    case .menu(let title, let items):
                        let uiMenu = UIMenu(title: title, children: elements(items: items))
                        uiElements.append(uiMenu)
                    }
                }
                return uiElements
            }
            return UIMenu(children: elements(items: items))
        }
        
        func editMenuInteraction(_ interaction: UIEditMenuInteraction, willDismissMenuFor configuration: UIEditMenuConfiguration, animator: UIEditMenuInteractionAnimating) {
            dismissed()
        }
    }
}

#endif
