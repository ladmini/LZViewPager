//
//  ViewController.swift
//  LZViewPagerDemo
//
//  Created by lizhu on 2018/6/5.
//  Copyright © 2018年 AGS. All rights reserved.
//

import UIKit

class ViewController7: BaseViewController, LZViewPagerDelegate, LZViewPagerDataSource {
    
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
        button.setTitleColor(UIColor.red, for: .selected)
        button.setTitleColor(UIColor.black, for: .normal)
        return button
    }
    
    func colorForIndicator(at index: Int) -> UIColor {
        return UIColor.red
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let vc1 = UIViewController.createFromNib(storyBoardId: "ContentViewController1")!
        vc1.title = "Title1"
        let vc2 = UIViewController.createFromNib(storyBoardId: "ContentViewController2")!
        vc2.title = "Title2"
        subControllers = [vc1, vc2]
        viewPager.hostController = self
        viewPager.reload()
    }
    
    func widthForButton(at index: Int) -> CGFloat {
        return 80
    }
    
    func buttonsAligment() -> ButtonsAlignment {
        return .center
    }
    
    func widthForIndicator(at index: Int) -> CGFloat {
        return 30
    }
    
}

