import SwiftUI

/// Small dark capsule with a check mark, used for brief confirmations like "Added to your bag".
struct ToastView: View {
    let message: String

    var body: some View {
        Label {
            Text(message)
                .lineLimit(2)
        } icon: {
            Image(systemName: AppImages.success)
                .foregroundStyle(AppColors.success)
        }
        .font(AppFont.callout.weight(.medium))
        .foregroundStyle(.white)
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
        .background(Color(white: 0.12).opacity(0.95), in: Capsule())
        .shadow(color: .black.opacity(0.15), radius: 12, y: 6)
        .accessibilityIdentifier("toast.message")
    }
}

#Preview {
    ToastView(message: "Radiance Serum added to your bag")
        .padding()
}
