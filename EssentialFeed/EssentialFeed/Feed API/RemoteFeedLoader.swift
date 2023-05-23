//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Stoyan Kostov on 23.05.23.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL)
}

public final class RemoteFeedLoader {
    let client: HTTPClient
    let url: URL
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    public func load() {
        client.get(from: url)
    }
}
