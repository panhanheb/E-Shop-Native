import Foundation

extension Order {
    private static let day: TimeInterval = 86_400

    /// Sample delivery address.
    static let mockAddress = ShippingAddress(
        fullName: "Alex Morgan",
        phone: "+855 12 345 678",
        street: "No. 12, Street 240",
        city: "Phnom Penh"
    )

    /// Sample order history for previews, mock services, and tests.
    static let mocks: [Order] = [
        makeMock(
            number: "MA-100238",
            products: [(Product.mocks[2], 2), (Product.mocks[4], 1)],
            status: .shipped,
            paymentMethod: .khqr,
            createdAt: Date.now.addingTimeInterval(-2 * day)
        ),
        makeMock(
            number: "MA-100201",
            products: [(Product.mocks[1], 1)],
            status: .delivered,
            paymentMethod: .cashOnDelivery,
            createdAt: Date.now.addingTimeInterval(-12 * day)
        )
    ]

    /// A single sample order.
    static var mock: Order { mocks[0] }

    /// Builds an order whose totals follow `ShippingPolicy`.
    static func makeMock(
        number: String,
        products: [(Product, Int)],
        status: OrderStatus = .pending,
        paymentMethod: PaymentMethod = .cashOnDelivery,
        address: ShippingAddress = mockAddress,
        createdAt: Date = .now
    ) -> Order {
        let items = products.map { product, quantity in
            OrderItem(productID: product.id, name: product.name, unitPrice: product.price, quantity: quantity)
        }
        let subtotal = items.reduce(Decimal.zero) { $0 + $1.unitPrice * Decimal($1.quantity) }
        let shippingFee = ShippingPolicy.fee(forSubtotal: subtotal)
        return Order(
            id: UUID(),
            number: number,
            items: items,
            subtotal: subtotal,
            shippingFee: shippingFee,
            total: subtotal + shippingFee,
            status: status,
            shippingAddress: address,
            paymentMethod: paymentMethod,
            createdAt: createdAt
        )
    }
}
