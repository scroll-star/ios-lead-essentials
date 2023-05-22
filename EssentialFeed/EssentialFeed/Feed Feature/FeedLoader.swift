//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Stoyan Kostov on 22.05.23.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
