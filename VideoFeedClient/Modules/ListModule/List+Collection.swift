//
//  Search+Collection.swift
//  VideoFeedClient
//
//  Created by Chris on 16.11.2022.
//

import Foundation
import UIKit

extension ListView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.movies.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCollectionViewCell.reuseID, for: indexPath) as? VideoCollectionViewCell {
            if presenter.movies.indices.contains(indexPath.row) {
                cell.setUp(vm: presenter.movies[indexPath.row])
            }
            return cell
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let widht = self.videosCollectionView.frame.width
        let height = self.videosCollectionView.frame.height
        return CGSize(width: widht, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? VideoCollectionViewCell {
            cell.startVideo()
        }
        let lastElement = presenter.movies.count - Constants.preloadIndex
        if indexPath.row == lastElement {
            presenter.loadMore()
        }
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? VideoCollectionViewCell {
            cell.pauseVideo()
        }
    }
}
