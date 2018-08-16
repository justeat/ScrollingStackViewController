//
//  ScrollingStackViewController.swift
//  Pods
//
//  Created by Maciej Trybilo on 24/01/2017.
//  Copyright © 2017 Just Eat Holding Ltd. All rights reserved.
//

import UIKit

public enum Position {
    case start
    case end
    case index(_: Int)
    case after(viewController: UIViewController)
    case before(viewController: UIViewController)
}

open class ScrollingStackViewController: UIViewController {
    
    public let scrollView: UIScrollView = UIScrollView()
    public let stackViewBackgroundView: UIView = UIView()
    public let stackView: UIStackView = UIStackView()
    
    public var spacingColor: UIColor = UIColor.clear {
        
        didSet {
            stackViewBackgroundView.backgroundColor = spacingColor
        }
    }
    
    public var borderColor: UIColor = UIColor.gray {
        
        didSet {
            stackViewBackgroundView.layer.borderColor = borderColor.cgColor
        }
    }
    
    public var borderWidth: CGFloat = 0.5 {
        
        didSet {
            stackViewBackgroundView.layer.borderWidth = borderWidth
            
            pinStackView(withBorderWidth: self.borderWidth)
            scrollView.layoutIfNeeded()
        }
    }
    
    static public func defaultAnimate(_ animations: @escaping () -> (), completion: ((Bool) -> Void)?) {
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 0,
                       options: [],
                       animations: animations,
                       completion: completion)
    }
    
    public var animate = ScrollingStackViewController.defaultAnimate
    
    private var viewDidLayoutSubviewsClosure: (() -> Void)?

    static public func defaultScrollAnimate(_ animations: @escaping () -> (), completion: ((Bool) -> Void)?) {
        
        UIView.animate(withDuration: 0.75,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.25,
                       options: [],
                       animations: animations,
                       completion: completion)
    }
    
    public var scrollAnimate = ScrollingStackViewController.defaultScrollAnimate
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        prepareViews()
        addInitialConstraints()
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        viewDidLayoutSubviewsClosure?()
    }
    
    var stackViewConstraints = [NSLayoutConstraint]()
    
    private func prepareViews() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackViewBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(stackViewBackgroundView)
        scrollView.addSubview(stackView)
        
        stackView.axis = .vertical
        stackViewBackgroundView.backgroundColor = .clear
    }
    
    private func addInitialConstraints() {
        let views = ["scrollView" : scrollView,
                     "stackViewBackgroundView" : stackViewBackgroundView,
                     ] as [String : Any]
        
        var constraints = [NSLayoutConstraint]()
        
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|[scrollView]|", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollView]|", options: [], metrics: nil, views: views)
        
        pinStackView(withBorderWidth: borderWidth)
        
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|[stackViewBackgroundView]|", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[stackViewBackgroundView(==scrollView)]|", options: [], metrics: nil, views: views)
        
        constraints.activate()
    }
    
    private func pinStackView(withBorderWidth borderWidth: CGFloat) {
        
        scrollView.removeConstraints(stackViewConstraints)
        stackViewConstraints.removeAll()
        
        stackViewConstraints += [stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: borderWidth)]
        stackViewConstraints += [stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -borderWidth)]
        
        stackViewConstraints += [stackView.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: borderWidth)]
        stackViewConstraints += [stackView.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -borderWidth)]
        
        stackViewConstraints += [stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -borderWidth * 2)]
        
        stackViewConstraints.activate()
    }
    
    open func add(viewController: UIViewController) {
        insert(viewController: viewController)
    }
    
    open func add(viewController: UIViewController, edgeInsets: UIEdgeInsets? = nil) {
        insert(viewController: viewController, edgeInsets: edgeInsets)
    }
    
    open func insert(viewController: UIViewController, at index: Int) {
        insert(viewController: viewController, at: .index(index))
    }
    
    open func insert(viewController: UIViewController, edgeInsets: UIEdgeInsets? = nil, at position: Position = .end) {
        var insertionIndex: Int?
        
        switch position {
        case .start:
            insertionIndex = 0
            
        case .end:
            insertionIndex = childViewControllers.count
            
        case .index(let index):
            insertionIndex =  min(Int(index), childViewControllers.count)
            
        case .after(let afterViewController):
            if let afterViewIndex = arrangedViewOrContainerIndex(for: afterViewController.view) {
                insertionIndex = afterViewIndex + 1
            } else {
                insertionIndex = childViewControllers.count
            }
            
        case .before(let beforeViewController):
            if let beforeViewIndex = arrangedViewOrContainerIndex(for: beforeViewController.view) {
                insertionIndex = beforeViewIndex
            } else {
                insertionIndex = childViewControllers.count
            }
        }
            
        insert(viewController: viewController, edgeInsets: edgeInsets, at: insertionIndex ?? childViewControllers.count)
    }
    
    open func insert(viewController: UIViewController, edgeInsets: UIEdgeInsets?, at index: Int) {
        add(viewController, addingView: false)
        stackView.insertArrangedSubview(viewController.view(withEdgeInsets: edgeInsets), at: index)
    }
    
    open func remove(viewController: UIViewController) {
        guard let arrangedView = arrangedView(for: viewController) else { return }
        stackView.removeArrangedSubview(arrangedView)
        
        viewController.removeAsChild(removingView: false)
    }
    
    open func show(viewController: UIViewController,
                   insertIfNeeded insertion: (position: Position, insets: UIEdgeInsets)? = nil,
                   _ action: (() -> Void)? = nil) {
        
        
        if let insertion = insertion, !isArrangedOrContained(view: viewController.view) || !childViewControllers.contains(viewController) {
            insert(viewController: viewController, edgeInsets: insertion.insets, at: insertion.position)
        }
        
        animate({
            if let view = self.arrangedView(for: viewController) {
                view.alpha = 1
                view.isHidden = false
            }
        }, { isFinished in
            if isFinished {
                action?()
            }
        })
    }
    
    open func hide(viewController: UIViewController, _ action: (() -> Void)? = nil) {
        
        animate({
            if let view = self.arrangedView(for: viewController) {
                view.alpha = 0
                view.isHidden = true
            }
        }, { isFinished in
            if isFinished {
                action?()
            }
        })
    }
    
    open func scrollTo(viewController: UIViewController, _ action:(() -> Void)? = nil) {
        
        //check if viewDidLayoutSubviews finished to resize scrollview
        if self.isArranged(view: viewController.view), self.scrollView.maxOffsetY > 0  {
            self.scrollTo(view: viewController.view, {
                action?()
            })
        } else if let superview = viewController.view.superview, superview != stackView, self.isArranged(view: superview), self.scrollView.maxOffsetY > 0 {
            self.scrollTo(view: superview, {
                action?()
            })
        } else {
            viewDidLayoutSubviewsClosure =  { [weak self] in
                self?.scrollTo(viewController: viewController, {
                    self?.viewDidLayoutSubviewsClosure = nil
                    action?()
                })
            }
        }
    }
    
    private func scrollTo(view: UIView, _ finished: @escaping (() -> Void)) {
        
        scrollAnimate({
            let offsetY = (view.frame.origin.y >= self.scrollView.maxOffsetY) ? self.scrollView.maxOffsetY : view.frame.origin.y
            self.scrollView.contentOffset = CGPoint(x: view.frame.origin.x, y: offsetY)
        }, { isFinished in
            if isFinished {
                finished()
            }
        })
    }
    
    public func isArranged(view: UIView) -> Bool {
        return arrangedViewIndex(for: view) != nil
    }
    
    public func isArrangedOrContained(view: UIView) -> Bool {
        return arrangedViewOrContainerIndex(for: view) != nil
    }
    
    public func arrangedView(for viewController: UIViewController) -> UIView? {
        guard let index = arrangedViewOrContainerIndex(for: viewController.view) else { return nil }
        return stackView.arrangedSubviews[index]
    }
    
    public func arrangedViewOrContainerIndex(for view: UIView) -> Int? {
        return arrangedViewIndex(for: view) ?? arrangedViewContainerIndex(for: view)
    }
    
    public func arrangedViewIndex(for view: UIView) -> Int? {
        return stackView.arrangedSubviews.index(of: view)
    }
    
    public func arrangedViewContainerIndex(for view: UIView) -> Int? {
        if let containerView = stackView.arrangedSubviews.first(where: { $0.subviews.contains(view) }) {
            return stackView.arrangedSubviews.index(of: containerView)
        } else {
            return nil
        }
    }
}
