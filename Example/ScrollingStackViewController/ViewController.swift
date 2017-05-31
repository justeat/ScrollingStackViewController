//
//  ViewController.swift
//  ScrollingStackViewController
//
//  Created by Maciej Trybilo on 01/24/2017.
//  Copyright © 2017 Just Eat Holding Ltd. All rights reserved.
//

import UIKit
import ScrollingStackViewController

class ViewController: ScrollingStackViewController {

    @IBOutlet weak var hideShowButton: UIBarButtonItem!
    
    var segments = [SegmentController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        for x in 1...10 {
            
            let viewController = storyboard.instantiateViewController(withIdentifier: "SegmentController") as! SegmentController
            viewController.count = x
            segments += [viewController]
            
            add(viewController: viewController)
        }
        
        // separators
        spacingColor = UIColor.lightGray
        stackView.spacing = 0.5
        
        borderWidth = 0        
    }
    
    var isHiding = false
    
    @IBAction func hideShowTapped(_ sender: Any) {
        
        isHiding = !isHiding
        
        if isHiding {
            
            hideShowButton.title = "Show 5"
            hide(viewController: self.segments[4])
        } else {
            
            hideShowButton.title = "Hide 5"
            show(viewController: self.segments[4])
        }
    }

    @IBAction func scrollTo8Tapped(_ sender: Any) {
        
        scrollTo(viewController: segments[7])
    }
}

