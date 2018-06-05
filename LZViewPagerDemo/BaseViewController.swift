//
//  BaseViewController.swift
//  XinHe
//
//  Created by HaoSheng on 2018/5/5.
//  Copyright © 2018年 HaoSheng. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    static func createFromNib<T: BaseViewController>(storyBoardId: String) -> T?{
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: storyBoardId) as? T
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

}
