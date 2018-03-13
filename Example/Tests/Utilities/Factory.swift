//
//  Factory.swift
//  ScrollingStackViewController_Example
//
//  Created by Jack Newcombe on 13/03/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import ScrollingStackViewController

typealias FactoryResult = (viewController: ScrollingStackViewController, children: [UIViewController])

class Factory {
    
    static func createScrollingStackViewController(window: UIWindow) -> ScrollingStackViewController {
        let scrollingStackViewController = ScrollingStackViewController()
        let navController = UINavigationController(rootViewController: scrollingStackViewController)
        window.rootViewController = navController
        _ = navController.view
        window.makeKeyAndVisible()
        return scrollingStackViewController
    }
    
    static func createStubViewController(height: CGFloat) -> UIViewController {
        let vc = UIViewController()
        let constraints = [
            vc.view.heightAnchor.constraint(equalToConstant: height)
        ]
        
        NSLayoutConstraint.activate(constraints)
        return vc
    }
    
    static func createScrollingStackViewController(withStubViewControllerCount count: Int, ofHeight height: CGFloat, in window: UIWindow) -> FactoryResult {
        let scrollingStackViewController = createScrollingStackViewController(window: window)
        let array: [UIViewController] = (0..<count).map { _ in createStubViewController(height: height) }
        array.forEach { scrollingStackViewController.add(viewController: $0) }
        scrollingStackViewController.view.setNeedsLayout()
        scrollingStackViewController.view.layoutIfNeeded()
        return (viewController: scrollingStackViewController, children: array)
    }
    
    static func createScrollingStackViewController(withStubViewControllerCount count: Int, ofHeight height: CGFloat, withInsets insets: UIEdgeInsets, in window: UIWindow) -> FactoryResult {
        let scrollingStackViewController = createScrollingStackViewController(window: window)
        let array: [UIViewController] = (0..<count).map { _ in createStubViewController(height: height) }
        array.forEach { scrollingStackViewController.add(viewController: $0, edgeInsets: insets) }
        scrollingStackViewController.view.setNeedsLayout()
        scrollingStackViewController.view.layoutIfNeeded()
        return (viewController: scrollingStackViewController, children: array)
    }
    
}
