//
//  LZPageHeaderView.swift
//  
//
//  Created by lizhu on 2018/4/12.
//  Copyright © 2018年 Li Zhu. All rights reserved.
//

import UIKit

extension UIButton {
    private struct RuntimeKey {
        static let indexKey = UnsafeRawPointer.init(bitPattern: "indexKey".hashValue)
    }
    
    public var index: Int {
        set {
            objc_setAssociatedObject(self, RuntimeKey.indexKey!, NSNumber(value: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        get {
            return  (objc_getAssociatedObject(self, RuntimeKey.indexKey!) as! NSNumber).intValue
        }
    }
}

class LZViewPagerHeader: UIView {
    internal var delegate: LZViewPagerDelegate?
    internal var dataSource: LZViewPagerDataSource?
    internal var onSelectionChanged: ((_ newIndex: Int) -> ())?

    @objc internal func buttonAction(sender: UIButton) {
        self.move(to: sender.index)
        self.delegate?.didSelectButton?(at: sender.index)
        self.onSelectionChanged?(sender.index)
    }
    
    private lazy var indicatorView: UIView = {
        return UIView(frame: CGRect.zero)
    }()
    
    internal func move(to index: Int) {
        for view in self.subviews {
            if view.isKind(of: UIButton.self) {
                let button = view as! UIButton
                if button.index == index {
                    button.isSelected = true
                } else {
                    (view as! UIButton).isSelected = false
                }
            }
        }
        if let shouldShowIndicator = self.dataSource?.shouldShowIndicator?() {
            if shouldShowIndicator {
                moveIndicator(to: index)
            }
        } else {
            moveIndicator(to: index)
        }
    }
    
    public func reload() {
        for view in self.subviews {
            view.removeFromSuperview()
        }
        let buttonsCount = self.dataSource?.numberOfItems() ?? 0
        let buttonWidth = self.bounds.size.width / CGFloat(buttonsCount)
        if buttonWidth == 0 {
            return
        }
        for i in 0..<buttonsCount {
            if let button = self.dataSource?.button(at: i) {
                self.addSubview(button)
                button.snp.makeConstraints({ (make) in
                    make.top.equalToSuperview().offset(5)
                    make.leading.equalToSuperview().offset(CGFloat(i) * buttonWidth)
                    make.width.equalTo(buttonWidth)
                    make.bottom.equalToSuperview().offset(-5)
                })
                button.index = i
                if let _ = button.titleLabel?.text {
                   
                } else {
                    let controller = self.dataSource?.controller(at: i)
                    button.setTitle(controller?.title, for: .normal)
                }
                button.addTarget(self, action: #selector(LZViewPagerHeader.buttonAction(sender:)), for: .touchUpInside)
                button.sizeToFit()
            }
        }
        if let shouldShowIndicator = self.dataSource?.shouldShowIndicator?() {
            if shouldShowIndicator {
                setUpIndicator()
            }
        } else {
            setUpIndicator()
        }
    }
    
    private func setUpIndicator() {
        let buttonsCount = self.dataSource?.numberOfItems() ?? 0
        let buttonWidth = self.bounds.size.width / CGFloat(buttonsCount)
        self.indicatorView.backgroundColor = self.dataSource?.colorForIndicator?(at: 0) ?? LZConstants.defaultIndicatorBgColor
        self.addSubview(self.indicatorView)
        let indicatorHight = self.dataSource?.heightForIndicator?(at: 0) ?? LZConstants.defaultIndicatorHight
        self.indicatorView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(5)
            make.width.equalTo(buttonWidth - 10)
            make.bottom.equalToSuperview()
            make.height.equalTo(indicatorHight)
        }
    }
    
    
    private func moveIndicator(to index: Int) {
        UIView.animate(withDuration: 0.3, animations: {
            let buttonsCount = self.dataSource?.numberOfItems() ?? 0
            let buttonWidth = self.bounds.size.width / CGFloat(buttonsCount)
            self.indicatorView.center = CGPoint(x: (CGFloat(index) + 0.5) * buttonWidth, y: self.indicatorView.center.y)
            self.indicatorView.backgroundColor = self.dataSource?.colorForIndicator?(at: index) ?? LZConstants.defaultIndicatorBgColor
            
        }, completion: nil)
    }
}
