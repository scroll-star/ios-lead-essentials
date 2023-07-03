//
//  UIView+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Stoyan Kostov on 3.07.23.
//

import UIKit

extension UIView {
    func enforceLayoutCycle() {
        layoutIfNeeded()
        RunLoop.current.run(until: Date())
    }
}
