//
//  ViewController10.swift
//  LZViewPagerDemo
//
//  Created by LiZhu on 2024/9/19.
//  Copyright © 2024 AGS. All rights reserved.
//

import UIKit

class ViewController10: BaseViewController, LZViewPagerDelegate, LZViewPagerDataSource {
    
    func numberOfItems() -> Int {
        
        return subControllers.count
        
    }
    
    
    
    func controller(at index: Int) -> UIViewController {
        
        print("controller at index: \(index)")
        
        return subControllers[index]
        
    }
    
    
    
    func button(at index: Int) -> UIButton {
        
        let button = UIButton()
        
        //let button = UIButton(type: UIButton.ButtonType.custom)
        
        
        
        // UIColor.label can only be used on iOS 13+, so replace this color
        // button.setTitleColor(UIColor.label, for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        
        
        
        //button.setTitle(String(index), for: UIControl.State.normal)
        
        button.setTitle(String(index), for: UIControl.State.normal)
        
        return button
        
    }
    
    
    
    
    
    func widthForButton(at index: Int) -> CGFloat{
        
        if index > 2 {
            
            //                Tools.p(val: index,"widthForButton index ")
            
        }
        
        return 50
        
    }
    
    func widthForIndicator(at index: Int) -> CGFloat{
        
        if index > 2 {
            
            //                Tools.p(val: index,"widthForIndicator index")
            
        }
        
        return 40
        
    }
    
    
    
    let titleFontSize = 16.0
    
    @IBOutlet weak var viewPager: LZViewPager!
    
    var subControllers:[UIViewController] = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        
        // Do any additional setup after loading the view.
        
        title = "view pager test"
        
        initViewPager()
        
    }
    
    func initViewPager(){
        
        
        
        viewPager.dataSource = self
        
        viewPager.delegate = self
        
        viewPager.hostController = self
        
        
        
        //添加6个vc
        
        for i in 0...5{
            
            let v = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ContentViewController1")
            
            let vv = v.view.subviews[0] as! UILabel
            
            vv.text = String(i)
            
            subControllers.append(v)
            
        }
        
        viewPager.reload()
        
    }
    
    @IBAction func reInit(_ sender: Any) {
        
        
        
        viewPager.dataSource = self
        
        viewPager.delegate = self
        
        viewPager.hostController = self
        
        
        
        subControllers.removeAll()
        
        
        
        //添加3个vc
        
        for i in 0...2{
            
            let v = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ContentViewController2")
            
            let vv = v.view.subviews[0] as! UILabel
            
            vv.text = String(i)
            
            subControllers.append(v)
            
        }
        
        //
        
        viewPager.select(index: 0)
        
        viewPager.reload()
        
        
        
    }
    
}
