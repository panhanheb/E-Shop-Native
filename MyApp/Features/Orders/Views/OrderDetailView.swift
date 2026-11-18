import SwiftUI

/// Read-only details of a placed order: progress tracker, items, delivery, payment, and totals.
struct OrderDetailView: View {
    /// The order to display.
    let order: Order

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    HStack(alignment: .firstTextBaseline) {
                        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                            Text(order.number)
                                .font(AppFont.headline)
                            Text(order.createdAt, format: .dateTime.day().month().year().hour().minute())
                                .font(AppFont.caption)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                        Spacer()
                        OrderStatusBadge(status: order.status)
                    }
                    OrderProgressView(status: order.status)
                }
                .padding(.vertical, AppSpacing.xs)
            }

            Section("Items") {
                ForEach(order.items) { item in
                    HStack(alignment: .center, spacing: AppSpacing.sm + AppSpacing.xxs) {
                        Text(verbatim: "\(item.quantity)×")
                            .font(AppFont.captionEmphasized.monospacedDigit())
                            .foregroundStyle(AppColors.primary)
                            .frame(width: 32, height: 32)
                            .background(AppColors.primarySoft, in: RoundedRectangle(cornerRadius: AppRadius.small, style: .continuous))
                        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                            Text(item.name)
                                .font(AppFont.subheadline.weight(.medium))
                            Text(item.unitPrice, format: .currency(code: AppCurrency.code))
                                .font(AppFont.caption)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                        Spacer()
                        Text(item.unitPrice * Decimal(item.quantity), format: .currency(code: AppCurrency.code))
                            .font(AppFont.subheadline.weight(.semibold).monospacedDigit())
                    }
                }
            }

            Section("Delivery") {
                HStack(alignment: .top, spacing: AppSpacing.sm + AppSpacing.xxs) {
                    IconTile(systemImage: AppImages.address)
                    VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                        Text(order.shippingAddress.fullName)
                            .font(AppFont.subheadline.weight(.semibold))
                        Text(order.shippingAddress.phone)
                        Text("\(order.shippingAddress.street), \(order.shippingAddress.city)")
                    }
                    .font(AppFont.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
                }
            }

            Section("Payment") {
                HStack(spacing: AppSpacing.sm + AppSpacing.xxs) {
                    IconTile(systemImage: order.paymentMethod.systemImage)
                    Text(order.paymentMethod.title)
                        .font(AppFont.subheadline)
                }
            }

            Section("Summary") {
                PriceSummaryView(subtotal: order.subtotal, shippingFee: order.shippingFee, total: order.total)
                    .padding(.vertical, AppSpacing.xs)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(AppColors.background)
        .navigationTitle("Order Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        OrderDetailView(order: .mock)
    }
}
