//
//  PagerScrollViewController.swift
//  Dose
//
//  Created by Michael Blatter on 4/1/16.
//  Copyright © 2016 Dose. All rights reserved.
//

import UIKit

public enum PagerScrollViewControllerOrientation {
    case Horizontal, Vertical
}

@objc public protocol PagerScrollViewControllerDelegate: class {
    func getPageCount() -> Int //Supply count of pages
    func getController(page: Int) -> UIViewController //Supply UIController for given page
    
    //Events
    optional func changedPage(page: Int, viewController: UIViewController, swiped: Bool)
    optional func loadMoreItems(callback: () -> ()) //Supply loadMoreItems function with callback
}

protocol PagerUIScrollViewDelegate {
    func didSetContentOffset()
}

class PagerUIScrollView: UIScrollView {
    var pagerDelegate: PagerUIScrollViewDelegate?
    
    override func setContentOffset(contentOffset: CGPoint, animated: Bool) {
        super.setContentOffset(contentOffset, animated: animated)
        pagerDelegate?.didSetContentOffset()
    }
}

public class PagerScrollViewController: UIViewController, UIScrollViewDelegate, PagerUIScrollViewDelegate {
    public var parentController: UIViewController!
    public var parentView: UIView!
    
    public var delegate: PagerScrollViewControllerDelegate?
    
    //Configuration
    public var orientation = PagerScrollViewControllerOrientation.Horizontal
    public var pagesLoadedAroundVisiblePage = 1
    public var itemsBeforeEndLoadMore = 5
    
    //Private
    var viewControllers: [UIViewController?] = []
    
    var requestedPage = 0
    var currentPage = 0
    var previousPage = 0
    
    var scrollView: PagerUIScrollView!
    var loadMoreItems = false
    var currentlyLoadingPages = false
    
