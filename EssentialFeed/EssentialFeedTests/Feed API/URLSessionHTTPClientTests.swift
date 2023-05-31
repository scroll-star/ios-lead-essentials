//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Stoyan Kostov on 30.05.23.
//

import XCTest
import EssentialFeed

final class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }

    struct UnexpectedValuesRepresentationError: Error {}
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success(data, response))
            } else {
                completion(.failure(UnexpectedValuesRepresentationError()))
            }
        }.resume()
    }
}

final class URLSessionHTTPClientTests: XCTestCase {

    var expectationTimeout: TimeInterval { 1.0 }

    override func setUp() {
        super.setUp()

        URLProtocolStub.startInterceptingRequests()
    }

    override func tearDown() {
        super.tearDown()

        URLProtocolStub.stopInterceptingRequests()
    }
}

// MARK: - Tests

extension URLSessionHTTPClientTests {

    func test_getFromURL_performsGETRequestWithURL() {
        let url = anyURL()
        let exp = expectation(description: "Wait for request")

        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }

        makeSUT().get(from: url) { _ in }

        wait(for: [exp], timeout: expectationTimeout)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let requestError = NSError(domain: "any error", code: 1)

        let receivedError = resultErrorFor(data: nil, response: nil, error: requestError)
        let receivedNSError = (receivedError as NSError?)

        XCTAssertEqual(receivedNSError?.code, requestError.code)
        XCTAssertEqual(receivedNSError?.domain, requestError.domain)
    }

    func test_getFromURL_failsOnAllInvalidRepresentationCases() {
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: nil))
    }

    func test_getFromURL_succeedsOnHTTPURLResponseWithData() {
        let data = anyData()
        let response = anyHTTPURLResponse()
        URLProtocolStub.stub(data: data, response: response, error: nil)

        let exp = expectation(description: "Wait for completion")

        makeSUT().get(from: anyURL()) { result in
            switch result {
            case let .success(receivedData, receivedResponse):
                XCTAssertEqual(receivedData, data)
                XCTAssertEqual(receivedResponse.url, response.url)
                XCTAssertEqual(receivedResponse.statusCode, response.statusCode)
            default:
                XCTFail("Expected success, got \(result) instead")
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: expectationTimeout)
    }

    func test_getFromURL_succeedsWithEmptyDataOnHTTPURLResponseWithNilData() {
        let response = anyHTTPURLResponse()
        URLProtocolStub.stub(data: nil, response: response, error: nil)

        let exp = expectation(description: "Wait for completion")

        makeSUT().get(from: anyURL()) { result in
            switch result {
            case let .success(receivedData, receivedResponse):
                let emptyData = Data()
                XCTAssertEqual(receivedData, emptyData)
                XCTAssertEqual(receivedResponse.url, response.url)
                XCTAssertEqual(receivedResponse.statusCode, response.statusCode)
            default:
                XCTFail("Expected success, got \(result) instead")
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: expectationTimeout)
    }
}

// MARK - Utils (private)

private extension URLSessionHTTPClientTests {
    
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    func resultErrorFor(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Error? {
        URLProtocolStub.stub(data: data, response: response, error: error)
        let sut = makeSUT(file: file, line: line)
        let exp = expectation(description: "Wait for completion")

        var receivedError: Error?
        sut.get(from: anyURL()) { result in
            switch result {
            case let .failure(error):
                receivedError = error
            default:
                XCTFail("Expected failure, got \(result) instead", file: file, line: line)
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: expectationTimeout)

        return receivedError
    }

    func anyURL() -> URL {
        .init(string: "http://any-url.com")!
    }

    func anyData() -> Data {
        .init("any data".utf8)
    }

    func anyNSError() -> NSError {
        .init(domain: "any error", code: 0)
    }

    func anyHTTPURLResponse() -> HTTPURLResponse {
        .init(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }

    func nonHTTPURLResponse() -> URLResponse {
        .init(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
}

// MARK - Namespace types

private extension URLSessionHTTPClientTests {
    
    final class URLProtocolStub: URLProtocol {
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?

        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(
            data: Data?,
            response: URLResponse?,
            error: Error? = nil
        ) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }

        static func observeRequests(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            request
        }
        
        override func startLoading() {
            if let data = Self.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }

            if let response = Self.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }

            if let error = Self.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }

            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
}
