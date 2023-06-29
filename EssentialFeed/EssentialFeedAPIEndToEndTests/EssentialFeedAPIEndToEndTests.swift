//
//  EssentialFeedAPIEndToEndTests.swift
//  EssentialFeedAPIEndToEndTests
//
//  Created by Stoyan Kostov on 31.05.23.
//

import XCTest
import EssentialFeed

final class EssentialFeedAPIEndToEndTests: XCTestCase {

    func test_endToEndTestServerGETFeedResult_matchesFixedTestAccountData() {
        switch getFeedResult() {
        case let .success(imageFeed)?:
            XCTAssertEqual(imageFeed.count, 8, "Expected 8 items in the test account feed")
            XCTAssertEqual(imageFeed[0], expectedItem(at: 0))
            XCTAssertEqual(imageFeed[1], expectedItem(at: 1))
            XCTAssertEqual(imageFeed[2], expectedItem(at: 2))
            XCTAssertEqual(imageFeed[3], expectedItem(at: 3))
            XCTAssertEqual(imageFeed[4], expectedItem(at: 4))
            XCTAssertEqual(imageFeed[5], expectedItem(at: 5))
            XCTAssertEqual(imageFeed[6], expectedItem(at: 6))
            XCTAssertEqual(imageFeed[7], expectedItem(at: 7))

        case let .failure(error)?:
            XCTFail("Expected successful feed result, got \(error) instead")

        default:
            XCTFail("Expected successful feed result, got no result instead")
        }
    }
}

// MARK: - Helpers (private)

private extension EssentialFeedAPIEndToEndTests {

    var feedTestServerURL: URL {
        URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
    }

    func ephemeralClient(file: StaticString = #file, line: UInt = #line) -> HTTPClient {
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        trackForMemoryLeaks(client, file: file, line: line)
        return client
    }

    func getFeedResult(file: StaticString = #file, line: UInt = #line) -> FeedLoader.Result? {
        let loader = RemoteFeedLoader(url: feedTestServerURL, client: ephemeralClient())
        trackForMemoryLeaks(loader, file: file, line: line)

        let exp = expectation(description: "Wait for load completion")

        var receivedResult: FeedLoader.Result?
        loader.load { result in
            receivedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 15.0)

        return receivedResult
    }

    func getFeedImageDataResult(file: StaticString = #file, line: UInt = #line) -> FeedImageDataLoader.Result? {
        let loader = RemoteFeedImageDataLoader(client: ephemeralClient())
        trackForMemoryLeaks(loader, file: file, line: line)

        let exp = expectation(description: "Wait for load completion")

        let url = feedTestServerURL.appendingPathComponent("73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6/image")

        var receivedResult: FeedImageDataLoader.Result?
        _ = loader.loadImageData(from: url) { result in
            receivedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5.0)

        return receivedResult
    }

    func expectedImage(at index: Int) -> FeedImage {
        .init(
            id: id(at: index),
            description: description(at: index),
            location: location(at: index),
            url: imageURL(at: index)
        )
    }

    func id(at index: Int) -> UUID {
        UUID(uuidString: [
            "73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6",
            "BA298A85-6275-48D3-8315-9C8F7C1CD109",
            "5A0D45B3-8E26-4385-8C5D-213E160A5E3C",
            "FF0ECFE2-2879-403F-8DBE-A83B4010B340",
            "DC97EF5E-2CC9-4905-A8AD-3C351C311001",
            "557D87F1-25D3-4D77-82E9-364B2ED9CB30",
            "A83284EF-C2DF-415D-AB73-2A9B8B04950B",
            "F79BD7F8-063F-46E2-8147-A67635C3BB01"
        ][index])!
    }

    func description(at index: Int) -> String? {
        [
            "Description 1",
            nil,
            "Description 3",
            nil,
            "Description 5",
            "Description 6",
            "Description 7",
            "Description 8"
        ][index]
    }

    func location(at index: Int) -> String? {
        [
            "Location 1",
            "Location 2",
            nil,
            nil,
            "Location 5",
            "Location 6",
            "Location 7",
            "Location 8"
        ][index]
    }

    func imageURL(at index: Int) -> URL {
        .init(string: "https://url-\(index+1).com")!
    }
}
