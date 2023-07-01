//
//  SharedTestHelpers.swift
//  EssentialAppTests
//
//  Created by Stoyan Kostov on 1.07.23.
//

import Foundation
import EssentialFeed

func anyURL() -> URL {
    URL(string: "http://a-url.com")!
}

func anyNSError() -> NSError {
    NSError(domain: "any error", code: 0)
}

func anyData() -> Data {
    Data("any data".utf8)
}

func uniqueFeed() -> [FeedImage] {
    [FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())]
}
