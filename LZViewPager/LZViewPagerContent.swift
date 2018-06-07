//
//  LZViewPagerContent.swift
//  
//
//  Created by lizhu on 2018/4/12.
//  Copyright © 2018年 Li Zhu. All rights reserved.
//

import UIKit
import SnapKit

extension UIViewController {
    private struct RuntimeKey {
        static let indexKey = UnsafeRawPointer.init(bitPattern: "indexKey".hashValue)
    }
    
    public var index: Int {
        set {
            objc_setAssociatedObject(self, RuntimeKey.indexKey!,  NSNumber(value: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        get {
            return  (objc_getAssociatedObject(self, RuntimeKey.indexKey!) as! NSNumber).intValue
        }
    }
}

class LZViewPagerContent: UIView, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    public var delegate: LZViewPagerDelegate?
    public var dataSource: LZViewPagerDataSource?
    public var hostController: UIViewController?
    var currentIndex: Int? 
    internal var onSelectionChanged: ((_ newIndex: Int) -> ())?

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let controllerCounts = self.dataSource?.numberOfItems() ?? 0
        let currentIndex = viewController.index
        if currentIndex == controllerCounts - 1 {
            return nil
        }
        let controller = dataSource?.controller(at: currentIndex + 1)
        controller?.index = currentIndex + 1
        return controller
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let currentIndex = viewController.index
        if currentIndex == 0 {
            return nil
        }
        let controller = dataSource?.controller(at: currentIndex - 1)
        controller?.index = currentIndex - 1
        return controller
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        self.delegate?.willTransition?(to: pendingViewControllers[0].index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            self.currentIndex = (self.pageViewController!.viewControllers![0]).index
            self.onSelectionChanged?(self.currentIndex!)
            self.delegate?.didTransition?(to: self.currentIndex!)
        }
    }
    
    private lazy var pageViewController: UIPageViewController? = {
        let pvc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pvc.delegate = self
        pvc.dataSource = self
        return pvc
    }()
    
    internal func scroll(to index: Int) {
        if let controller = self.dataSource?.controller(at: index) {
            controller.index = index
            if let currentIndex = (self.pageViewController?.viewControllers?[0])?.index {
                if index == currentIndex {
                    return
                }
                else if index > currentIndex {
                    self.pageViewController?.setViewControllers([controller], direction: .forward, animated: true, completion: nil)
                } else {
                    self.pageViewController?.setViewControllers([controller], direction: .reverse, animated: true, completion: nil)
                }
            } else {
                self.pageViewController?.setViewControllers([controller], direction: .forward, animated: true, completion: nil)
            }
            self.currentIndex = index
        }
    }
    
    public func reload() {
        guard let _ = hostController else {
            assertionFailure("You must specify a host controller")
            return
        }
        if let pvc = self.pageViewController {
            if let _ = pvc.view.superview {
                pvc.willMove(toParentViewController: nil)
                pvc.view.removeFromSuperview()
                pvc.didMove(toParentViewController: nil)
                pvc.removeFromParentViewController()
            }
            hostController?.addChildViewController(pvc)
            pvc.willMove(toParentViewController: hostController)
            self.addSubview(pvc.view)
            pvc.didMove(toParentViewController: hostController)
        }
        if let first = self.dataSource?.controller(at: 0) {
            self.pageViewController?.setViewControllers([first], direction: .forward, animated: true, completion: nil)
            first.index = 0
            self.currentIndex = 0
        }
        for view in self.pageViewController?.view.subviews ?? [] {
            if view.isKind(of: UIScrollView.self) {
                (view as! UIScrollView).delaysContentTouches = false
            }
        }
        self.pageViewController?.view.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
    }

}
