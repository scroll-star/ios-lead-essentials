//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Stoyan Kostov on 28.06.23.
//

import XCTest

final class FeedImagePresenter {
    init(view: Any) {

    }
}

final class FeedImagePresenterTests: XCTestCase {

    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()

        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
}

// MARK: - Helpers (private)

private extension FeedImagePresenterTests {

    func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: FeedImagePresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }

    final class ViewSpy {
        let messages = [Any]()
    }
}
