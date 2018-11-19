import UIKit
import XCTest
import ScrollingStackViewController

class ScrollingStackViewTests: XCTestCase {
    
    let window = UIApplication.shared.keyWindow!

    func testSimpleScrolling() {
        
        // Sets up a scrolling stack view with two view controller with views both
        // equal to the height of the window, then scrolls to the second view

        let vc = Factory.createScrollingStackViewController(window: window)

        let height = vc.view.frame.height
        
        let child1 = Factory.createStubViewController(height: height)
        let child2 = Factory.createStubViewController(height: height)

        vc.add(viewController: child1)
        vc.add(viewController: child2)
        
        vc.view.setNeedsLayout()
        vc.view.layoutIfNeeded()
        
        let expectation = self.expectation(description: "Expect scrolling to finish")
        
        vc.scrollTo(viewController: child2, {
            XCTAssertEqual(vc.scrollView.contentOffset.y, vc.view.frame.height - vc.topLayoutGuide.length)
            expectation.fulfill()
        })

        self.waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testShowHideViewControllers() {
        let vc = Factory.createScrollingStackViewController(window: window)
        
        let height = vc.view.frame.height
        
        let child1 = Factory.createStubViewController(height: height)
        let child2 = Factory.createStubViewController(height: height)
        XCTAssert(vc.stackView.arrangedSubviews.count == 0)
        
        vc.add(viewController: child1)
        XCTAssert(vc.stackView.arrangedSubviews.count == 1)
        
        vc.show(viewController: child2)
        XCTAssert(vc.stackView.arrangedSubviews.count == 1)
        
        vc.show(viewController: child2, insertIfNeeded: (position: .end, insets: .zero))
        XCTAssert(vc.stackView.arrangedSubviews.count == 2)
    
        vc.hide(viewController: child1)
        XCTAssert(vc.stackView.arrangedSubviews.count == 2)
        XCTAssert(vc.arrangedView(for: child1)!.isHidden)
        
        vc.remove(viewController: child2)
        XCTAssert(vc.stackView.arrangedSubviews.count == 1)
    }
    
    func testRemoveViewControllers() {
        let vc = Factory.createScrollingStackViewController(window: window)
        let height = vc.view.frame.height
        
        let arrangedVC = Factory.createStubViewController(height: height)
        let containedVC = Factory.createStubViewController(height: height)
        let edgeInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        vc.add(viewController: arrangedVC)
        vc.show(viewController: arrangedVC)
        vc.show(viewController: containedVC, insertIfNeeded: (position: .end, insets: edgeInset))
        XCTAssert(vc.stackView.arrangedSubviews.count == 2)
        
        vc.remove(viewController: arrangedVC)
        XCTAssert(vc.stackView.arrangedSubviews.count == 1)
        XCTAssert(arrangedVC.view.superview == nil)
        
        vc.remove(viewController: containedVC)
        XCTAssert(vc.stackView.arrangedSubviews.count == 0)
        XCTAssert(containedVC.view.superview == nil)
    }

    func testComplexScrolling() {
        
        // Setup a scrolling stack view with lots of equally fixed-height children,
        // then scroll to one of the children and verify the offset is a product of
        // the fixed height of the children
        
        let height = CGFloat(200);
        
        let scrollIndex = 10;
        
        let result = Factory.createScrollingStackViewController(withStubViewControllerCount: 20, ofHeight: height, in: window)
        
        let expectation = self.expectation(description: "Expect scrolling to finish")
        
        result.viewController.scrollTo(viewController: result.children[scrollIndex], {
            XCTAssertEqual(result.viewController.scrollView.contentOffset.y, (height * CGFloat(scrollIndex)) - result.viewController.topLayoutGuide.length)
            expectation.fulfill()
        })
        
        self.waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testChildViewControllerInsets() {
        
        // Verify that stack view correctly applies insets to its children
        
        let height = CGFloat(200);
        let insets = UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100)

        let result = Factory.createScrollingStackViewController(withStubViewControllerCount: 20, ofHeight: height, withInsets: insets, in: window)
        
        let stackView = result.viewController.stackView
        
        stackView.arrangedSubviews.forEach { view in
            let innerView = view.subviews.first!
            XCTAssertEqual(view.frame.width, stackView.frame.width)
            XCTAssertEqual(view.frame.height, innerView.frame.height + insets.top + insets.bottom)
            XCTAssertEqual(view.frame.width, innerView.frame.width + insets.left + insets.right)
        }
        
    }
    
    func testScrollingWithInsets() {
        
        // Verify that the scroll offset correctly accounts for insets of
        // the children of the stack view
        
        let height = CGFloat(200);
        let insets = UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100)

        let scrollIndex = 10;
        
        let result = Factory.createScrollingStackViewController(withStubViewControllerCount: 20, ofHeight: height, withInsets: insets, in: window)
        
        let expectation = self.expectation(description: "Expect scrolling to finish")
        
        result.viewController.scrollTo(viewController: result.children[scrollIndex], {
            XCTAssertEqual(result.viewController.scrollView.contentOffset.y, ((height + insets.top + insets.bottom) * CGFloat(scrollIndex)) - result.viewController.topLayoutGuide.length)
            expectation.fulfill()
        })
        
        self.waitForExpectations(timeout: 5.0, handler: nil)
    }
    
}
