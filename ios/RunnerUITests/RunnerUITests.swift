import XCTest

@MainActor
class RunnerUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testScreenshots() throws {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

        // Wait for app to load
        sleep(3)

        // Screenshot 1: Main send page
        snapshot("01-send-page")

        let receiveButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Receive' OR label CONTAINS[c] 'Empfangen'")).firstMatch
        receiveButton.tap()

        // Screenshot 2: Receive page
        sleep(1)
        snapshot("02-receive-page")

        let settingsButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Settings' OR label CONTAINS[c] 'Einstellungen'")).firstMatch
        settingsButton.tap()

        // Screenshot 3: Settings page
        sleep(1)
        snapshot("03-settings-page")
    }
}
