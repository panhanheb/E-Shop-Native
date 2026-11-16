import SwiftUI

/// Full-screen loading indicator with a message.
struct LoadingView: View {
    private let message: LocalizedStringKey

    /// Creates a loading view showing `message`.
    init(message: LocalizedStringKey = "Loading…") {
        self.message = message
    }

    var body: some View {
        ProgressView {
            Text(message)
                .font(AppFont.callout)
                .foregroundStyle(AppColor.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    LoadingView(message: "Loading tasks…")
}
