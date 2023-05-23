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
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let sut = makeSUT()
        
        sut.load()
        
        XCTAssertFalse(client.requestedURLs.isEmpty)
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://url.com")!
        let sut = makeSUT(url: url)
        
        sut.load()
        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let sut = makeSUT()
        
        var capturedErrors: [RemoteFeedLoader.Error] = []
        sut.load { error in
            capturedErrors.append(error)
        }
        
        let clientError = NSError(domain: "Test", code: 0)
        client.completions[0](clientError)
        
        XCTAssertEqual(capturedErrors, [.connectivity])
    }
}

// MARK: Utils

private extension RemoteFeedLoaderTests {
    func makeSUT(url: URL = URL(string: "https://some-url.com")!) -> RemoteFeedLoader {
        let sut = RemoteFeedLoader(url: url, client: client)
        return sut
    }
    
    final class HTTPClientSpy: HTTPClient {
        var requestedURLs: [URL] = []
        var completions = [(Error) -> Void]()

        func get(from url: URL, completion: @escaping (Error) -> Void) {
            requestedURLs.append(url)
            completions.append(completion)
        }
    }
}
