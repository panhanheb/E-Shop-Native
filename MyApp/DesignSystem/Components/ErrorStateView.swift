import SwiftUI

/// Full-screen error state with an optional retry action.
struct ErrorStateView: View {
    private let message: String
    private let retryAction: (() -> Void)?

    /// Creates an error state.
    /// - Parameters:
    ///   - message: User-facing description of what went wrong.
    ///   - retryAction: Shows a "Try Again" button when provided.
    init(message: String, retryAction: (() -> Void)? = nil) {
        self.message = message
        self.retryAction = retryAction
    }

    var body: some View {
        ContentUnavailableView {
            Label("Something Went Wrong", systemImage: AppImages.warning)
        } description: {
            Text(message)
        } actions: {
            if let retryAction {
                Button("Try Again", action: retryAction)
                    .buttonStyle(.borderedProminent)
            }
        }
    }
}

#Preview {
    ErrorStateView(message: "You appear to be offline.") {}
}
