//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Stoyan Kostov on 22.05.23.
//

import Foundation

public struct FeedItem {
    let id: UUID
    let description: String?
    let location: String?
    let imageURL: URL
}
