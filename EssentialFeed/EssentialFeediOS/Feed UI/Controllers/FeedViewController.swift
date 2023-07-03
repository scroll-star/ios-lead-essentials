//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Stoyan Kostov on 20.06.23.
//

import EssentialFeed
import UIKit

public protocol FeedViewControllerDelegate: AnyObject {
    func didRequestFeedRefresh()
}

public final class FeedViewController: UITableViewController, FeedLoadingView {
    public var delegate: FeedViewControllerDelegate?

    @IBOutlet public private(set) var errorView: ErrorView?

    private var tableModel = [FeedImageCellController]() {
        didSet {
            tableView.reloadData()
        }
    }

    private var cellControllers = [IndexPath: FeedImageCellController]()

    override public func viewDidLoad() {
        super.viewDidLoad()
        refresh()
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        tableView.sizeTableHeaderToFit()
    }

    public func display(_ viewModel: FeedLoadingViewModel) {
        refreshControl?.update(isRefreshing: viewModel.isLoading)
    }

    public func display(model: [FeedImageCellController]) {
        tableModel = model
    }

    @IBAction private func refresh() {
        delegate?.didRequestFeedRefresh()
    }

    private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
        tableModel[indexPath.row]
    }

    private func removeCellController(forRowAt indexPath: IndexPath) {
        cellControllers[indexPath] = nil
    }

    private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
        cellController(forRowAt: indexPath).cancelLoad()
    }
}

// MARK: - FeedErrorView

extension FeedViewController: FeedErrorView {

    public func display(_ viewModel: FeedErrorViewModel) {
        errorView?.message = viewModel.message
    }
}

// MARK: - UITableViewDataSource

extension FeedViewController {

    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableModel.count
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cellController(forRowAt: indexPath).view(in: tableView)
    }

    override public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelCellControllerLoad(forRowAt: indexPath)
    }
}

// MARK: - UITableViewDataSourcePrefetching

extension FeedViewController: UITableViewDataSourcePrefetching {

    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath).preload()
        }
    }

    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelCellControllerLoad)
    }
}
