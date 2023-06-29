//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Stoyan Kostov on 8.06.23.
//

import Foundation

func anyNSError() -> NSError {
    NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
    URL(string: "http://any-url.com")!
}

func anyData() -> Data {
    Data("any data".utf8)
}
