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
    private struct LZRuntimeKey {
        static let indexKey = UnsafeRawPointer.init(bitPattern: "indexKey".hashValue)
    }
    
    public var index: Int {
        set {
            objc_setAssociatedObject(self, LZRuntimeKey.indexKey!,  NSNumber(value: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        get {
            return  (objc_getAssociatedObject(self, LZRuntimeKey.indexKey!) as! NSNumber).intValue
        }
    }
}

extension UIPageViewController {
    var isScrollEnabled: Bool {
        get {
            var isEnabled: Bool = true
            for view in view.subviews {
                if let subView = view as? UIScrollView {
                    isEnabled = subView.isScrollEnabled
                }
            }
            return isEnabled
        }
        set {
            for view in view.subviews {
                if let subView = view as? UIScrollView {
                    subView.isScrollEnabled = newValue
                }
            }
        }
    }
}

class LZViewPagerContent: UIView, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    var delegate: LZViewPagerDelegate?
    var dataSource: LZViewPagerDataSource?
    var hostController: UIViewController?
    var currentIndex: Int? 
    var onSelectionChanged: ((_ newIndex: Int) -> ())?
    
    var shouldEnableSwipeable: Bool {
        if let e = self.dataSource?.shouldEnableSwipeable?() {
            return e
        } else {
            return true
        }
    }

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
    
    func scroll(to index: Int, animated: Bool = true) {
        if let controller = self.dataSource?.controller(at: index) {
            controller.index = index
            if let currentIndex = (self.pageViewController?.viewControllers?[0])?.index {
                if index == currentIndex {
                    return
                }
                else if index > currentIndex {
                    self.pageViewController?.setViewControllers([controller], direction: .forward, animated: animated, completion: nil)
                } else {
                    self.pageViewController?.setViewControllers([controller], direction: .reverse, animated: animated, completion: nil)
                }
            } else {
                self.pageViewController?.setViewControllers([controller], direction: .forward, animated: animated, completion: nil)
            }
            self.currentIndex = index
        }
    }
    
    public func reload() {
        guard let index = self.currentIndex else {
            return
        }
        guard let _ = hostController else {
            assertionFailure("You must specify a host controller")
            return
        }
        if let pvc = self.pageViewController {
            if let _ = pvc.view.superview {
                pvc.willMove(toParent: nil)
                pvc.view.removeFromSuperview()
                pvc.didMove(toParent: nil)
                pvc.removeFromParent()
            }
            hostController?.addChild(pvc)
            pvc.willMove(toParent: hostController)
            self.addSubview(pvc.view)
            pvc.didMove(toParent: hostController)
            pvc.isScrollEnabled = self.shouldEnableSwipeable
        }
        if let first = self.dataSource?.controller(at: index) {
            self.pageViewController?.setViewControllers([first], direction: .forward, animated: false, completion: nil)
            first.index = index
        }
        for view in self.pageViewController?.view.subviews ?? [] {
            if view.isKind(of: UIScrollView.self) {
                (view as! UIScrollView).delaysContentTouches = false
                (view as! UIScrollView).canCancelContentTouches = true
            }
        }
        self.pageViewController?.view.snp.remakeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
    }
    
    

}
