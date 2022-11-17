//
//  ListPresenter.swift
//  VideoFeedClient
//
//  Created by Chris on 16.11.2022.
//

import Foundation
import Alamofire
import BrightFutures

protocol ListAction: BasePresenter {
    func loadVideos()
    func loadMore()
    func resetPage()
    var movies: [MovieCellViewModel] { get }
}

final class ListPresenter: ListAction {

    // MARK: - Public properties
    unowned var view: ListViewActions
    var movies: [MovieCellViewModel] {
        return moviesVM
    }

    // MARK: - Private Properties
    private var initialPage: Int {
        return Int.random(in: 1...50)
    }

    private var currentPage: Int = 1
    private var itemsPerPage: Int = 5
    private var moviesVM: [MovieCellViewModel] = []
    private var timer = Timer()

    // MARK: - Initialization
    init(view: ListViewActions) {
        self.view = view
    }

    func configureView() {
        resetPage()
        self.view.setState()
    }

    func resetPage() {
        moviesVM = []
        currentPage = initialPage
    }

    func loadVideos() {
        ListAPI().fetchVideos(page: currentPage, numberOfItems: itemsPerPage)
            .onSuccess { [weak self] wrapper in
                guard let strongSelf = self else { return }
                if let result = wrapper.videos {
                    strongSelf.moviesVM.append(contentsOf: result.map({ item in
                        return MovieCellViewModel(model: item)
                    }))
                    strongSelf.moviesVM = strongSelf.moviesVM.unique{$0.id == $1.id}
                    print(strongSelf.moviesVM.count)
                    strongSelf.view.setState()
                }
            }
            .onFailure { err in
                Logger.logError(err: err)
            }
    }

    func loadMore() {
        self.currentPage += 1
        self.loadVideos()
    }
}


extension Array {
    func unique(selector:(Element,Element)->Bool) -> Array<Element> {
        return reduce(Array<Element>()){
            if let last = $0.last {
                return selector(last,$1) ? $0 : $0 + [$1]
            } else {
                return [$1]
            }
        }
    }
}
