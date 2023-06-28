//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Stoyan Kostov on 28.06.23.
//

import XCTest

final class FeedPresenter {
    init(view: Any) {

    }
}

final class FeedPresenterTests: XCTestCase {

    func test_init_doesNotSendMessagesToView() {
        let view = ViewSpy()

        _ = FeedPresenter(view: view)

        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
}

// MARK: - Helpers (private)

private extension FeedPresenterTests {

    final class ViewSpy {
        let messages = [Any]()
    }

}
