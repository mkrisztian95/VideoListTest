//
//  UINavigationController+Extension.swift
//  VideoFeedClient
//
//  Created by Chris on 16.11.2022.
//

import UIKit

extension UINavigationController {
    func replaceTopViewController(with viewController: UIViewController, animated: Bool) {
        replaceTopViewControllers(count: 1, with: [viewController], animated: animated)
    }

    func replaceTopViewControllers(count: Int, with viewControllers: [UIViewController], animated: Bool) {
        var vcs = self.viewControllers
        if count <= vcs.count {
            vcs.removeLast(count)
            vcs.append(contentsOf: viewControllers)
        } else {
            vcs = viewControllers
        }
        setViewControllers(vcs, animated: animated)
    }

    func replaceViewControllers(with replacingViewControllers: [UIViewController], after referenceViewController: UIViewController, includingReference: Bool = false, animated: Bool = true) {
        if let index = viewControllers.lastIndex(of: referenceViewController) {
            replaceTopViewControllers(
                count: viewControllers.count - index - (includingReference ? 0 : 1),
                with: replacingViewControllers,
                animated: animated
            )
        }
    }
}
