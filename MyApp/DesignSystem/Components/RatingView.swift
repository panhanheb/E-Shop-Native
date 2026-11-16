import SwiftUI

/// Star rating with the average and the number of reviews, e.g. "★ 4.6 (1,284)".
struct RatingView: View {
    /// Average rating from 0 to 5.
    let rating: Double
    /// Number of reviews.
    let reviewCount: Int

    var body: some View {
        HStack(spacing: AppSpacing.xxs) {
            Image(systemName: AppImages.star)
                .foregroundStyle(AppColors.warning)
                .accessibilityHidden(true)
            Text(rating, format: .number.precision(.fractionLength(1)))
                .foregroundStyle(AppColors.textPrimary)
            Text("(\(reviewCount))")
                .foregroundStyle(AppColors.textSecondary)
        }
        .font(AppFont.caption)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    RatingView(rating: 4.6, reviewCount: 1284)
}
