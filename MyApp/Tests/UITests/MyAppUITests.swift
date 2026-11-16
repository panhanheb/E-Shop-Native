import XCTest

/// End-to-end flows against the instant mock backend (`-ui-testing`).
final class MyAppUITests: XCTestCase {
    @MainActor
    func testLoginScreenAppearsOnLaunch() {
        let app = launchApp()

        XCTAssertTrue(app.textFields["login.email"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.secureTextFields["login.password"].exists)
        XCTAssertFalse(app.buttons["login.submit"].isEnabled)
    }

    @MainActor
    func testLoginWithDemoCredentialsShowsShop() {
        let app = launchApp()

        signIn(app, email: "demo@example.com", password: "password123")

        XCTAssertTrue(app.navigationBars["Shop"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testLoginWithWrongPasswordShowsError() {
        let app = launchApp()

        signIn(app, email: "demo@example.com", password: "wrong-password")

        XCTAssertTrue(app.staticTexts["errorBanner.message"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testBuyProductFromShopToConfirmation() {
        let app = launchApp()
        signIn(app, email: "demo@example.com", password: "password123")
        XCTAssertTrue(app.navigationBars["Shop"].waitForExistence(timeout: 5))

        // Open the first product and add it to the cart.
        let firstProduct = app.buttons.matching(identifier: "product.card").firstMatch
        XCTAssertTrue(firstProduct.waitForExistence(timeout: 5))
        firstProduct.tap()

        let addToCart = app.buttons["productDetail.addToCart"]
        XCTAssertTrue(addToCart.waitForExistence(timeout: 5))
        addToCart.tap()
        app.alerts.buttons["OK"].tap()

        // Go to the cart and start checkout.
        app.tabBars.buttons["Cart"].tap()
        let checkout = app.buttons["cart.checkout"]
        XCTAssertTrue(checkout.waitForExistence(timeout: 5))
        checkout.tap()

        // Fill in the delivery address (name is pre-filled from the profile).
        type("012345678", into: app.textFields["checkout.phone"])
        type("No. 12, Street 240", into: app.textFields["checkout.street"])
        type("Phnom Penh", into: app.textFields["checkout.city"])

        let placeOrder = app.buttons["checkout.placeOrder"]
        for _ in 0..<5 where !placeOrder.isHittable {
            app.swipeUp()
        }
        placeOrder.tap()

        XCTAssertTrue(app.buttons["checkout.done"].waitForExistence(timeout: 5))
        app.buttons["checkout.done"].tap()

        // The cart is empty after the order is placed.
        XCTAssertFalse(app.buttons["cart.checkout"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testSignOutReturnsToLogin() {
        let app = launchApp()
        signIn(app, email: "demo@example.com", password: "password123")
        XCTAssertTrue(app.navigationBars["Shop"].waitForExistence(timeout: 5))

        app.tabBars.buttons["Profile"].tap()
        let signOut = app.buttons["profile.signOut"]
        XCTAssertTrue(signOut.waitForExistence(timeout: 5))
        signOut.tap()
        app.buttons["Sign Out"].firstMatch.tap()

        XCTAssertTrue(app.textFields["login.email"].waitForExistence(timeout: 5))
    }

    // MARK: - Helpers

    @MainActor
    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing"]
        app.launch()
        return app
    }

    @MainActor
    private func signIn(_ app: XCUIApplication, email: String, password: String) {
        let emailField = app.textFields["login.email"]
        XCTAssertTrue(emailField.waitForExistence(timeout: 5))
        emailField.tap()
        emailField.typeText(email)

        let passwordField = app.secureTextFields["login.password"]
        passwordField.tap()
        passwordField.typeText(password)

        app.buttons["login.submit"].tap()
    }

    @MainActor
    private func type(_ text: String, into field: XCUIElement) {
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap()
        field.typeText(text)
    }
}
