import SwiftUI

/// Five-star rating with the number of reviews, e.g. "★★★★½ (126)".
struct RatingView: View {
    /// Average rating from 0 to 5.
    let rating: Double
    /// Number of reviews.
    let reviewCount: Int
    /// Star size.
    var starSize: CGFloat = 10

    private func symbol(for index: Int) -> String {
        let value = rating - Double(index)
        if value >= 0.75 { return AppImages.star }
        if value >= 0.25 { return AppImages.starHalf }
        return AppImages.starEmpty
    }

    var body: some View {
        HStack(spacing: AppSpacing.xxs) {
            HStack(spacing: 1) {
                ForEach(0..<5, id: \.self) { index in
                    Image(systemName: symbol(for: index))
                        .font(.system(size: starSize))
                        .foregroundStyle(AppColors.star)
                }
            }
            Text("(\(reviewCount))")
                .font(AppFont.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Rated \(rating, specifier: "%.1f") out of 5, \(reviewCount) reviews"))
    }
}

#Preview {
    VStack(alignment: .leading) {
        RatingView(rating: 4.6, reviewCount: 126)
        RatingView(rating: 3.2, reviewCount: 8, starSize: 14)
    }
}
