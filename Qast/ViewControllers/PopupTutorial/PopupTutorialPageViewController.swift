//
//  NewUserPageViewController.swift
//  Qast
//
//  Created by Andrew O'Brien on 7/6/19.
//  Copyright © 2019 Qast. All rights reserved.
//

import UIKit

class PopupTutorialPageViewController: UIPageViewController {
    
    init(transitionStyle style: UIPageViewController.TransitionStyle, navigationOrientation: UIPageViewController.NavigationOrientation, options: [UIPageViewController.OptionsKey: AnyObject]!) {
        super.init(transitionStyle: style, navigationOrientation: navigationOrientation, options: options)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        setViewControllers([TutorialCardOneViewController()], direction: .forward, animated: true, completion: nil)
        setupPageControlIndicator()
    }
    
}

extension PopupTutorialPageViewController {
    
    private func setupPageControlIndicator() {
        let appearance = UIPageControl.appearance()
        appearance.backgroundColor = UIColor.clear
        appearance.pageIndicatorTintColor = UIColor.white
        appearance.currentPageIndicatorTintColor = UIColor.init(hexString: "#FAD747", alpha: 1.0)
    }
    
}

extension PopupTutorialPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if viewController is ConnectionViewController {
            // 3 -> 2
            return TutorialCardTwo()
        } else if viewController is TutorialCardTwo {
            // 2 -> 1
            return TutorialCardOneViewController()
        } else {
            // 1 -> end of the road
            return nil
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if viewController is TutorialCardOneViewController {
            // 1 -> 2
            return TutorialCardTwo()
        } else if viewController is TutorialCardTwo {
            // 2 -> 3
            return ConnectionViewController()
        } else {
            // 3 -> end of the road
            return nil
        }
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        setupPageControlIndicator()
        return 3
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
}

extension PopupTutorialPageViewController: UIPageViewControllerDelegate {
    
}
