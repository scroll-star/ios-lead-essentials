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
        let url = URL(string: "https://some-url.com")!
        let client = HTTPClientSpy()
        _ = RemoteFeedLoader(url: url, client: client)
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        let url = URL(string: "https://some-url.com")!
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }
}

// MARK: Utils

private extension RemoteFeedLoaderTests {
    func makeSUT(url: URL = URL(string: "https://some-url.com")!) -> RemoteFeedLoader {
        let sut = RemoteFeedLoader(url: url, client: client)
        return sut
    }
    
    class HTTPClientSpy: HTTPClient {
        func get(from url: URL) {
            requestedURL = url
        }
        var requestedURL: URL?
    }
}
