//
//  FeedLoaderWithFallbackComposite.swift
//  EssentialApp
//
//  Created by Stoyan Kostov on 1.07.23.
//

import EssentialFeed

public final class FeedLoaderWithFallbackComposite: FeedLoader {
    private let primary: FeedLoader
    private let fallback: FeedLoader

    public init(primary: FeedLoader, fallback: FeedLoader) {
        self.primary = primary
        self.fallback = fallback
    }

    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        primary.load(completion: { [weak self] result in
            switch result {
            case .success:
                completion(result)
            case .failure:
                self?.fallback.load(completion: completion)
            }
        })
    }
}
