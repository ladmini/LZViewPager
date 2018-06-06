//
//  LZViewPager.swift
//  
//
//  Created by lizhu on 2018/4/12.
//  Copyright © 2018年 Li Zhu. All rights reserved.
//

import UIKit
import SnapKit
class LZConstants {
    static let defaultIndicatorBgColor = UIColor(red: 255.0/255.0, green: 36.0/255.0, blue: 79.0/255.0, alpha: 1.0)
    static let defaultHeaderHight: CGFloat = 40.0
    static let defaultIndicatorHight: CGFloat = 2.0
}

@objc public protocol LZViewPagerDataSource: AnyObject{
    @objc optional func heightForHeader() -> CGFloat
    @objc optional func heightForIndicator(at index: Int) -> CGFloat
    @objc optional func colorForIndicator(at index: Int) -> UIColor
    @objc optional func shouldShowIndicator() -> Bool
    func numberOfItems() -> Int
    func controller(at index: Int) -> UIViewController
    func button(at index: Int) -> UIButton
}

@objc public protocol LZViewPagerDelegate: AnyObject{
    @objc optional func didSelectButton(at index: Int)
    @objc optional func willTransition(to index: Int)
    @objc optional func didTransition(to index: Int)
}

public class LZViewPager : UIView {
    @IBOutlet public var delegate: LZViewPagerDelegate?
    @IBOutlet public var dataSource: LZViewPagerDataSource?
    public var hostController: UIViewController?

    private lazy var headerView: LZViewPagerHeader = {
        let header = LZViewPagerHeader()
        header.delegate = self.delegate
        header.dataSource = self.dataSource
        header.onSelectionChanged = {[weak self] (newIndex: Int) in
            self?.contentView.scroll(to: newIndex)
        }
        return header
    }()
    
    private lazy var contentView: LZViewPagerContent = {
        let content = LZViewPagerContent()
        content.onSelectionChanged = {[weak self] (newIndex: Int) in
            self?.headerView.move(to: newIndex)
        }
        return content
    }()
    
    public func reload() {
        if let _ = headerView.superview {
            headerView.removeFromSuperview()
        }
        if let _ = contentView.superview {
            contentView.removeFromSuperview()
        }
        self.addSubview(headerView)
        self.addSubview(contentView)
        let headerHeight = dataSource?.heightForHeader?() ?? LZConstants.defaultHeaderHight
        headerView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(headerHeight)
            make.top.equalToSuperview()
        }
        contentView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(headerView.snp.bottom)
        }
        self.headerView.delegate = self.delegate
        self.headerView.dataSource = self.dataSource
        self.contentView.delegate = self.delegate
        self.contentView.dataSource = self.dataSource
        self.contentView.hostController = self.hostController
        self.layoutIfNeeded()
        self.headerView.reload()
        self.contentView.reload()
    }
    
    public func select(index: Int) {
        guard let itemsCount = self.dataSource?.numberOfItems(), index < itemsCount else {
            assertionFailure("Index out of range")
            return
        }
        for v in self.headerView.subviews {
            if v.isKind(of: UIButton.self) {
                let button = v as! UIButton
                if button.index == index {
                    headerView.buttonAction(sender: button)
                    break
                }
            }
        }
    }
    
}
