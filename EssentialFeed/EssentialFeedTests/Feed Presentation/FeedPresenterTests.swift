//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Stoyan Kostov on 28.06.23.
//

import XCTest

struct FeedErrorViewModel {
    let message: String?

    static var noError: FeedErrorViewModel {
        FeedErrorViewModel(message: nil)
    }
}

protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

final class FeedPresenter {
    private let errorView: FeedErrorView

    init(errorView: FeedErrorView) {
        self.errorView = errorView
    }

    func didStartLoadingFeed() {
        errorView.display(.noError)
    }
}

final class FeedPresenterTests: XCTestCase {

    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()

        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }

    func test_didStartLoadingFeed_displaysNoErrorMessage() {
        let (sut, view) = makeSUT()

        sut.didStartLoadingFeed()

        XCTAssertEqual(view.messages, [.display(errorMessage: .none)])
    }
}

// MARK: - Helpers (private)

private extension FeedPresenterTests {

    func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(errorView: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }

    final class ViewSpy: FeedErrorView {
        enum Message: Equatable {
            case display(errorMessage: String?)
        }

        private(set) var messages = [Message]()

        func display(_ viewModel: FeedErrorViewModel) {
            messages.append(.display(errorMessage: viewModel.message))
        }
    }
}
