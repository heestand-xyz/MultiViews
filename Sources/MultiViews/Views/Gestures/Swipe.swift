#if os(iOS)

import SwiftUI

extension View {

    public func swipe(direction: UISwipeGestureRecognizer.Direction,
                      completion: @escaping () -> ()) -> some View {
        overlay(SwipeViewRepresentable(direction: direction,
                                       completion: completion))
    }
}


struct SwipeViewRepresentable: ViewRepresentable {

    let direction: UISwipeGestureRecognizer.Direction
    let completion: () -> ()

    func makeView(context: Context) -> SwipeView {
        SwipeView(direction: direction,
                  completion: completion)
    }

    func updateView(_ view: SwipeView, context: Context) {}
}

class SwipeView: MPView {
    
    let direction: UISwipeGestureRecognizer.Direction
    let completion: () -> ()

    init(direction: UISwipeGestureRecognizer.Direction,
         completion: @escaping () -> ()) {
        self.direction = direction
        self.completion = completion
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe))
        swipeGestureRecognizer.direction = direction
        addGestureRecognizer(swipeGestureRecognizer)
    }

    @objc
    func didSwipe(_ gesture: UISwipeGestureRecognizer) {
        switch gesture.state {
        case .ended:
            completion()
        default:
            break
        }
    }
}

#endif
