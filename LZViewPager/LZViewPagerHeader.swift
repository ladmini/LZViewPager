//
//  LZViewPagerHeader.swift
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

class LZViewPagerHeader: UIScrollView {
    var pagerDelegate: LZViewPagerDelegate?
    var dataSource: LZViewPagerDataSource?
    var onSelectionChanged: ((_ newIndex: Int) -> ())?
    var currentIndex: Int?

    private lazy var containerView: UIView = {
        let v = UIView(frame: CGRect.zero)
        v.backgroundColor = UIColor.clear
        return v
    }()
    
    private lazy var contentView: UIView = {
        let v = UIView(frame: CGRect.zero)
        v.backgroundColor = UIColor.clear
        return v
    }()
    
    private lazy var indicatorView: UIView = {
        return UIView(frame: CGRect.zero)
    }()
    
    private var buttonsWidth: CGFloat {
        guard let buttonsCount = self.dataSource?.numberOfItems(), buttonsCount > 0 else {
            return 0
        }
        if let _ = self.dataSource?.widthForButton?(at: 0) {
            var totalWidth: CGFloat = 0
            for i in 0..<buttonsCount {
                totalWidth += self.dataSource!.widthForButton!(at: i)
            }
            return totalWidth
        } else {
            return self.bounds.width
        }
    }
    
    private var indicatorHeight: CGFloat {
        if let shouldShowIndicator = self.dataSource?.shouldShowIndicator?() {
            if !shouldShowIndicator {
                return 0
            }
            return self.dataSource?.heightForIndicator?() ?? LZConstants.defaultIndicatorHight
        } else {
            return self.dataSource?.heightForIndicator?() ?? LZConstants.defaultIndicatorHight
        }
    }
    
    private func buttonWidth(at index: Int) -> CGFloat {
        guard let buttonsCount = self.dataSource?.numberOfItems(), buttonsCount > 0 else {
            return 0
        }
        if let _ = self.dataSource?.widthForButton?(at: 0) {
            return self.dataSource!.widthForButton!(at: index)
        } else {
            return self.bounds.width / CGFloat(buttonsCount)
        }
    }
    
    private func xLeading(for index: Int) -> CGFloat {
        var offest: CGFloat = 0
        for i in 0..<index {
            offest += self.buttonWidth(at: i)
        }
        return offest
    }

    private var buttonsAlignment: ButtonsAlignment {
        if let aligment = self.dataSource?.buttonsAligment?() {
            return aligment
        } else {
            return .left
        }
    }
    
    @objc internal func buttonAction(sender: UIButton) {
        self.move(to: sender.index)
        self.pagerDelegate?.didSelectButton?(at: sender.index)
        self.onSelectionChanged?(sender.index)
    }
    
    func move(to index: Int) {
        for view in self.contentView.subviews {
            if view.isKind(of: UIButton.self) {
                let button = view as! UIButton
                if button.index == index {
                    button.isSelected = true
                } else {
                    (view as! UIButton).isSelected = false
                }
            }
        }
        if self.indicatorHeight > 0 {
            self.moveIndicator(to: index)
        }
        self.currentIndex = index
        self.makeButtonCenteredIfNeeded(at: index)
    }
    
    private func makeButtonCenteredIfNeeded(at index: Int, animated: Bool = true) {
        var targetButton: UIButton? = nil
        for view in self.contentView.subviews {
            if view.isKind(of: UIButton.self) {
                let button = view as! UIButton
                if button.index == index {
                    targetButton = button
                }
            }
        }
        guard let button = targetButton else { return }
        guard let _ = button.superview else { return }
        let rect = self.contentView.convert(button.frame, to: self)
        self.scrollRectToVisibleCentered(rect, animated: animated)
    }
    
    public func reload() {
        if self.bounds.size.width == 0 {
            return
        }
        for view in self.subviews {
            view.removeFromSuperview()
        }
        guard let buttonsCount = self.dataSource?.numberOfItems(), buttonsCount > 0 else {
            return
        }
        self.addSubview(self.containerView)
        self.containerView.snp.makeConstraints {[weak self] (make) in
            guard let s = self else { return }
            make.width.equalTo(max(s.buttonsWidth, s.bounds.size.width))
            make.height.equalTo(s.bounds.size.height)
            make.edges.equalToSuperview()
        }
        self.containerView.addSubview(self.contentView)
        self.contentView.snp.makeConstraints {[weak self] (make) in
            guard let s = self else { return }
            if s.buttonsAlignment == .left {
                make.leading.equalToSuperview()
            } else if s.buttonsAlignment == .center {
                make.center.equalToSuperview()
            } else if s.buttonsAlignment == .right {
                make.trailing.equalToSuperview()
            }
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(s.buttonsWidth)
        }
        for i in 0..<buttonsCount {
            if let button = self.dataSource?.button(at: i) {
                button.index = i
                self.contentView.addSubview(button)
                button.snp.makeConstraints({[weak self] (make) in
                    guard let s = self else { return }
                    make.top.equalToSuperview()
                    make.leading.equalToSuperview().offset(s.xLeading(for: i))
                    make.width.equalTo(s.buttonWidth(at: i))
                    make.bottom.equalToSuperview().offset(-s.indicatorHeight)
                })
                if let _ = button.titleLabel?.text {
                    
                } else {
                    let controller = self.dataSource?.controller(at: i)
                    button.setTitle(controller?.title, for: .normal)
                }
                button.addTarget(self, action: #selector(LZViewPagerHeader.buttonAction(sender:)), for: .touchUpInside)
                button.sizeToFit()
                if button.index == currentIndex {
                    button.isSelected = true
                }
            }
        }
        if self.indicatorHeight > 0 {
            self.setUpIndicator()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.makeButtonCenteredIfNeeded(at: self.currentIndex ?? 0, animated: false)
        }
    }
    
    private func setUpIndicator() {
        guard let index = self.currentIndex else { return }
        self.indicatorView.backgroundColor = self.dataSource?.colorForIndicator?(at: 0) ?? LZConstants.defaultIndicatorColor
        self.contentView.addSubview(self.indicatorView)
        self.indicatorView.snp.makeConstraints {[weak self] (make) in
            guard let s = self else { return }
            make.leading.equalToSuperview().offset(s.xLeading(for: index))
            make.width.equalTo(s.buttonWidth(at: index))
            make.bottom.equalToSuperview()
            make.height.equalTo(s.indicatorHeight)
        }
    }
    
    
    private func moveIndicator(to index: Int) {
        self.indicatorView.snp.updateConstraints {[weak self] (make) in
            guard let s = self else { return }
            make.leading.equalToSuperview().offset(s.xLeading(for: index))
            make.width.equalTo(s.buttonWidth(at: index))
            make.bottom.equalToSuperview()
            make.height.equalTo(s.indicatorHeight)
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.indicatorView.backgroundColor = self.dataSource?.colorForIndicator?(at: index) ?? LZConstants.defaultIndicatorColor
            self.containerView.layoutIfNeeded()
        }, completion: nil)
    }
    
    private func scrollRectToVisibleCentered(_ rect: CGRect, animated: Bool) {
        let centedRect = CGRect(x: rect.origin.x + rect.size.width/2.0 - self.frame.size.width/2.0,
                                y: rect.origin.y + rect.size.height/2.0 - self.frame.size.height/2.0,
                                width:  self.frame.size.width,
                                height: self.frame.size.height)
        self.scrollRectToVisible(centedRect, animated: animated)
    }

    
}
