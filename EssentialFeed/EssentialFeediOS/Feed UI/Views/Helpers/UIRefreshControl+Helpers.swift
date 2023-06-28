//
//  UIRefreshControl+Helpers.swift
//  EssentialFeediOS
//
//  Created by Stoyan Kostov on 28.06.23.
//

import UIKit

extension UIRefreshControl {
    func update(isRefreshing: Bool) {
        isRefreshing ? beginRefreshing() : endRefreshing()
    }
}
