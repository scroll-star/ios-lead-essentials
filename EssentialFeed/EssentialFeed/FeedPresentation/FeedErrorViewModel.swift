//
//  FeedErrorViewModel.swift
//  EssentialFeed
//
//  Created by Stoyan Kostov on 28.06.23.
//

public struct FeedErrorViewModel {
    public let message: String?

    static var noError: FeedErrorViewModel {
        .init(message: nil)
    }

    static func error(message: String) -> FeedErrorViewModel {
        .init(message: message)
    }
}
