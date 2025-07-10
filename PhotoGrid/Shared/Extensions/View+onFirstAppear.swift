import SwiftUI

/// This implementation is copied from somewhere!!
public extension View {
    func onFirstAppear(_ action: @escaping () -> Void) -> some View {
        modifier(FirstTask(action: {
            Task { action() }
        }))
    }

    func onFirstAppear(_ action: @escaping () async -> Void) -> some View {
        modifier(FirstTask(action: {
            Task { await action() }
        }))
    }
}

private struct FirstTask: ViewModifier {
    let action: () -> Void
    @State private var hasAppeared = false

    func body(content: Content) -> some View {
        content.task {
            guard !hasAppeared else { return }
            hasAppeared = true
            action()
        }
    }
}

