//
//  UIViewController+Ext.swift
//  LZViewPagerDemo
//
//  Created by lizhu on 2018/6/14.
//  Copyright © 2018年 AGS. All rights reserved.
//

import UIKit

extension UIViewController {
    static func createFromNib<T: UIViewController>(storyBoardId: String) -> T? {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: storyBoardId) as? T
    }
}
