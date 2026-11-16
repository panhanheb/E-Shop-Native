import SwiftUI

/// Inline, non-blocking error message.
struct ErrorBanner: View {
    /// User-facing error text.
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.sm) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(AppColor.danger)
                .accessibilityHidden(true)
            Text(message)
                .font(AppFont.callout)
                .foregroundStyle(AppColor.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityIdentifier("errorBanner.message")
        }
        .padding(AppSpacing.md)
        .background(AppColor.danger.opacity(0.12), in: RoundedRectangle(cornerRadius: AppRadius.medium))
    }
}

#Preview {
    ErrorBanner(message: "Incorrect email or password.")
        .padding()
}
