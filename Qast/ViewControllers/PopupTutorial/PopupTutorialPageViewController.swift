//
//  NewUserPageViewController.swift
//  Qast
//
//  Created by Andrew O'Brien on 7/6/19.
//  Copyright © 2019 Qast. All rights reserved.
//

import UIKit

import UIKit

class PopupTutorialPageViewController: UIPageViewController {
    
    var orderedViewControllers = [UIViewController]()
    
    var currentIndex:Int {
        get {
            return orderedViewControllers.index(of: self.viewControllers!.first!)!
        }
        
        set {
            guard newValue >= 0,
                newValue < orderedViewControllers.count else {
                    return
            }
            
            let vc = orderedViewControllers[newValue]
            let direction: UIPageViewController.NavigationDirection = newValue > currentIndex ? .forward : .reverse
            self.setViewControllers([vc], direction: direction, animated: true, completion: nil)
        }
    }
    
    init(transitionStyle style: UIPageViewController.TransitionStyle, navigationOrientation: UIPageViewController.NavigationOrientation, options: [UIPageViewController.OptionsKey: AnyObject]!) {
        super.init(transitionStyle: style, navigationOrientation: navigationOrientation, options: options)
    }
    
    convenience init(viewControllerFlow: [UIViewController]) {
        self.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        self.orderedViewControllers = viewControllerFlow
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
        
        setupPageControl()
    }
    
    private func setupPageControl() {
        let appearance = UIPageControl.appearance()
        appearance.backgroundColor = UIColor.clear
        appearance.pageIndicatorTintColor = UIColor.white
        appearance.currentPageIndicatorTintColor = UIColor.init(hexString: "#FAD747", alpha: 1.0)
    }
    
}

extension PopupTutorialPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let previousIndex = currentIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let nextIndex = currentIndex + 1
        
        guard orderedViewControllers.count != nextIndex else {
            return nil
        }
        
        guard orderedViewControllers.count > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return currentIndex
    }
}

extension PopupTutorialPageViewController: UIPageViewControllerDelegate {
    
}

