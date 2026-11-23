//
//  ManyTimeUITests.swift
//  ManyTimeUITests
//
//  Created by Domenic Murtari on 2/5/25.
//

import XCTest

final class ManyTimeUITests: XCTestCase {

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.

    // In UI tests it is usually best to stop immediately when a failure occurs.
    continueAfterFailure = false

    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  #if os(macOS)
  @MainActor
  func testAddCityTimeZone() throws {
    let app = XCUIApplication()
    app.launchEnvironment["MANYTIME_UI_TEST_SAVE_KEY"] = "UITest-\(UUID().uuidString)"
    app.launch()

    let statusItem = app.statusItems.firstMatch
    XCTAssertTrue(statusItem.waitForExistence(timeout: 10))
    statusItem.click()
    app.descendants(matching: .any)["Options"].firstMatch.click()
    app.menuItems["Preferences"].click()
    let zonesTab = app.descendants(matching: .any)["Time Zones"].firstMatch
    XCTAssertTrue(zonesTab.waitForExistence(timeout: 10))
    zonesTab.click()
    app.buttons["City"].click()

    let search = app.textFields["Search for a city"]
    XCTAssertTrue(search.waitForExistence(timeout: 10))
    search.click()
    search.typeText("Tokyo")
    let city = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Tokyo,")).firstMatch
    XCTAssertTrue(city.waitForExistence(timeout: 10))
    city.click()

    let add = app.buttons["Add"]
    XCTAssertTrue(add.isEnabled)
    add.click()
    XCTAssertTrue(app.staticTexts["Tokyo"].waitForExistence(timeout: 10))
  }
  #endif

  @MainActor
  func testLaunchPerformance() throws {
    if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
      // This measures how long it takes to launch your application.
      measure(metrics: [XCTApplicationLaunchMetric()]) {
        XCUIApplication().launch()
      }
    }
  }
}
