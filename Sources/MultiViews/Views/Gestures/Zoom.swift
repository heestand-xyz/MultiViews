//#if os(iOS)
//
//import SwiftUI
//import UIKit
//
//extension View {
//
//    public func zoom() -> some View {
//        self.overlay(ZoomViewRepresentable())
//    }
//}
//
//struct ZoomViewRepresentable: UIViewRepresentable {
//
//    func makeUIView(context: Context) -> ZoomView {
//        ZoomView()
//    }
//
//    func updateUIView(_ view: ZoomView, context: Context) {}
//}
//
//class ZoomView: UIView {
//
//    init() {
//        super.init(frame: .zero)
//        isMultipleTouchEnabled = true
//        backgroundColor = .green.withAlphaComponent(0.25)
//        let gesture = UIPinchGestureRecognizer(target: self, action: #selector(didPinch))
//        gesture.delegate = self
//        addGestureRecognizer(gesture)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    @objc func didPinch(_ gesture: UIPinchGestureRecognizer) {
//        print("---> pinch:", gesture.state, gesture.location(in: self))
//    }
//
//    override func touchesBegan(
//        _ touches: Set<UITouch>,
//        with event: UIEvent?
//    ) {
//        print("---> touch began:", touches.map({ $0.location }))
//    }
//
//    override func touchesMoved(
//        _ touches: Set<UITouch>,
//        with event: UIEvent?
//    ) {
//        print("---> touch moved:", touches.map({ $0.location }))
//    }
//
//    override func touchesEnded(
//        _ touches: Set<UITouch>,
//        with event: UIEvent?
//    ) {
//        print("---> touch ended:", touches.map({ $0.location }))
//    }
//
//    override func touchesCancelled(
//        _ touches: Set<UITouch>,
//        with event: UIEvent?
//    ) {
//        print("---> touch cancelled:", touches.map({ $0.location }))
//    }
//
////    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
////        print("---> point inside:", point)
////        return false
////    }
////
////    override func hitTest(
////        _ point: CGPoint,
////        with event: UIEvent?
////    ) -> UIView? {
////        print("---> hit test:", point)
////        return nil
////    }
//}
//
//extension ZoomView: UIGestureRecognizerDelegate {
//
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        true
//    }
//}
//
//#endif
