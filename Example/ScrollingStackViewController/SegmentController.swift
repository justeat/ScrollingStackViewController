//
//  SegmentController.swift
//  ScrollingStackViewController
//
//  Created by Maciej Trybilo on 03/02/2017.
//  Copyright © 2017 Just Eat Holding Ltd. All rights reserved.
//

import UIKit
import ScrollingStackViewController

class SegmentController: UIViewController {
    
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var hideMeButton: UIButton!
    
    var count: Int? {
        didSet {
            configure()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
    
    @IBAction func hideShowButtonTapped(_ sender: Any) {
        
        let shouldHide = !countLabel.isHidden
        
        ScrollingStackViewController.defaultAnimate({
            
            self.countLabel.isHidden = shouldHide
            self.hideMeButton.setTitle(shouldHide ? "Show label" : "Hide label", for: .normal)
            
        }, completion: nil)
    }
    
    private func configure() {
        
        guard isViewLoaded else { return }
        
        if let count = count {
            countLabel.text = "View Controller \(count)"
        } else {
            countLabel.text = nil
        }
    }
}
