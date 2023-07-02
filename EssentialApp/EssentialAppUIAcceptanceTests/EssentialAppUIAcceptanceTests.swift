//
//  EssentialAppUITests.swift
//  EssentialAppUITests
//
//  Created by Stoyan Kostov on 1.07.23.
//

import XCTest

final class EssentialAppUIAcceptanceTests: XCTestCase {

    func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
        let app = XCUIApplication()

        app.launch()

        XCTAssertEqual(app.cells.count, 22)
        XCTAssert(app.cells.images.count >= 1)
    }
}
