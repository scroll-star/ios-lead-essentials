//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Stoyan Kostov on 22.05.23.
//

import Foundation

public enum LoadFeedResult<Error: Swift.Error> {
    case success([FeedItem])
    case failure(Error)
}

protocol FeedLoader {
    associatedtype Error: Swift.Error

    func load(completion: @escaping (LoadFeedResult<Error>) -> Void)
}

extension LoadFeedResult: Equatable where Error: Equatable {}
