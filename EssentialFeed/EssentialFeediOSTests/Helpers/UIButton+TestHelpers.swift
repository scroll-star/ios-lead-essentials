//
//  UIButton+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Stoyan Kostov on 21.06.23.
//

import UIKit

extension UIButton {
    func simulateTap() {
        simulate(event: .touchUpInside)
    }
}
