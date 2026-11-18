import SwiftUI

/// Placeholder shown when a screen has no content, with an optional call to action.
struct EmptyStateView: View {
    private let title: LocalizedStringKey
    private let systemImage: String
    private let message: LocalizedStringKey?
    private let actionTitle: LocalizedStringKey?
    private let action: (() -> Void)?

    /// Creates an empty state.
    init(
        title: LocalizedStringKey,
        systemImage: String,
        message: LocalizedStringKey? = nil,
        actionTitle: LocalizedStringKey? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.systemImage = systemImage
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: systemImage)
        } description: {
            if let message {
                Text(message)
            }
        } actions: {
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                    .controlSize(.large)
            }
        }
    }
}

#Preview {
    EmptyStateView(
        title: "Your Cart Is Empty",
        systemImage: AppImages.cart,
        message: "Browse the shop and add something you like.",
        actionTitle: "Start Shopping"
    ) {}
}
