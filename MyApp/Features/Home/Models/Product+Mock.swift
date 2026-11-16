import Foundation

extension Product {
    /// Exact USD amount from cents (avoids floating-point rounding in `Decimal` literals).
    private static func usd(_ cents: Int) -> Decimal {
        Decimal(cents) / 100
    }

    /// Sample catalog for previews, mock services, and tests.
    static let mocks: [Product] = [
        Product(
            id: UUID(),
            name: "Wireless Earbuds Pro",
            details: "Active noise cancelling, 30-hour battery life with the charging case, and water resistance for workouts.",
            price: usd(5999),
            originalPrice: usd(7999),
            category: .electronics,
            imageURL: nil,
            rating: 4.6,
            reviewCount: 1284,
            stock: 25
        ),
        Product(
            id: UUID(),
            name: "Smart Watch S2",
            details: "Heart-rate and sleep tracking, GPS, and a bright always-on display.",
            price: usd(12900),
            originalPrice: nil,
            category: .electronics,
            imageURL: nil,
            rating: 4.4,
            reviewCount: 842,
            stock: 12
        ),
        Product(
            id: UUID(),
            name: "Cotton Crew T-Shirt",
            details: "Soft 100% cotton in a relaxed fit. Machine washable.",
            price: usd(1250),
            originalPrice: nil,
            category: .fashion,
            imageURL: nil,
            rating: 4.3,
            reviewCount: 510,
            stock: 100
        ),
        Product(
            id: UUID(),
            name: "Classic Denim Jacket",
            details: "Timeless denim jacket with button front and two chest pockets.",
            price: usd(4500),
            originalPrice: usd(6000),
            category: .fashion,
            imageURL: nil,
            rating: 4.5,
            reviewCount: 233,
            stock: 0
        ),
        Product(
            id: UUID(),
            name: "Ceramic Coffee Mug Set",
            details: "Set of four 350 ml stoneware mugs. Dishwasher and microwave safe.",
            price: usd(1890),
            originalPrice: nil,
            category: .home,
            imageURL: nil,
            rating: 4.7,
            reviewCount: 389,
            stock: 40
        ),
        Product(
            id: UUID(),
            name: "LED Desk Lamp",
            details: "Adjustable brightness and color temperature with a USB charging port.",
            price: usd(2499),
            originalPrice: nil,
            category: .home,
            imageURL: nil,
            rating: 4.2,
            reviewCount: 156,
            stock: 8
        ),
        Product(
            id: UUID(),
            name: "Vitamin C Serum",
            details: "Brightening daily serum with 15% vitamin C and hyaluronic acid. 30 ml.",
            price: usd(1575),
            originalPrice: nil,
            category: .beauty,
            imageURL: nil,
            rating: 4.5,
            reviewCount: 972,
            stock: 60
        ),
        Product(
            id: UUID(),
            name: "Non-Slip Yoga Mat",
            details: "6 mm cushioning with a textured grip surface and carrying strap.",
            price: usd(2200),
            originalPrice: usd(2800),
            category: .sports,
            imageURL: nil,
            rating: 4.6,
            reviewCount: 641,
            stock: 30
        )
    ]

    /// A single in-stock sample product.
    static var mock: Product { mocks[0] }

    /// A sample product that is out of stock.
    static var mockOutOfStock: Product { mocks[3] }
}
