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
    
    private var maxOffsetY: CGFloat {
        return self.scrollView.contentSize.height - self.scrollView.frame.size.height
    }
    
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
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackViewBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(stackViewBackgroundView)
        scrollView.addSubview(stackView)
        
        stackView.axis = .vertical
        
        stackViewBackgroundView.backgroundColor = UIColor.clear
        
        let views = ["scrollView" : scrollView,
                     "stackViewBackgroundView" : stackViewBackgroundView,
                     ] as [String : Any]
        
        var constraints = [NSLayoutConstraint]()
        
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|[scrollView]|", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollView]|", options: [], metrics: nil, views: views)
        
        pinStackView(withBorderWidth: borderWidth)
        
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|[stackViewBackgroundView]|", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[stackViewBackgroundView(==scrollView)]|", options: [], metrics: nil, views: views)
        
        NSLayoutConstraint.activate(constraints)
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        viewDidLayoutSubviewsClosure?()
    }
    
    var stackViewConstraints = [NSLayoutConstraint]()
    
    private func pinStackView(withBorderWidth borderWidth: CGFloat) {
        
        scrollView.removeConstraints(stackViewConstraints)
        stackViewConstraints.removeAll()
        
        stackViewConstraints += [stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: borderWidth)]
        stackViewConstraints += [stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -borderWidth)]
        
        stackViewConstraints += [stackView.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: borderWidth)]
        stackViewConstraints += [stackView.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -borderWidth)]
        
        stackViewConstraints += [stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -borderWidth * 2)]
        
        stackViewConstraints.forEach { $0.isActive = true }
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
            insertionIndex = children.count
            
        case .index(let index):
            insertionIndex =  min(Int(index), children.count)
            
        case .after(let afterViewController):
            if let afterViewIndex = arrangedViewOrContainerIndex(for: afterViewController.view) {
                insertionIndex = afterViewIndex + 1
            } else {
                insertionIndex = children.count
            }
            
        case .before(let beforeViewController):
            if let beforeViewIndex = arrangedViewOrContainerIndex(for: beforeViewController.view) {
                insertionIndex = beforeViewIndex
            } else {
                insertionIndex = children.count
            }
        }
            
        insert(viewController: viewController, edgeInsets: edgeInsets, at: insertionIndex ?? children.count)
    }
    
    open func insert(viewController: UIViewController, edgeInsets: UIEdgeInsets?, at index: Int) {

        addChild(viewController)
        viewController.didMove(toParent: self)
        
        if let edgeInsets = edgeInsets {
            
            let childView: UIView = viewController.view
            let containerView = UIView()
            containerView.translatesAutoresizingMaskIntoConstraints = false
            childView.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(childView)
            
            let constraints = [
                childView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: edgeInsets.top),
                childView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: edgeInsets.left),
                containerView.bottomAnchor.constraint(equalTo: childView.bottomAnchor, constant: edgeInsets.bottom),
                containerView.trailingAnchor.constraint(equalTo: childView.trailingAnchor, constant: edgeInsets.right),
                ]
            
            NSLayoutConstraint.activate(constraints)
            stackView.insertArrangedSubview(containerView, at: index)
            
        } else {
            stackView.insertArrangedSubview(viewController.view, at: index)
        }
    }
    
    open func remove(viewController: UIViewController) {
        guard let arrangedView = arrangedView(for: viewController) else { return }
        arrangedView.removeFromSuperview()
        if arrangedView != viewController.view {
            viewController.view.removeFromSuperview()
        }
        
        viewController.willMove(toParent: nil)
        viewController.removeFromParent()
    }
    
    open func show(viewController: UIViewController,
                   insertIfNeeded insertion: (position: Position, insets: UIEdgeInsets)? = nil,
                   _ action: (() -> Void)? = nil) {
        
        
        if let insertion = insertion, !isArrangedOrContained(view: viewController.view) || !children.contains(viewController) {
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
        if self.isArranged(view: viewController.view), self.maxOffsetY > 0  {
            self.scrollTo(view: viewController.view, {
                action?()
            })
        } else if let superview = viewController.view.superview, superview != stackView, self.isArranged(view: superview), self.maxOffsetY > 0 {
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
            let offsetY = (view.frame.origin.y >= self.maxOffsetY) ? self.maxOffsetY : view.frame.origin.y
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
