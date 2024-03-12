//
//  ViewController.swift
//  LZViewPagerDemo
//
//  Created by lizhu on 2018/6/5.
//  Copyright © 2018年 AGS. All rights reserved.
//

import UIKit

class ViewController: BaseViewController, LZViewPagerDelegate, LZViewPagerDataSource {
    
    @IBOutlet weak var viewPager: LZViewPager!
    private var subControllers:[UIViewController] = []
    
    func numberOfItems() -> Int {
        return self.subControllers.count
    }
    
    func controller(at index: Int) -> UIViewController {
        return subControllers[index]
    }
    
    func button(at index: Int) -> UIButton {
        let button = UIButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitleColor(UIColor.black, for: .selected)
        button.setTitleColor(UIColor.black.withAlphaComponent(0.2), for: .normal)
        return button
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let vc1 = UIViewController.createFromNib(storyBoardId: "ContentViewController1")!
        vc1.title = "Title1"
        let vc2 = UIViewController.createFromNib(storyBoardId: "ContentViewController2")!
        vc2.title = "Title2"
        let vc3 = UIViewController.createFromNib(storyBoardId: "ContentViewController3")!
        vc3.title = "Title3"
        let vc4 = UIViewController.createFromNib(storyBoardId: "ContentViewController4")!
        vc4.title = "Title4"
        subControllers = [vc1, vc2, vc3, vc4]
        viewPager.hostController = self
        viewPager.reload()
    }
    
    func willTransition(to index: Int) {
        print("Current index before transition: \(viewPager.currentIndex ?? -1)")
    }
    
    func didTransition(to index: Int) {
        print("Current index after transition: \(viewPager.currentIndex ?? -1)")
    }

    func didSelectButton(at index: Int) {
        print("Current index before transition: \(viewPager.currentIndex ?? -1)")
        print("Current index after transition: \(index)")
    }
    
    @IBAction func nextPageAction(_ sender: UIBarButtonItem) {
        guard let currentIndex = viewPager.currentIndex else { return }
        let nextIndex = currentIndex + 1 > self.numberOfItems() - 1 ? 0 : currentIndex + 1
        viewPager.select(index: nextIndex, animated: true)
    }
    
    func heightForIndicator() -> CGFloat {
        return 10
    }
    
    func cornerRadiusForIndicator() -> CGFloat {
        return 5.0
    }
    
    func colorForIndicator(at index: Int) -> UIColor {
        if index == 0 {
            return .red
        } else if index == 1 {
            return .yellow
        } else if index == 2 {
            return .green
        } else {
            return .black
        }
    }
    
//    func backgroundColorForHeader() -> UIColor {
//        return .clear
//    }
//
//    func leftMarginForHeader() -> CGFloat {
//        return 10
//    }
//
//    func rightMarginForHeader() -> CGFloat {
//        return 10
//    }
//
//    func shouldShowSeparator() -> Bool {
//        return true
//    }
//
//    func colorForSeparator() -> UIColor {
//        return .black
//    }
//
//    func leftMarginForSeparator() -> CGFloat {
//        return 5
//    }
//
//    func rightMarginForSeparator() -> CGFloat {
//        return 30
//    }
//
//    func topMarginForSeparator() -> CGFloat {
//        return -2.0
//    }
    
}

