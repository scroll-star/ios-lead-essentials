//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Stoyan Kostov on 5.06.23.
//

import XCTest
import EssentialFeed

final class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date

    init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }

    func save(_ items: [FeedItem]) {
        store.deleteCachedFeed(completion: { [unowned self] error in
            if error == nil {
                self.store.insert(items, timestamp: self.currentDate())
            }
        })
    }
}

final class FeedStore {
    typealias DeletionCompletion = (Error?) -> Void

    var deleteCachedFeedCallCount = 0
    var insertCallCount = 0

    private var deletionCompletions = [DeletionCompletion]()

    var insertions = [(items: [FeedItem], timestamp: Date)]()

    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deleteCachedFeedCallCount += 1
        deletionCompletions.append(completion)
    }

    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }

    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }

    func insert(_ items: [FeedItem], timestamp: Date) {
        insertCallCount += 1
        insertions.append((items, timestamp))
    }
}

final class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }

    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]

        sut.save(items)

        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
    }

    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()

        sut.save(items)
        store.completeDeletion(with: deletionError)

        XCTAssertEqual(store.insertCallCount, 0)
    }

    func test_save_requestsNewCacheInsertionOnSuccessfulDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]

        sut.save(items)
        store.completeDeletionSuccessfully()

        XCTAssertEqual(store.insertCallCount, 1)
    }

    func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT(currentDate: { timestamp })

        sut.save(items)
        store.completeDeletionSuccessfully()

        XCTAssertEqual(store.insertions.count, 1)
        XCTAssertEqual(store.insertions.first?.items, items)
        XCTAssertEqual(store.insertions.first?.timestamp, timestamp)
    }
}

// MARK: - Helpers

private extension CacheFeedUseCaseTests {
    func makeSUT(
        currentDate: @escaping () -> Date = Date.init,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }

    func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    }

    func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }

    func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
}
