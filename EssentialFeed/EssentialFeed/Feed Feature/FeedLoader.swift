//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Stoyan Kostov on 22.05.23.
//

import Foundation

public typealias LoadFeedResult = Result<[FeedImage], Error>

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
