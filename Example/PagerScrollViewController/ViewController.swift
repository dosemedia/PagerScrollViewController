//
//  ViewController.swift
//  PagerScrollViewController
//
//  Created by Michael Blatter on 05/27/2016.
//  Copyright (c) 2016 Michael Blatter. All rights reserved.
//

import UIKit
import PagerScrollViewController

class ViewController: UIViewController, PagerScrollViewControllerDelegate {
    var pagerScrollViewController: PagerScrollViewController!
    
    var pageCount = 10
    var pageToColor = [UIColor.blueColor(), UIColor.purpleColor(), UIColor.brownColor(), UIColor.cyanColor(), UIColor.orangeColor()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setup Pager
        pagerScrollViewController = PagerScrollViewController()
        pagerScrollViewController.parentController = self
        pagerScrollViewController.parentView = view
        pagerScrollViewController.delegate = self
        
        //Configuration
        pagerScrollViewController.orientation = PagerScrollViewControllerOrientation.Horizontal
        
        //Add pager to self
        addChildViewController(pagerScrollViewController)
        pagerScrollViewController.view.frame = view.frame
        view.addSubview(pagerScrollViewController.view)
        pagerScrollViewController.didMoveToParentViewController(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getPageCount() -> Int {
        return pageCount
    }
    
    func getController(page: Int) -> UIViewController {
        let viewController = UIViewController()
        viewController.view.backgroundColor = getRandomColor()
        
        return viewController
    }
    
    func getRandomColor() -> UIColor {
        let randomRed:CGFloat = CGFloat(drand48())
        let randomGreen:CGFloat = CGFloat(drand48())
        let randomBlue:CGFloat = CGFloat(drand48())
        
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
    
    //Events
    //All these delegate methods are optional
    func changedPage(page: Int, viewController: UIViewController, swiped: Bool) {
        print("page: \(page)")
        print("viewController: \(viewController)")
        print("swiped: \(swiped)")
    }
    
    func loadMoreItems(callback: () -> ()) {
        pageCount += 10
    }
}

