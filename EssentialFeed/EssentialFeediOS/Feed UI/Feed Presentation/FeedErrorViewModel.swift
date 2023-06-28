//
//  FeedErrorViewModel.swift
//  EssentialFeediOS
//
//  Created by Stoyan Kostov on 28.06.23.
//

struct FeedErrorViewModel {
    let message: String?

    static var noError: FeedErrorViewModel {
        .init(message: nil)
    }

    static func error(message: String) -> FeedErrorViewModel {
        .init(message: message)
    }
}
