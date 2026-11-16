import SwiftUI

/// Shows a `ToastView` at the bottom of the screen while `message` is non-nil, then clears it.
struct ToastModifier: ViewModifier {
    @Binding var message: String?
    var duration: Duration = .seconds(1.8)

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                if let message {
                    ToastView(message: message)
                        .padding(.bottom, AppSpacing.lg)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .task(id: message) {
                            try? await Task.sleep(for: duration)
                            withAnimation { self.message = nil }
                        }
                }
            }
            .animation(.spring(duration: 0.35), value: message)
    }
}

extension View {
    /// Presents a short-lived toast whenever `message` is set.
    func toast(message: Binding<String?>) -> some View {
        modifier(ToastModifier(message: message))
    }
}
