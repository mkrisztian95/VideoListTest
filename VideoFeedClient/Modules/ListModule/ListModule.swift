//
//  SearchModule.swift
//  VideoFeedClient
//
//  Created by Chris on 16.11.2022.
//

import UIKit

final class ListModule: BaseModule {
    private let view: ListView
    private let presenter: ListPresenter

    init() {
        view = R.storyboard.listView.listView()! // swiftlint:disable:this force_unwrapping
        presenter = ListPresenter(view: view)
        view.presenter = presenter
    }

    func viewController() -> UIViewController {
        return view
    }
}
