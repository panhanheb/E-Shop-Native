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
    func testLoginWithDemoCredentialsShowsTasks() {
        let app = launchApp()

        signIn(app, email: "demo@example.com", password: "password123")

        XCTAssertTrue(app.navigationBars["Tasks"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testLoginWithWrongPasswordShowsError() {
        let app = launchApp()

        signIn(app, email: "demo@example.com", password: "wrong-password")

        XCTAssertTrue(app.staticTexts["errorBanner.message"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testSignOutReturnsToLogin() {
        let app = launchApp()
        signIn(app, email: "demo@example.com", password: "password123")
        XCTAssertTrue(app.navigationBars["Tasks"].waitForExistence(timeout: 5))

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
}
