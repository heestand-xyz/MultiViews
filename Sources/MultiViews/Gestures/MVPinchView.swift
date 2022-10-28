////
////  File.swift
////  
////
////  Created by Anton Heestand on 2021-05-22.
////
//
//#if os(iOS)
//import UIKit
//#elseif os(macOS)
//import AppKit
//#endif
//
//struct MVPinchView: ViewRepresentable {
//    
//    
//    
//    func makeView(context: Context) -> MPView {
//        let view = MPView()
//        #if os(macOS)
//        let gesture = NSMagnificationGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.pinch))
//        #elseif os(iOS)
//        
//        #endif
//        view.addGestureRecognizer(gesture)
//        return view
//    }
//    
//    func updateView(_ view: MPView, context: Context) {}
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator()
//    }
//    
//    class Coordinator {
//        #if os(macOS)
//        func pinch(_ gesture: NSMagnificationGestureRecognizer) {
//            if gesture.state == .ended {
//                gesture.magnification
//            }
//        }
//        #elseif os(iOS)
//        
//        #endif
//    }
//}
