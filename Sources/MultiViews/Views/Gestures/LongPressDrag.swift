//
//  LongPressDrag.swift
//  MultiViews
//

import SwiftUI

#if os(iOS)
import UIKit
#endif

extension View {

    /// Adds a drag that starts after a long press on touch platforms.
    ///
    /// Movement beyond `allowableMovement` before activation fails the long
    /// press so an enclosing scroll view can begin scrolling instead.
    public func longPressDrag<Space: CoordinateSpaceProtocol>(
        isEnabled: Bool = true,
        minimumDuration: TimeInterval = 0.5,
        extendedDuration: TimeInterval = 1.5,
        allowableMovement: CGFloat = 10.0,
        coordinateSpace: Space = .local,
        onPressingChanged: ((Bool) -> Void)? = nil,
        onExtendedPress: (() -> Void)? = nil,
        onStart: @escaping () -> Void,
        onUpdate: @escaping (CGSize) -> Void,
        onEnd: @escaping (CGSize?) -> Void
    ) -> some View {
        modifier(
            LongPressDragModifier(
                isEnabled: isEnabled,
                minimumDuration: minimumDuration,
                extendedDuration: extendedDuration,
                allowableMovement: allowableMovement,
                coordinateSpace: coordinateSpace,
                onPressingChanged: onPressingChanged,
                onExtendedPress: onExtendedPress,
                onStart: onStart,
                onUpdate: onUpdate,
                onEnd: onEnd
            )
        )
    }
}

private struct LongPressDragModifier<Space: CoordinateSpaceProtocol>: ViewModifier {

    let isEnabled: Bool
    let minimumDuration: TimeInterval
    let extendedDuration: TimeInterval
    let allowableMovement: CGFloat
    let coordinateSpace: Space
    let onPressingChanged: ((Bool) -> Void)?
    let onExtendedPress: (() -> Void)?
    let onStart: () -> Void
    let onUpdate: (CGSize) -> Void
    let onEnd: (CGSize?) -> Void

    @State private var legacyLongPressIsActive: Bool = false
    @State private var dragIsActive: Bool = false
    @State private var sequencedDragIsActive: Bool = false
    @State private var lastSequencedDragTranslation: CGSize?
    @State private var extendedPressWorkItem: DispatchWorkItem?
    @SwiftUI.GestureState private var sequencedGestureIsRecognized: Bool = false

    @ViewBuilder
    func body(content: Content) -> some View {
#if os(iOS)
        if #available(iOS 18.0, *) {
            content
                .simultaneousGesture(
                    legacyLongPressGesture,
                    including: isEnabled ? .subviews : .all
                )
                .simultaneousGesture(
                    dragGesture,
                    including: isEnabled ? .subviews : .all
                )
                .gesture(
                    PlatformLongPressDragGesture(
                        isEnabled: isEnabled,
                        minimumDuration: minimumDuration,
                        extendedDuration: extendedDuration,
                        allowableMovement: allowableMovement,
                        onPressingChanged: onPressingChanged,
                        onExtendedPress: onExtendedPress,
                        onStart: onStart,
                        onUpdate: onUpdate,
                        onEnd: onEnd
                    )
                )
        } else {
            touchFallbackBody(content: content)
        }
#elseif os(visionOS)
        touchFallbackBody(content: content)
#elseif os(macOS)
        content
            .simultaneousGesture(dragGesture)
#else
        content
#endif
    }

#if os(iOS) || os(visionOS)
    private func touchFallbackBody(content: Content) -> some View {
        content
            .simultaneousGesture(
                legacyLongPressGesture,
                including: isEnabled ? .subviews : .all
            )
            .simultaneousGesture(
                dragGesture,
                including: isEnabled ? .subviews : .all
            )
            .simultaneousGesture(
                sequencedDragGesture,
                including: isEnabled ? .all : .subviews
            )
            .onChange(of: sequencedGestureIsRecognized) { _, isRecognized in
                guard !isRecognized, sequencedDragIsActive else { return }
                cancelSequencedDrag()
            }
    }