    public func setPosition(page: Int) {
        requestedPage = page
        
        switch(self.orientation) {
        case .Horizontal:
            scrollView.setContentOffset(CGPoint(x: scrollView.frame.size.width * CGFloat(page), y: 0.0), animated: false)
        case .Vertical:
            scrollView.setContentOffset(CGPoint(x: 0.0, y: scrollView.frame.size.height * CGFloat(page)), animated: false)
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        addScrollView()
        
        update()
        setPosition(requestedPage)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PagerScrollViewController.orientationChanged), name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        update()
        setPosition(requestedPage)
    }
    
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        update()
        setPosition(requestedPage)
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        //Remove all other pages, except current
        if let pageCount = delegate?.getPageCount() {
            if pageCount > 0 {
                for index in 0 ..< pageCount {
                    if index == currentPage {
                        continue
                    }
                    
                    purgePage(index)
                }
            }
        }
    }
    
    func orientationChanged() {
        var newFrame = parentView.frame
        newFrame.origin.x = 0
        newFrame.origin.y = 0
        
        view.frame = newFrame
        scrollView.frame = newFrame
        
        update()
        setPosition(requestedPage)
    }
    
    //Scroll View Delegates
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        requestedPage = currentPosition()
        
        update()
        checkPageChange(true)
    }
    
    func didSetContentOffset() {
        update()
        checkPageChange(false)
    }
    
    //Internal Functions
    private func update() {
        setSize()
        resetViewControllers()
        loadRequestedPages()
    }
    
    private func setSize() {
        if delegate == nil {
            return
        }
        
        let width = view.frame.size.width
        let height = view.frame.size.height
        
        switch(self.orientation) {
        case .Horizontal:
            scrollView.contentSize = CGSizeMake(width * CGFloat(delegate!.getPageCount()), height)
        case .Vertical:
            scrollView.contentSize = CGSizeMake(width, height * CGFloat(delegate!.getPageCount()))
        }
    }
    
    private func checkPageChange(swiped: Bool) {
        let currentPosition = (swiped) ? self.currentPosition() : requestedPage
        
        if currentPage != currentPosition {
            if let viewController = viewControllers[requestedPage] {
                delegate?.changedPage?(requestedPage, viewController: viewController, swiped: swiped)
            }
        }
        
        //Check to see if we need to load more!
        if viewControllers.count - itemsBeforeEndLoadMore < currentPosition {
            if loadMoreItems == false {
                loadMoreItems = true
                delegate?.loadMoreItems?() {
                    self.loadMoreItems = false
                    self.setSize()
                }
            }
        }
        
        previousPage = currentPage
        currentPage = requestedPage
    }
    
    private func resetViewControllers() {
        if delegate == nil {
            return
        }
        
        var difference = 0
        if let pageCount = delegate?.getPageCount() {
            difference = pageCount - viewControllers.count
        }
        
        if difference > 0 {
            for _ in 0...(difference-1) {
                viewControllers.append(nil)
            }
        }
        else if difference < 0
        {
            for _ in 0...difference-1 {
                viewControllers.removeAtIndex(viewControllers.count - 1)
            }
        }
    }
    
    private func addScrollView() {
        scrollView = PagerUIScrollView()
        scrollView.frame = view.frame
        scrollView.delegate = self
        scrollView.pagerDelegate = self
        scrollView.pagingEnabled = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
    }
    
    private func currentPosition() -> Int {
        let scrollOffset = (orientation == .Horizontal) ? scrollView.contentOffset.x : scrollView.contentOffset.y
        
        if scrollOffset == 0 {
            return 0
        }
        
        let scrollSize = (orientation == .Horizontal) ? view.frame.size.width : view.frame.size.height
        return Int(floor((scrollOffset * 2.0 + scrollSize) / (scrollSize * 2.0)))
    }
    
    private func loadRequestedPages() {
        if delegate == nil {
            return
        }
        
        //Maybe disable scrolling till everything is caught up
        if currentlyLoadingPages == true {
            return
        }
        currentlyLoadingPages = true
        
        let page = requestedPage
        
        let firstPage = page - pagesLoadedAroundVisiblePage
        let lastPage = page + pagesLoadedAroundVisiblePage
        
        //Purge before
        if firstPage > 0 {
            for index in 0 ..< firstPage {
                purgePage(index)
            }
        }
        
        //Purge After
        if(delegate!.getPageCount() > lastPage + 1) {
            for index in lastPage + 1 ..< delegate!.getPageCount() {
                purgePage(index)
            }
        }
        
        //Load first page, then the others
        var loadPageArray = [page]
        for index in firstPage ..< lastPage+1 {
            if index != page {
                loadPageArray.append(index) //Add the others in order
            }
        }
        
        //print("starting loading: \(loadPageArray)")
        //Send array to the loadPage func, it's a recursive threaded function
        loadPage(loadPageArray, suppliedPageCount: nil, completionCallback: {
            self.currentlyLoadingPages = false
        })
    }
    
    private func purgePage(page: Int) {
        if delegate == nil {
            return
        }
        
        if page < 0 || page >= delegate!.getPageCount() {
            return
        }
        
        if let viewController = viewControllers[page] {
            viewController.view.removeFromSuperview()
            viewController.removeFromParentViewController()
            viewControllers[page] = nil
        }
    }
    
    private func loadPage(loadPageArray: [Int], suppliedPageCount: Int?, completionCallback: () -> ()) {
        if delegate == nil || loadPageArray.count == 0 {
            //print("ending loading")
            completionCallback()
            
            return
        }
        
        let pageCount = (suppliedPageCount != nil) ? suppliedPageCount : delegate?.getPageCount()
        if pageCount == nil {
            //print("ending loading")
            completionCallback()
            
            return
        }
        
        let page = loadPageArray[0]
        if page < 0 || page >= pageCount! {
            var newLoadArray = loadPageArray
            newLoadArray.removeAtIndex(0)
            loadPage(newLoadArray, suppliedPageCount: pageCount, completionCallback: completionCallback)
            
            return
        }
        
        if let viewController = viewControllers[page] {
            viewController.view.frame = getPageFrame(page)
            
            var newLoadArray = loadPageArray
            newLoadArray.removeAtIndex(0)
            loadPage(newLoadArray, suppliedPageCount: pageCount, completionCallback: completionCallback)
        }
        else
        {
            let newViewController = delegate!.getController(page)
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                //Task
                self.addChildViewController(newViewController)
                
                //Update View
                dispatch_async(dispatch_get_main_queue(), {
                    newViewController.view.frame = self.getPageFrame(page)
                    
                    //Add as sub
                    self.scrollView.addSubview(newViewController.view)
                    newViewController.didMoveToParentViewController(self)
                    self.viewControllers[page] = newViewController
                    
                    var newLoadArray = loadPageArray
                    newLoadArray.removeAtIndex(0)
                    self.loadPage(newLoadArray, suppliedPageCount: pageCount, completionCallback: completionCallback)
                })
            })
        }
    }
    
    private func getPageFrame(page: Int) -> CGRect {
        var frame = parentView.frame
        
        switch(orientation) {
        case .Horizontal:
            frame.origin.x = parentView.frame.size.width * CGFloat(page)
            frame.origin.y = 0.0
        case .Vertical:
            frame.origin.x = 0.0
            frame.origin.y = parentView.frame.size.height * CGFloat(page)
        }
        
        return frame
    }
}