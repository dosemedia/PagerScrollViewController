# PagerScrollViewController

[![Version](https://img.shields.io/cocoapods/v/PagerScrollViewController.svg?style=flat)](http://cocoapods.org/pods/PagerScrollViewController)
[![License](https://img.shields.io/cocoapods/l/PagerScrollViewController.svg?style=flat)](http://cocoapods.org/pods/PagerScrollViewController)
[![Platform](https://img.shields.io/cocoapods/p/PagerScrollViewController.svg?style=flat)](http://cocoapods.org/pods/PagerScrollViewController)

PagerScrollViewController is a UIScrollView extension that allows for paging UIViewControllers efficently. Similar to Android's implementation of ViewPager and Fragments.

## Features

1. Very simple/lightweight library - (~400 lines of code)
2. Vertical and horizontal support, also supports orientation changes 
3. Infinite scroll ability
4. Creates UIViewController's around current page to create a seamless paging transition
5. Memory Management - didReceiveMemoryWarning will trigger removal of all controllers except the current one the user is on

## Example in Source

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

Swift 2.0

## Installation

PagerScrollViewController is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```
pod 'PagerScrollViewController'
```

## Creating PagerScrollViewController

Creating the PagerScrollViewController is straightforward and can be done in viewDidLoad.

```
//Setup Pager
pagerScrollViewController = PagerScrollViewController()
pagerScrollViewController.parentController = self
pagerScrollViewController.parentView = view
pagerScrollViewController.delegate = self

//Configure It
pagerScrollViewController.orientation = PagerScrollViewControllerOrientation.Horizontal //Default Horizontal
pagerScrollViewController.pagesLoadedAroundVisiblePage = 1 //Default 1
pagerScrollViewController.itemsBeforeEndLoadMore = 5 //Default 5

//Add Pager to view
addChildViewController(pagerScrollViewController)
pagerScrollViewController.view.frame = view.frame
view.addSubview(pagerScrollViewController.view)
pagerScrollViewController.didMoveToParentViewController(self)
```

## Implementing PagerScrollViewControllerDelegate

**Required Methods:**

These required methods are needed for PagerScrollViewController to operate. Will need the number of pages and how to get the UIViewController
when attempting to place one within the UIScrollView.

```
func getPageCount() -> Int {}

func getController(page: Int) -> UIViewController {}
```

**Optional Methods:**

These optional methods are events that occur within PagerScrollViewController you can use to implement your own code.
For loadMoreItems, will need to call callback closure before the method will be requested again to avoid repeats.

```
func changedPage(page: Int, viewController: UIViewController, swiped: Bool) { }

func loadMoreItems(callback: () -> ()) {}
```

## Contributors

[Michael Blatter](https://github.com/mikeblatter/)

[Brad Woodard](https://github.com/BCWoodard)

## License

PagerScrollViewController is available under the MIT license. See the LICENSE file for more info.
