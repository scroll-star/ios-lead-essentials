//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Stoyan Kostov on 22.05.23.
//

import XCTest
import EssentialFeed

final class RemoteFeedLoaderTests: XCTestCase {
    private var client: HTTPClientSpy!
    
    override func setUp() {
        super.setUp()
        client = .init()
    }
    
    func test_init_doesNotRequestDataFromURL() {
        _ = makeSUT()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestsDataFromURL() {
        let sut = makeSUT()
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://url.com")!
        let sut = makeSUT(url: url)
        
        sut.load()
        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
}

// MARK: Utils

private extension RemoteFeedLoaderTests {
    func makeSUT(url: URL = URL(string: "https://some-url.com")!) -> RemoteFeedLoader {
        let sut = RemoteFeedLoader(url: url, client: client)
        return sut
    }
    
    final class HTTPClientSpy: HTTPClient {
        var requestedURL: URL?
        var requestedURLs: [URL] = []
        
        func get(from url: URL) {
            requestedURL = url
            requestedURLs.append(url)
        }
    }
}
