//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Stoyan Kostov on 6.06.23.
//

import Foundation

struct RemoteFeedItem: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}
