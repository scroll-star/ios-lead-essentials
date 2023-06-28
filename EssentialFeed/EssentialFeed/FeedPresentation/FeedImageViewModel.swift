//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by Stoyan Kostov on 28.06.23.
//

public struct FeedImageViewModel<Image> {
    public let description: String?
    public let location: String?
    public let image: Image?
    public let isLoading: Bool
    public let shouldRetry: Bool

    public var hasLocation: Bool {
        location != nil
    }
}
