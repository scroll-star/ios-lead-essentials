//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Stoyan Kostov on 30.05.23.
//

import XCTest
import EssentialFeed

final class URLSessionHTTPClientTests: XCTestCase {

    var expectationTimeout: TimeInterval { 1.0 }

    override func tearDown() {
        super.tearDown()

        URLProtocolStub.removeStub()
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

        let receivedError = resultErrorFor((data: nil, response: nil, error: requestError))
        let receivedNSError = (receivedError as NSError?)

        XCTAssertEqual(receivedNSError?.code, requestError.code)
        XCTAssertEqual(receivedNSError?.domain, requestError.domain)
    }

    func test_getFromURL_failsOnAllInvalidRepresentationCases() {
        XCTAssertNotNil(resultErrorFor((data: nil, response: nil, error: nil)))
        XCTAssertNotNil(resultErrorFor((data: nil, response: nonHTTPURLResponse(), error: nil)))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nil, error: nil)))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nil, error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: nil, response: nonHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: nil, response: anyHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nonHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: anyHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nonHTTPURLResponse(), error: nil)))
    }

    func test_getFromURL_succeedsOnHTTPURLResponseWithData() {
        let data = anyData()
        let response = anyHTTPURLResponse()

        let receivedValues = resultValuesFor((data: data, response: response, error: nil))

        XCTAssertEqual(receivedValues?.data, data)
        XCTAssertEqual(receivedValues?.response.url, response.url)
        XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
    }

    func test_getFromURL_succeedsWithEmptyDataOnHTTPURLResponseWithNilData() {
        let response = anyHTTPURLResponse()

        let receivedValues = resultValuesFor((data: nil, response: response, error: nil))

        let emptyData = Data()
        XCTAssertEqual(receivedValues?.data, emptyData)
        XCTAssertEqual(receivedValues?.response.url, response.url)
        XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
    }

    func test_cancelGetFromURLTask_cancelsURLRequest() {
        let receivedError = resultErrorFor(taskHandler: { $0.cancel() }) as NSError?

        XCTAssertEqual(receivedError?.code, URLError.cancelled.rawValue)
    }
}

// MARK - Utils (private)

private extension URLSessionHTTPClientTests {
    
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> HTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)

        let sut = URLSessionHTTPClient(session: session)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    func resultValuesFor(
        _ values: (data: Data?, response: URLResponse?, error: Error?),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (data: Data, response: HTTPURLResponse)? {
        let result = resultFor(values, file: file, line: line)

        switch result {
        case let .success((data, response)):
            return (data, response)
        default:
            XCTFail("Expected success, got \(result) instead", file: file, line: line)
            return nil
        }
    }

    func resultErrorFor(
        _ values: (data: Data?, response: URLResponse?, error: Error?)? = nil,
        taskHandler: (HTTPClientTask) -> Void = { _ in },
        file: StaticString = #file,
        line: UInt = #line
    ) -> Error? {
        let result = resultFor(values, taskHandler: taskHandler, file: file, line: line)
        switch result {
        case let .failure(error):
            return error
        default:
            XCTFail("Expected failure, got \(result) instead", file: file, line: line)
            return nil
        }
    }

    func resultFor(
        _ values: (data: Data?, response: URLResponse?, error: Error?)?,
        taskHandler: (HTTPClientTask) -> Void = { _ in },
        file: StaticString = #file,
        line: UInt = #line
    ) -> HTTPClient.Result {
        values.map { URLProtocolStub.stub(data: $0, response: $1, error: $2) }
        let sut = makeSUT(file: file, line: line)
        let exp = expectation(description: "Wait for completion")

        var receivedResult: HTTPClient.Result!
        taskHandler(sut.get(from: anyURL()) { result in
            receivedResult = result
            exp.fulfill()
        })

        wait(for: [exp], timeout: expectationTimeout)
        return receivedResult
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

        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
            let requestObserver: ((URLRequest) -> Void)?
        }

        private static let queue = DispatchQueue(label: "URLProtocolStub.queue")

        private static var _stub: Stub?
        private static var stub: Stub? {
            get { return queue.sync { _stub } }
            set { queue.sync { _stub = newValue } }
        }

        static func stub(
            data: Data?,
            response: URLResponse?,
            error: Error? = nil
        ) {
            stub = Stub(data: data, response: response, error: error, requestObserver: nil)
        }
        
        static func removeStub() {
            stub = nil
        }

        static func observeRequests(observer: @escaping (URLRequest) -> Void) {
            stub = Stub(data: nil, response: nil, error: nil, requestObserver: observer)
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            request
        }
        
        override func startLoading() {
            guard let stub = URLProtocolStub.stub else { return }

            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            }

            if let response = stub.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }

            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            } else {
                client?.urlProtocolDidFinishLoading(self)
            }
            stub.requestObserver?(request)
        }
        
        override func stopLoading() {}
    }
}
