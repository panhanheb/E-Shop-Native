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
                .foregroundStyle(AppColors.primary)
        }
        .font(AppFont.callout.weight(.medium))
        .foregroundStyle(.white)
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
        .background(Color.black.opacity(0.85), in: Capsule())
        .shadow(color: AppColors.shadow, radius: 8, y: 4)
        .accessibilityIdentifier("toast.message")
    }
}

#Preview {
    ToastView(message: "Radiance Serum added to your bag")
        .padding()
}
