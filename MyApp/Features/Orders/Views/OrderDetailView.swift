import SwiftUI

/// Read-only details of a placed order.
struct OrderDetailView: View {
    /// The order to display.
    let order: Order

    var body: some View {
        List {
            Section {
                LabeledContent("Order Number", value: order.number)
                LabeledContent("Placed On") {
                    Text(order.createdAt, format: .dateTime.day().month().year().hour().minute())
                }
                LabeledContent("Status") {
                    OrderStatusBadge(status: order.status)
                }
            }

            Section("Items") {
                ForEach(order.items) { item in
                    HStack(alignment: .firstTextBaseline) {
                        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                            Text(item.name)
                                .font(AppFont.callout)
                            Text("\(item.quantity) × \(item.unitPrice.formatted(.currency(code: AppCurrency.code)))")
                                .font(AppFont.caption)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                        Spacer()
                        Text(item.unitPrice * Decimal(item.quantity), format: .currency(code: AppCurrency.code))
                            .font(AppFont.callout)
                    }
                }
            }

            Section("Delivery") {
                Label {
                    VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                        Text(order.shippingAddress.fullName)
                        Text(order.shippingAddress.phone)
                            .foregroundStyle(AppColors.textSecondary)
                        Text("\(order.shippingAddress.street), \(order.shippingAddress.city)")
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    .font(AppFont.callout)
                } icon: {
                    Image(systemName: AppImages.address)
                }
            }

            Section("Payment") {
                Label(order.paymentMethod.title, systemImage: order.paymentMethod.systemImage)
            }

            Section {
                PriceSummaryView(subtotal: order.subtotal, shippingFee: order.shippingFee, total: order.total)
            }
        }
        .navigationTitle(order.number)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        OrderDetailView(order: .mock)
    }
}
