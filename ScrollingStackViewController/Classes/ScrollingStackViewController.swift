//
//  ScrollingStackViewController.swift
//  Pods
//
//  Created by Maciej Trybilo on 24/01/2017.
//  Copyright © 2017 Just Eat Holding Ltd. All rights reserved.
//

import UIKit

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
                     "stackView" : stackView,
                     "topGuide" : topLayoutGuide,
                     "bottomGuide" : bottomLayoutGuide] as [String : Any]
        
        var constraints = [NSLayoutConstraint]()
        
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:[topGuide][scrollView][bottomGuide]", options: [], metrics: nil, views: views)
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
        
        insert(viewController: viewController, at: stackView.arrangedSubviews.count)
    }
    
    open func insert(viewController: UIViewController, at index: Int) {
        
        addChildViewController(viewController)
        stackView.insertArrangedSubview(viewController.view, at: index)
        viewController.didMove(toParentViewController: self)
    }
    
    open func remove(viewController: UIViewController) {
        
        guard childViewControllers.contains(where: { $0 === viewController }) else { return }
        viewController.willMove(toParentViewController: nil)
        stackView.removeArrangedSubview(viewController.view)
        viewController.removeFromParentViewController()
    }
    
    open func show(viewController: UIViewController, _ action: (() -> Void)? = nil) {
        
        animate({
            viewController.view.alpha = 1
            viewController.view.isHidden = false
        }, { isFinished in
            if isFinished {
                action?()
            }
        })
    }
    
    open func hide(viewController: UIViewController, _ action: (() -> Void)? = nil) {
        
        animate({
            viewController.view.alpha = 0
            viewController.view.isHidden = true
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
        } else {
            viewDidLayoutSubviewsClosure =  { [weak self] in
                self?.scrollTo(viewController: viewController, {
                    self?.viewDidLayoutSubviewsClosure = nil
                    action?()
                })
            }
        }
    }
    
    private func isArranged(view: UIView) -> Bool {
        return self.stackView.arrangedSubviews.filter({ $0 == view}).count > 0
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
    
}
