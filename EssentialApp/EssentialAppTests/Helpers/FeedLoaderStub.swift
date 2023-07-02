//
//  FeedLoaderStub.swift
//  EssentialAppTests
//
//  Created by Stoyan Kostov on 1.07.23.
//

import EssentialFeed

final class FeedLoaderStub: FeedLoader {
    private let result: FeedLoader.Result

    init(result: FeedLoader.Result) {
        self.result = result
    }

    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        completion(result)
    }
}
