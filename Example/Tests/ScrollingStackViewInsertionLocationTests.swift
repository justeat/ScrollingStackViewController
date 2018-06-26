//
//  ScrollingStackViewInsertionLocationTests.swift
//  ScrollingStackViewController_Tests
//
//  Created by Ed Rutter on 21/06/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
@testable import ScrollingStackViewController

class ScrollingStackViewInsertionTests: XCTestCase {
    
    var vc: ScrollingStackViewController!
    
    var childA: UIViewController!
    var childB: UIViewController!
    var insertingChild: UIViewController!

    
    override func setUp() {
        super.setUp()
        
        let window = UIApplication.shared.keyWindow!
        vc = Factory.createScrollingStackViewController(window: window)
        
        childA = Factory.createStubViewController(height: 100)
        childB = Factory.createStubViewController(height: 100)
        insertingChild = Factory.createStubViewController(height: 100)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testShow_InsertingIfNeeded_Insets() {
        let insets = UIEdgeInsets(top: 10, left: 20, bottom: 30, right: 40)
        vc.show(viewController: insertingChild, insertIfNeeded: (location: .end, insets: insets))
        
        let paddingView = vc.stackView.arrangedSubviews.first!
        let topConstraint = paddingView.constraints.filter { $0.firstAttribute == .top }.first
        let leftConstraint = paddingView.constraints.filter { $0.firstAttribute == .leading }.first
        let bottomConstraint = paddingView.constraints.filter { $0.firstAttribute == .bottom }.first
        let rightConstraint = paddingView.constraints.filter { $0.firstAttribute == .trailing }.first
        
        XCTAssert(paddingView.subviews.count == 1, "View should be added in a container view")
        
        XCTAssert(topConstraint?.constant == 10, "Constraint constant should be 10")
        XCTAssert(leftConstraint?.constant == 20, "Constraint constant should be 20")
        XCTAssert(bottomConstraint?.constant == 30, "Constraint constant should be 30")
        XCTAssert(rightConstraint?.constant == 40, "Constraint constant should be 40")
        
        vc.show(viewController: insertingChild, insertIfNeeded: (location: .end, insets: .zero))
        XCTAssert(topConstraint?.constant == 10, "Constraint constant should still be 10")
        XCTAssert(leftConstraint?.constant == 20, "Constraint constant should still 20")
        XCTAssert(bottomConstraint?.constant == 30, "Constraint constant should still 30")
        XCTAssert(rightConstraint?.constant == 40, "Constraint constant should still 40")
    }

    func testShow_insertingIfNeeded_atStart() {
        vc.insert(viewController: childA, at: 0)
        vc.insert(viewController: childB, at: 1)
        
        vc.show(viewController: insertingChild, insertIfNeeded: (location: .start, insets: .zero))
        XCTAssert(vc.arrangedViewOrContainerIndex(for: insertingChild.view) == 0, "Ordering should be InsertingChild, Child A, Child B")
    }
    
    func testShow_insertingIfNeeded_atEnd() {
        vc.insert(viewController: childA, at: 0)
        vc.insert(viewController: childB, at: 1)
        
        vc.show(viewController: insertingChild, insertIfNeeded: (location: .end, insets: .zero))
        XCTAssert(vc.arrangedViewOrContainerIndex(for: insertingChild.view) == 2, "Ordering should be Child A, Child B, InsertingChild")
    }
    
    func testShow_insertingIfNeeded_atIndex() {
        vc.insert(viewController: childA, at: 0)
        vc.insert(viewController: childB, at: 1)
        
        vc.show(viewController: insertingChild, insertIfNeeded: (location: .index(0), insets: .zero))
        XCTAssert(vc.arrangedViewOrContainerIndex(for: insertingChild.view) == 0, "Ordering should be InsertingChild, Child A, Child B")
        
        vc.remove(viewController: insertingChild)
        vc.show(viewController: insertingChild, insertIfNeeded: (location: .index(2), insets: .zero))
        XCTAssert(vc.arrangedViewOrContainerIndex(for: insertingChild.view) == 2, "Ordering should be Child A, Child B, InsertingChild")
        
        vc.remove(viewController: insertingChild)
        vc.show(viewController: insertingChild, insertIfNeeded: (location: .index(5), insets: .zero))
        XCTAssert(vc.arrangedViewOrContainerIndex(for: insertingChild.view) == 2, "Ordering should be Child A, Child B, InsertingChild")
    }
    
    func testShow_insertingIfNeeded_afterViewViewController() {
        vc.insert(viewController: childA, at: 0)
        vc.insert(viewController: childB, at: 1)
        
        vc.show(viewController: insertingChild, insertIfNeeded: (location: .after(viewController: childA), insets: .zero))
        XCTAssert(vc.arrangedViewOrContainerIndex(for: insertingChild.view) == 1, "Ordering should be Child A, InsertingChild, Child B")
    }
    
    func testShow_insertingIfNeeded_beforeViewViewController() {
        vc.insert(viewController: childA, at: 0)
        vc.insert(viewController: childB, at: 1)
        
        vc.show(viewController: insertingChild, insertIfNeeded: (location: .before(viewController: childB), insets: .zero))
        XCTAssert(vc.arrangedViewOrContainerIndex(for: insertingChild.view) == 1, "Ordering should be Child A, InsertingChild, Child B")
    }
}
