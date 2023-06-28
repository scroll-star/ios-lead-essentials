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
        let (_, view) = makeSUT()

        _ = FeedPresenter(view: view)

        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
}

// MARK: - Helpers (private)

private extension FeedPresenterTests {

    func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(view: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }

    final class ViewSpy {
        let messages = [Any]()
    }
}
