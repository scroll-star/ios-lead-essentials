//
//  XCTestCase+MemoryLeakTracking.swift
//  EssentialAppTests
//
//  Created by Stoyan Kostov on 1.07.23.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
}
