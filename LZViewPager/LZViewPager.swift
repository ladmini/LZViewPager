//
//  LZViewPager.swift
//  
//
//  Created by lizhu on 2018/4/12.
//  Copyright © 2018年 Li Zhu. All rights reserved.
//

import UIKit
import SnapKit

@objc public enum ButtonsAlignment: Int {
    case left
    case center
    case right
}

class LZConstants {
    static let defaultIndicatorColor = UIColor(red: 255.0/255.0, green: 36.0/255.0, blue: 79.0/255.0, alpha: 1.0)
    static let defaultHeaderBackgroundColor = UIColor.white
    static let defaultHeaderHight: CGFloat = 40.0
    static let defaultIndicatorHight: CGFloat = 2.0
    static let defaultSeparatorHight: CGFloat = 2.0
}

@objc public protocol LZViewPagerDataSource: AnyObject{
    @objc optional func heightForHeader() -> CGFloat // default is 40
    @objc optional func backgroundColorForHeader() -> UIColor // default is .white
    @objc optional func heightForIndicator() -> CGFloat // default is 2.0
    @objc optional func colorForIndicator(at index: Int) -> UIColor // default is true UIColor(red: 255.0/255.0, green: 36.0/255.0, blue: 79.0/255.0, alpha: 1.0)
    @objc optional func shouldShowIndicator() -> Bool // default is true
    @objc optional func widthForButton(at index: Int) -> CGFloat // default is bounds.width / count
    @objc optional func widthForIndicator(at index: Int) -> CGFloat // default is equals to button's width
    @objc optional func buttonsAligment() -> ButtonsAlignment // default is .left
    @objc optional func shouldEnableSwipeable() -> Bool // default is true
    
    @objc optional func leftMarginForHeader() -> CGFloat //default is 0
    @objc optional func rightMarginForHeader() -> CGFloat //default is 0
    @objc optional func shouldShowSeparator() -> Bool // default is false
    @objc optional func colorForSeparator()-> UIColor // default is .white
    @objc optional func heightForSeparator() -> CGFloat // default is 2.0
    @objc optional func leftMarginForSeparator() -> CGFloat //default is 0
    @objc optional func rightMarginForSeparator() -> CGFloat //default is 0
    @objc optional func topMarginForSeparator() -> CGFloat //default is 0

    
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
    //If empty datasource then the currentIndex will return nil
    public var currentIndex: Int? {
        return self.contentView.currentIndex
    }
    
    private var headerLeading: CGFloat {
        if let leading = self.dataSource?.leftMarginForHeader?() {
            return leading
        } else {
            return 0
        }
    }
    
    private var headerTrailing: CGFloat {
        if let trailing = self.dataSource?.rightMarginForHeader?() {
            return trailing
        } else {
            return 0
        }
    }
    
    private var defaultPageIndex: Int? {
        guard let itemsCount = self.dataSource?.numberOfItems() else {
            return nil
        }
        for i in 0..<itemsCount {
            guard let button = self.dataSource?.button(at: i) else {
                continue
            }
            if button.isSelected {
                return i
            }
        }
        return 0
    }
    
    private lazy var headerView: LZViewPagerHeader = {
        let header = LZViewPagerHeader()
        header.showsVerticalScrollIndicator = false
        header.showsHorizontalScrollIndicator = false
        header.panGestureRecognizer.delaysTouchesBegan = true
        header.pagerDelegate = self.delegate
        header.dataSource = self.dataSource
        header.currentIndex = self.defaultPageIndex
        header.onSelectionChanged = {[weak self] (newIndex: Int, animated: Bool) in
            self?.contentView.scroll(to: newIndex, animated: animated)
        }
        header.backgroundColor = self.dataSource?.backgroundColorForHeader?() ?? LZConstants.defaultHeaderBackgroundColor
        return header
    }()
    
    private lazy var contentView: LZViewPagerContent = {
        let content = LZViewPagerContent()
        content.currentIndex = self.defaultPageIndex
        content.onSelectionChanged = {[weak self] (newIndex: Int) in
            self?.headerView.move(to: newIndex)
        }
        return content
    }()
    
    private lazy var separatorView: UIView = {
        let separator = UIView()
        if let spcolor = self.dataSource?.colorForSeparator?() {
            separator.backgroundColor = spcolor
        } else {
            separator.backgroundColor = .white
        }
        return separator
    }()
    
    public func reload() {
        if let _ = headerView.superview {
            headerView.removeFromSuperview()
        }
        if let _ = contentView.superview {
            contentView.removeFromSuperview()
        }
        
        if let _ = separatorView.superview {
           separatorView.removeFromSuperview()
        }
        
        self.addSubview(headerView)
        self.addSubview(contentView)
        let headerHeight = dataSource?.heightForHeader?() ?? LZConstants.defaultHeaderHight
        headerView.snp.remakeConstraints { (make) in
            make.leading.equalToSuperview().offset(headerLeading)
            make.trailing.equalToSuperview().offset(0 - headerTrailing)
            make.height.equalTo(headerHeight)
            make.top.equalToSuperview()
        }
        
        if let showSeparator = self.dataSource?.shouldShowSeparator?(), showSeparator {
            self.addSubview(separatorView)
            separatorView.snp.remakeConstraints { (make) in
                let leading = self.dataSource?.leftMarginForSeparator?() ?? 0
                let trailing = self.dataSource?.rightMarginForSeparator?() ?? 0
                let top = self.dataSource?.topMarginForSeparator?() ?? 0
                let height = self.dataSource?.heightForSeparator?() ?? LZConstants.defaultSeparatorHight
                make.leading.equalToSuperview().offset(leading)
                make.trailing.equalToSuperview().offset(0 - trailing)
                make.top.equalTo(headerView.snp.bottom).offset(top)
                make.height.equalTo(height)
            }
            self.sendSubviewToBack(separatorView)
        }
        
        contentView.snp.remakeConstraints { (make) in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            if let showSeparator = self.dataSource?.shouldShowSeparator?(), showSeparator {
                let maginTop = self.dataSource?.topMarginForSeparator?() ?? 0
                let height = self.dataSource?.heightForSeparator?() ?? LZConstants.defaultSeparatorHight
                make.top.equalTo(headerView.snp.bottom).offset(maginTop + height)
            } else {
                make.top.equalTo(headerView.snp.bottom)
            }
        }
        self.headerView.pagerDelegate = self.delegate
        self.headerView.dataSource = self.dataSource
        self.contentView.delegate = self.delegate
        self.contentView.dataSource = self.dataSource
        self.contentView.hostController = self.hostController
        self.layoutIfNeeded()
        self.headerView.reload()
        self.contentView.reload()
    }
    
    public func select(index: Int, animated: Bool = true) {
        guard let itemsCount = self.dataSource?.numberOfItems(), index < itemsCount else {
            assertionFailure("Index out of range")
            return
        }
        headerView.selectPage(at: index, animated: animated)
    }
    
}
