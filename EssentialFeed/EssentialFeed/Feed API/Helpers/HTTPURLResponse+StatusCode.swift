//
//  HTTPURLResponse+StatusCode.swift
//  EssentialFeed
//
//  Created by Stoyan Kostov on 29.06.23.
//

import Foundation

extension HTTPURLResponse {
    private static var OK_200: Int { return 200 }

    var isOK: Bool {
        return statusCode == HTTPURLResponse.OK_200
    }
}
