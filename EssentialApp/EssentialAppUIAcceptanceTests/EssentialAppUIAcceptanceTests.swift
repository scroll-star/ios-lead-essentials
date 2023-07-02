//
//  EssentialAppUITests.swift
//  EssentialAppUITests
//
//  Created by Stoyan Kostov on 1.07.23.
//

import XCTest

final class EssentialAppUIAcceptanceTests: XCTestCase {

    func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
        let app = makeSUTAndLaunch(options: .reset, .connectivity(.online))

        let feedCells = app.cells.matching(identifier: "feed-image-cell")
        XCTAssertEqual(feedCells.count, 2)

        let firstImage = app.images.matching(identifier: "feed-image-view").firstMatch
        XCTAssertTrue(firstImage.exists)
    }

    func test_onLaunch_displaysCachedRemoteFeedWhenCustomerHasNoConnectivity() {
        makeSUTAndLaunch(options: .reset, .connectivity(.online))

        let offlineApp = makeSUTAndLaunch(options: .connectivity(.offline))

        let cachedFeedCells = offlineApp.cells.matching(identifier: "feed-image-cell")
        XCTAssertEqual(cachedFeedCells.count, 2)

        let firstCachedImage = offlineApp.images.matching(identifier: "feed-image-view").firstMatch
        XCTAssertTrue(firstCachedImage.exists)
    }

    func test_onLaunch_displaysEmptyFeedWhenCustomerHasNoConnectivityAndNoCache() {
        let app = makeSUTAndLaunch(options: .reset, .connectivity(.offline))

        let feedCells = app.cells.matching(identifier: "feed-image-cell")
        XCTAssertEqual(feedCells.count, 0)
    }
}

// MARK: - Helpers (private)

private extension EssentialAppUIAcceptanceTests {
    enum Connectivity: String {
        case online
        case offline
    }

    enum Option {
        case reset
        case connectivity(Connectivity)
    }

    @discardableResult
    func makeSUTAndLaunch(options: Option...) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = options.mapToLaunchArguments()
        app.launch()
        return app
    }
}

private extension Array where Element == EssentialAppUIAcceptanceTests.Option {
    func mapToLaunchArguments() -> [String] {
        flatMap { option in
            switch option {
            case .reset:
                return ["-reset"]
            case let .connectivity(connectivity):
                return ["-connectivity", connectivity.rawValue]
            }
        }
    }
}
