//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Stoyan Kostov on 2.07.23.
//

import Foundation

public protocol FeedCache {
    typealias Result = Swift.Result<Void, Error>

    func save(_ feed: [FeedImage], completion: @escaping (Result) -> Void)
}
