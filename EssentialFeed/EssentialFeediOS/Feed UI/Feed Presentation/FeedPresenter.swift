//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Stoyan Kostov on 23.06.23.
//

import EssentialFeed


struct FeedLoadingViewModel {
    let isLoading: Bool
}

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

struct FeedViewModel {
    let feed: [FeedImage]
}

protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

final class FeedPresenter {
    var feedView: FeedView?
    var loadingView: FeedLoadingView?

    func didStartLoadingFeed() {
        loadingView?.display(FeedLoadingViewModel(isLoading: true))
    }

    func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView?.display(.init(feed: feed))
        loadingView?.display(.init(isLoading: false))
    }

    func didFinishLoadingFeed(with error: Error) {
        loadingView?.display(.init(isLoading: false))
    }
}
