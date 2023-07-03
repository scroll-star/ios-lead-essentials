//
//  FeedSnapshotTests.swift
//  EssentialAppTests
//
//  Created by Stoyan Kostov on 3.07.23.
//

import EssentialFeediOS
import XCTest

final class FeedSnapshotTests: XCTestCase {

    func test_emptyFeed() {
        let sut = makeSUT()

        sut.display(model: emptyFeed)

        record(snapshot: sut.snapshot(), named: "EMPTY_FEED")
    }
}

// MARK: - Helpers

private extension FeedSnapshotTests {
    var emptyFeed: [FeedImageCellController] { [] }

    func makeSUT() -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! FeedViewController
        controller.loadViewIfNeeded()
        return controller
    }

    func record(
        snapshot: UIImage,
        named name: String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        guard let snapshotData = snapshot.pngData() else {
            XCTFail("Failed to generate PNG data representation from snapshot", file: file, line: line)
            return
        }

        let snapshotURL = URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("Snapshots")
            .appendingPathComponent("\(name).png")

        do {
            try FileManager.default.createDirectory(
                at: snapshotURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )

            try snapshotData.write(to: snapshotURL)
        } catch {
            XCTFail("Failed to record snapshot with error: \(error)", file: file, line: line)
        }
    }
}

extension UIViewController {
    func snapshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        return renderer.image { action in
            view.layer.render(in: action.cgContext)
        }
    }
}
