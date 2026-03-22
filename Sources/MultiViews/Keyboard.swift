#if os(iOS) || os(visionOS)

import Combine
import UIKit

public struct Keyboard {
    
    public let isVisible: Bool
    /// `false` for hardware keyboards.
    public let isSoftwareVisible: Bool
    
    public static let `default` = Keyboard(isVisible: false, isSoftwareVisible: false)

    private static func isSoftwareKeyboardVisible(_ notification: Notification) -> Bool {
        let frame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect) ?? .zero
        return frame.height > 0
    }

    @available(*, deprecated, message: "Please use softwareKeyboardVisibleStream instead.")
    public static var publisher: AnyPublisher<Bool, Never> {
        Publishers.Merge(
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillShowNotification)
                .map { _ in true },
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in false }
        )
        .eraseToAnyPublisher()
    }

    public static var stream: AsyncStream<Keyboard> {
        AsyncStream { continuation in
            let center = NotificationCenter.default
            let showObserver = center.addObserver(
                forName: UIResponder.keyboardWillShowNotification,
                object: nil,
                queue: nil
            ) { notification in
                let keyboard = Keyboard(
                    isVisible: true,
                    isSoftwareVisible: isSoftwareKeyboardVisible(notification)
                )
                continuation.yield(keyboard)
            }
            let hideObserver = center.addObserver(
                forName: UIResponder.keyboardWillHideNotification,
                object: nil,
                queue: nil
            ) { _ in
                let keyboard = Keyboard(
                    isVisible: false,
                    isSoftwareVisible: false
                )
                continuation.yield(keyboard)
            }
            continuation.onTermination = { _ in
                center.removeObserver(showObserver)
                center.removeObserver(hideObserver)
            }
        }
    }
}

#endif
