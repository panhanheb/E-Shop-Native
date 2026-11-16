import Foundation

extension Product {
    /// Exact USD amount from cents (avoids floating-point rounding in `Decimal` literals).
    private static func usd(_ cents: Int) -> Decimal {
        Decimal(cents) / 100
    }

    // swiftlint:disable function_parameter_count
    private static func make(
        _ name: String,
        _ tagline: String,
        _ details: String,
        price: Int,
        originalPrice: Int? = nil,
        category: ProductCategory,
        rating: Double,
        reviews: Int,
        stock: Int
    ) -> Product {
        Product(
            id: UUID(),
            name: name,
            tagline: tagline,
            details: details,
            price: usd(price),
            originalPrice: originalPrice.map(usd),
            category: category,
            imageURL: nil,
            rating: rating,
            reviewCount: reviews,
            stock: stock
        )
    }
    // swiftlint:enable function_parameter_count

    /// Sample beauty catalog for previews, mock services, and tests.
    static let mocks: [Product] = [
        make(
            "Radiance Serum", "Brightening & Glow",
            "A lightweight vitamin C serum that evens skin tone and boosts radiance. Suitable for all skin types. 30 ml.",
            price: 2499, originalPrice: 3299, category: .skincare, rating: 4.6, reviews: 126, stock: 25
        ),
        make(
            "Hydra Moisturizer", "24H Hydration",
            "Hyaluronic acid gel-cream that keeps skin plump and hydrated all day without feeling greasy. 50 ml.",
            price: 1999, category: .skincare, rating: 4.4, reviews: 98, stock: 40
        ),
        make(
            "Matte Lipstick", "Long Lasting Color",
            "Velvety matte finish with rich pigment that lasts up to 12 hours. Enriched with vitamin E.",
            price: 1499, category: .makeup, rating: 4.7, reviews: 156, stock: 60
        ),
        make(
            "Glow Foundation", "Natural Finish",
            "Buildable medium coverage with a luminous, skin-like finish. SPF 15. 30 ml.",
            price: 2299, category: .makeup, rating: 4.5, reviews: 112, stock: 18
        ),
        make(
            "Rose Eau de Parfum", "Floral & Romantic",
            "Fresh Damask rose with notes of pink pepper and soft musk. 50 ml.",
            price: 4800, originalPrice: 6000, category: .fragrance, rating: 4.8, reviews: 87, stock: 12
        ),
        make(
            "Luxe Day Cream", "Firming & Smooth",
            "Rich peptide day cream that firms, smooths, and protects with SPF 20. 50 ml.",
            price: 2950, originalPrice: 3500, category: .skincare, rating: 4.3, reviews: 64, stock: 30
        ),
        make(
            "Argan Repair Shampoo", "Smooth & Shiny",
            "Sulfate-free shampoo with argan oil that repairs dry, damaged hair. 300 ml.",
            price: 1600, category: .haircare, rating: 4.2, reviews: 73, stock: 45
        ),
        make(
            "Silk Hair Oil", "Frizz Control",
            "Lightweight finishing oil that tames frizz and adds a glossy shine. 100 ml.",
            price: 1850, category: .haircare, rating: 4.5, reviews: 58, stock: 8
        ),
        make(
            "Pro Brush Set", "10-Piece Collection",
            "Soft synthetic brushes for face and eyes, with a vegan leather travel case.",
            price: 3200, originalPrice: 4600, category: .tools, rating: 4.6, reviews: 141, stock: 20
        ),
        make(
            "Jade Face Roller", "De-puff & Relax",
            "Natural jade roller for a soothing facial massage that reduces puffiness.",
            price: 2100, category: .tools, rating: 4.1, reviews: 39, stock: 0
        )
    ]

    /// A single in-stock sample product.
    static var mock: Product { mocks[0] }

    /// A sample product that is out of stock.
    static var mockOutOfStock: Product { mocks[9] }
}
