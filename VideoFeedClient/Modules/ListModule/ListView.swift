//
//  ViewController.swift
//  VideoFeedClient
//
//  Created by Chris on 16.11.2022.
//

import UIKit
import Reachability
import NotificationBannerSwift

protocol ListViewActions: BaseView {
    func setState()
    func closeToHeader()
}

class ListView: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet private weak var mainView: RoundedCornerView!
    @IBOutlet private weak var robotIcon: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet public private(set) weak var videosCollectionView: UICollectionView!
    @IBOutlet private weak var collectionViewContainer: UIView!
    @IBOutlet private weak var robotHeight: NSLayoutConstraint!
    @IBOutlet private weak var robotIcoTop: NSLayoutConstraint!
    @IBOutlet private weak var robotIcoLeading: NSLayoutConstraint!
    @IBOutlet private weak var mainViewBottomConstraint: NSLayoutConstraint!

    // MARK: - Private Properties
    private var isCollapsed: Bool = false
    private var currentPage: Int = 1
    private var refreshControl:UIRefreshControl?

    // MARK: - Public Properties
    public var indexOfCellBeforeDragging = 0
    // MARK: - public properties
    var presenter: ListAction!

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.videosCollectionView.register(VideoCollectionViewCell.nib, forCellWithReuseIdentifier: VideoCollectionViewCell.reuseID)
        self.collectionViewContainer.isHidden = true
        self.videosCollectionView.isPagingEnabled = true

        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.loadData), for: .valueChanged)
        self.videosCollectionView.addSubview(refreshControl)
        self.refreshControl = refreshControl
        self.presenter.configureView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.closeToHeader()
            self.presenter.loadVideos()
        }
    }

    @objc func loadData() {
        refreshControl?.beginRefreshing()
        self.presenter.resetPage()
        self.presenter.loadVideos()
     }

    func stopRefresher() {
        refreshControl?.endRefreshing()
     }
}

// MARK: - ListView + ListViewActions
extension ListView: ListViewActions {
    func setState() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.videosCollectionView.reloadData()
        self.stopRefresher()
    }

    func closeToHeader() {
        self.isCollapsed = true
        UIView.animate(withDuration: Constants.animationDuration) { [weak self] in
            guard let self = self else { return }
            self.mainView.leftBottomRadius = Constants.ClosedHeader.mainViewBottomRadius
            self.mainView.rightBottomRadius = Constants.ClosedHeader.mainViewBottomRadius
            self.robotIcoTop.constant = Constants.ClosedHeader.RobotIcon.topInset
            self.robotIcoLeading.constant = Constants.ClosedHeader.RobotIcon.leading
            self.robotHeight.constant = Constants.ClosedHeader.RobotIcon.height
            self.mainViewBottomConstraint.constant = self.view.frame.height - Constants.ClosedHeader.SearchBlock.leading
            self.view.bringSubviewToFront(self.mainView)
            self.view.bringSubviewToFront(self.collectionViewContainer)
            self.view.layoutIfNeeded()
        } completion: { [weak self] _ in
            guard let self = self else { return }
            self.collectionViewContainer.isHidden = false
        }
    }
}
