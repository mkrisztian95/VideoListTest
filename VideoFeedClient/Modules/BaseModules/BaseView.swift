//
//  BaseView.swift
//  VideoFeedClient
//
//  Created by Chris on 16.11.2022.
//

import UIKit

public protocol BaseView: AnyObject {
    func open(module: BaseModule)
    func replace(with module: BaseModule, animated: Bool)
    func closeModule(animated: Bool)
}

public extension BaseView where Self: UIViewController {
    func open(module: BaseModule) {
        guard let navigation = navigationController else {
            return
        }
        // Pushing a navigation controller is not supported
        if (module.viewController() as? UINavigationController) == nil {
            navigation.pushViewController(module.viewController(), animated: true)
        } else if let navModule = (module.viewController() as? UINavigationController) {
            navigation.pushViewController(navModule.viewControllers[0], animated: true)
        }
    }

    func replace(with module: BaseModule, animated: Bool) {
        guard let navigation = navigationController,
              (module.viewController() as? UINavigationController) == nil
        else {
            return
        }
        navigation.replaceTopViewController(with: module.viewController(), animated: animated)
    }

    func closeModule(animated: Bool = true) {
        if let navigationController = navigationController,
            presentingViewController != nil, navigationController.viewControllers.count > 1 {
            navigationController.popViewController(animated: animated)
        } else if presentingViewController != nil {
            dismiss(animated: animated, completion: nil)
        } else if let navigationController = navigationController {
            navigationController.popViewController(animated: animated)
        }
    }
}