#endif

    private var dragGesture: some Gesture {
        DragGesture(coordinateSpace: coordinateSpace)
            .onChanged { value in
                if !dragIsActive {
                    dragIsActive = true
                    onStart()
                }
                onUpdate(value.translation)
            }
            .onEnded { value in
                dragIsActive = false
                onEnd(value.translation)
            }
    }

    private var legacyLongPressGesture: some Gesture {
        LongPressGesture(
            minimumDuration: minimumDuration,
            maximumDistance: allowableMovement
        )
        .sequenced(
            before: DragGesture(
                minimumDistance: 0.0,
                coordinateSpace: coordinateSpace
            )
        )
        .onChanged { value in
            switch value {
            case .first(true), .second(true, _):
                guard !legacyLongPressIsActive else { return }
                legacyLongPressIsActive = true
                scheduleExtendedPress()
                onStart()
            default:
                break
            }
        }
        .onEnded { _ in
            guard legacyLongPressIsActive else { return }
            legacyLongPressIsActive = false
            cancelExtendedPress()
            onEnd(nil)
        }
    }

    private var sequencedDragGesture: some Gesture {
        LongPressGesture(
            minimumDuration: minimumDuration,
            maximumDistance: allowableMovement
        )
        .sequenced(
            before: DragGesture(
                minimumDistance: 0.0,
                coordinateSpace: coordinateSpace
            )
        )
        .updating($sequencedGestureIsRecognized) { value, isRecognized, _ in
            switch value {
            case .first(true), .second(true, _):
                isRecognized = true
            default:
                break
            }
        }
        .onChanged { value in
            switch value {
            case .first(true):
                activateSequencedDragIfNeeded()
            case .second(true, let dragValue):
                activateSequencedDragIfNeeded()
                guard let dragValue else { return }
                let translation = dragValue.translation
                lastSequencedDragTranslation = translation
                cancelExtendedPressAfterMovement(translation)
                onUpdate(translation)
            default:
                break
            }
        }
        .onEnded { value in
            if case .second(true, let dragValue) = value,
               let dragValue {
                lastSequencedDragTranslation = dragValue.translation
            }
            endSequencedDrag()
        }
    }

    private func activateSequencedDragIfNeeded() {
        guard !sequencedDragIsActive else { return }
        sequencedDragIsActive = true
        scheduleExtendedPress()
        onStart()
    }

    private func endSequencedDrag() {
        guard sequencedDragIsActive else { return }
        let translation = lastSequencedDragTranslation ?? .zero
        resetSequencedDrag()
        onEnd(translation)
    }

    private func cancelSequencedDrag() {
        guard sequencedDragIsActive else { return }
        resetSequencedDrag()
        onEnd(nil)
    }

    private func resetSequencedDrag() {
        cancelExtendedPress()
        sequencedDragIsActive = false
        lastSequencedDragTranslation = nil
    }

    private func scheduleExtendedPress() {
        guard let onExtendedPress else { return }
        cancelExtendedPress()
        let workItem = DispatchWorkItem(block: onExtendedPress)
        extendedPressWorkItem = workItem
        DispatchQueue.main.asyncAfter(
            deadline: .now() + max(extendedDuration - minimumDuration, 0.0),
            execute: workItem
        )
    }

    private func cancelExtendedPressAfterMovement(_ translation: CGSize) {
        guard hypot(translation.width, translation.height) > allowableMovement else { return }
        cancelExtendedPress()
    }

    private func cancelExtendedPress() {
        extendedPressWorkItem?.cancel()
        extendedPressWorkItem = nil
    }
}

#if os(iOS)
@available(iOS 18.0, *)
private struct PlatformLongPressDragGesture: UIGestureRecognizerRepresentable {

    let isEnabled: Bool
    let minimumDuration: TimeInterval
    let extendedDuration: TimeInterval
    let allowableMovement: CGFloat
    let onPressingChanged: ((Bool) -> Void)?
    let onExtendedPress: (() -> Void)?
    let onStart: () -> Void
    let onUpdate: (CGSize) -> Void
    let onEnd: (CGSize?) -> Void

    final class Coordinator {
        var startLocation: CGPoint?
        var extendedPressWorkItem: DispatchWorkItem?
        weak var connectedScrollView: UIScrollView?

        func reset() {
            extendedPressWorkItem?.cancel()
            extendedPressWorkItem = nil
            startLocation = nil
        }
    }

    final class Recognizer: UILongPressGestureRecognizer {

