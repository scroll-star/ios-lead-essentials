//
//  UIRefreshControl+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Stoyan Kostov on 21.06.23.
//

import UIKit

extension UIRefreshControl {

    func simulatePullToRefresh() {
        simulate(event: .valueChanged)
    }
}
