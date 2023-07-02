//
//  FeedLoaderCacheDecorator.swift
//  EssentialApp
//
//  Created by Stoyan Kostov on 2.07.23.
//

import EssentialFeed

public final class FeedLoaderCacheDecorator: FeedLoader {
    private let decoratee: FeedLoader
    private let cache: FeedCache

    public init(decoratee: FeedLoader, cache: FeedCache) {
        self.decoratee = decoratee
        self.cache = cache
    }

    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load(completion: { [weak self] result in
            completion(result.map { feed in
                self?.cache.save(feed, completion: { _ in })
                return feed
            })
        })
    }
}