        var onPressingChanged: ((Bool) -> Void)?

        private var isPressing: Bool = false

        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
            super.touchesBegan(touches, with: event)
            setPressing(true)
        }

        override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
            super.touchesMoved(touches, with: event)
            if state == .failed {
                setPressing(false)
            }
        }

        override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
            super.touchesEnded(touches, with: event)
            setPressing(false)
        }

        override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
            super.touchesCancelled(touches, with: event)
            setPressing(false)
        }

        override func reset() {
            super.reset()
            setPressing(false)
        }

        private func setPressing(_ isPressing: Bool) {
            guard self.isPressing != isPressing else { return }
            self.isPressing = isPressing
            onPressingChanged?(isPressing)
        }
    }

    func makeCoordinator(converter: CoordinateSpaceConverter) -> Coordinator {
        Coordinator()
    }

    func makeUIGestureRecognizer(context: Context) -> Recognizer {
        let recognizer = Recognizer()
        recognizer.minimumPressDuration = minimumDuration
        recognizer.allowableMovement = allowableMovement
        recognizer.cancelsTouchesInView = false
        recognizer.onPressingChanged = onPressingChanged
        recognizer.isEnabled = isEnabled
        return recognizer
    }

    func updateUIGestureRecognizer(
        _ recognizer: Recognizer,
        context: Context
    ) {
        recognizer.minimumPressDuration = minimumDuration
        recognizer.allowableMovement = allowableMovement
        recognizer.onPressingChanged = onPressingChanged
        recognizer.isEnabled = isEnabled
        if !isEnabled {
            context.coordinator.reset()
        }
        connectEnclosingScrollView(recognizer, coordinator: context.coordinator)
    }

    /// Makes an enclosing scroll view's pan wait for this recognizer to fail.
    ///
    /// Without this the scroll view's pan claims the touch and the drag never
    /// moves anything. Moving beyond `allowableMovement` fails this recognizer
    /// early, so a plain swipe still scrolls.
    private func connectEnclosingScrollView(
        _ recognizer: Recognizer,
        coordinator: Coordinator
    ) {
        DispatchQueue.main.async {
            NSLog("[LPD] connect view=\(String(describing: recognizer.view)) scroll=\(String(describing: recognizer.view?.enclosingScrollView))")
            guard
                let scrollView = recognizer.view?.enclosingScrollView,
                coordinator.connectedScrollView !== scrollView
            else { return }
            scrollView.panGestureRecognizer.require(toFail: recognizer)
            coordinator.connectedScrollView = scrollView
            NSLog("[LPD] connected to scroll view")
        }
    }

    func handleUIGestureRecognizerAction(
        _ recognizer: Recognizer,
        context: Context
    ) {
        let coordinator = context.coordinator
        let location = recognizer.location(in: nil)
        NSLog("[LPD] state=\(recognizer.state.rawValue) location=\(location)")

        switch recognizer.state {
        case .began:
            coordinator.startLocation = location
            scheduleExtendedPress(coordinator: coordinator)
            onStart()
        case .changed:
            guard let startLocation = coordinator.startLocation else { return }
            let translation = CGSize(
                width: location.x - startLocation.x,
                height: location.y - startLocation.y
            )
            if hypot(translation.width, translation.height) > allowableMovement {
                coordinator.extendedPressWorkItem?.cancel()
                coordinator.extendedPressWorkItem = nil
            }
            onUpdate(translation)
        case .ended:
            guard let startLocation = coordinator.startLocation else { return }
            let translation = CGSize(
                width: location.x - startLocation.x,
                height: location.y - startLocation.y
            )
            coordinator.reset()
            onEnd(translation)
        case .cancelled:
            guard coordinator.startLocation != nil else { return }
            coordinator.reset()
            onEnd(nil)
        case .failed:
            coordinator.reset()
        default:
            break
        }
    }

    private func scheduleExtendedPress(coordinator: Coordinator) {
        guard let onExtendedPress else { return }
        let workItem = DispatchWorkItem(block: onExtendedPress)
        coordinator.extendedPressWorkItem = workItem
        DispatchQueue.main.asyncAfter(
            deadline: .now() + max(extendedDuration - minimumDuration, 0.0),
            execute: workItem
        )
    }
}
#endif
