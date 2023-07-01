//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Stoyan Kostov on 1.07.23.
//

import Foundation

public protocol FeedImageDataStore {

    typealias Result = Swift.Result<Data?, Error>

    func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void)
}
