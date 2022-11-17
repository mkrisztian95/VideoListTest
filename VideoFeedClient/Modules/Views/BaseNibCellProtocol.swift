//
//  BaseNibCellProtocol.swift
//  VideoFeedClient
//
//  Created by Chris on 16.11.2022.
//

import UIKit

public protocol ReusableCell {
    static var reuseID: String { get }
}

public extension ReusableCell {
    static var reuseID: String {
        return String(describing: self)
    }
}

protocol BaseNibCellProtocol: ReusableCell {
    static var nib: UINib { get }
}

class BaseCollectionNibCell: UICollectionViewCell, BaseNibCellProtocol {
    static var nib: UINib {
        return UINib(nibName: reuseID, bundle: nil)
    }
}
