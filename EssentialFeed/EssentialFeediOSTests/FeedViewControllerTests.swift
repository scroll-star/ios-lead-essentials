//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Stoyan Kostov on 20.06.23.
//

import XCTest

final class FeedViewController {
    fileprivate init(loader: FeedViewControllerTests.LoaderSpy) {

    }
}

final class FeedViewControllerTests: XCTestCase {

    func test_init_doesNotLoadFeed() {
        let loader = LoaderSpy()
        _ = FeedViewController(loader: loader)

        XCTAssertEqual(loader.loadCallCount, 0)
    }
}

// MARK: - Helpers (private)

private extension FeedViewControllerTests {

    final class LoaderSpy {
        private(set) var loadCallCount: Int = 0
    }
}
