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
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        return button
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let vc1 = BaseViewController.createFromNib(storyBoardId: "ContentViewController1") as! ContentViewController1
        vc1.title = "标题1"
        let vc2 = BaseViewController.createFromNib(storyBoardId: "ContentViewController2") as! ContentViewController2
        vc2.title = "标题2"
        let vc3 = BaseViewController.createFromNib(storyBoardId: "ContentViewController3") as! ContentViewController3
        vc3.title = "标题3"
        let vc4 = BaseViewController.createFromNib(storyBoardId: "ContentViewController4") as! ContentViewController4
        vc4.title = "标题4"
        subControllers = [vc1, vc2, vc3, vc4]
        viewPager.hostController = self
        viewPager.reload()
    }


}

