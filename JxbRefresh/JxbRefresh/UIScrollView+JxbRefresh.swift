//
//  UIScrollView+JxbRefresh.swift
//  JxbRefresh
//
//  Created by Peter on 16/6/12.
//  Copyright © 2016年 https://github.com/JxbSir. All rights reserved.
//

import Foundation
import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


func afterTime(_ delay: Double) -> DispatchTime {
    return DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
}


private let offset_heaer_y: CGFloat = 54.0
private let offset_footer_y: CGFloat = 54.0
private let offset_morepull_y: CGFloat = 20.0
private let offset_morenext_y: CGFloat = 40.0
private let JxbContentOffset = "contentOffset";
private let JxbPanstate = "panGestureRecognizer.state";

extension UIScrollView {
    //MARK: public function

    /**
     下拉刷新函数 / the function of pull action
     
     - parameter closure: 执行闭包 / the function of closure
     */
    public func addPullRefresh(_ closure: @escaping JxbRefreshClosure) -> Void {
        self.layoutIfNeeded()
        self.jxbHeader = JxbRefreshHeader.init(frame: CGRect(x: 0, y: -offset_heaer_y, width: self.frame.width, height: offset_heaer_y))
        self.jxbHeader?.backgroundColor = self.backgroundColor
        self.jxbHeader!.jxbClosure = closure
        self.addSubview(self.jxbHeader!)
        self.p_addObsever()
    }
    
    /**
     Gif下拉刷新函数 / the function of pull action with gif
     
     - parameter idleImages:    下拉过程中的图片组 / the images when pulling
     - parameter refreshImages: 刷新过程图片组 / the images when refreshing
     - parameter closure:       执行闭包 / the function of closure
     */
    public func addGifPullRefresh(idleImages: NSArray, refreshImages: NSArray, closure: @escaping JxbRefreshClosure) -> Void {
        self.layoutIfNeeded()
        self.jxbGifHeader = JxbRefreshGifHeader.init(frame: CGRect(x: 0, y: -offset_heaer_y, width: self.frame.width, height: offset_heaer_y))
        self.jxbGifHeader!.backgroundColor = self.backgroundColor
        self.jxbGifHeader!.jxbClosure = closure
        self.jxbGifHeader!.images_idle = (idleImages as! [UIImage])
        self.jxbGifHeader!.images_refresh = (refreshImages as! [UIImage])
        self.addSubview(self.jxbGifHeader!)
        self.p_addObsever()
    }
    
    /**
     触发下拉刷新 / trigger to pull to refresh
     */
    public func triggerPullToRefresh() {
        let baseHeader: JxbRefreshBaseHeader? = self.p_getCurrentHeader()
        if baseHeader != nil {
            baseHeader?.state = .willRefresh
            self.p_adjustRefresh(baseHeader!)
  
        }
    }
    
    /**
     上拉刷新函数 / the function of pull next page action
     - parameter closure: 执行闭包 / the function of closure
     */
    public func addFooterRefresh(closure:@escaping JxbRefreshClosure) ->Void {
        self.layoutIfNeeded()
        self.footerEnable = true
        self.jxbFooter = JxbNextRefreshFooter.init(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: offset_footer_y))
        self.jxbFooter?.backgroundColor = self.backgroundColor
        self.jxbFooter!.jxbClosure = closure
        self.p_addObsever()
    }
   
    /**
     当没有更多数据禁用上拉刷新 / disable the next refresh when it has no more data
     - parameter enbale: true or false
     */
    public func setFooterEnable(_ enbale: Bool) -> Void {
        self.footerEnable = enbale
    }
    
    /**
     结束下拉刷新 / Finish Refresh
     */
    public func stopPullRefresh() {
        let baseHeader: JxbRefreshBaseHeader? = self.p_getCurrentHeader()
        DispatchQueue.main.async(execute: {[weak self, weak baseHeader] in
            if baseHeader?.state == JxbRefreshPullState.refreshing {
                baseHeader?.state = JxbRefreshPullState.none
                baseHeader?.stopRefresh()
                UIView.animate(withDuration: 0.35, animations: {
                    self?.contentInset = UIEdgeInsetsMake((self?.contentInset.top)! - offset_heaer_y, 0, 0, 0)
                })
            }
            else if self?.jxbFooter?.state == JxbRefreshPullState.refreshing {
                self?.jxbFooter?.state = JxbRefreshPullState.none
                self?.jxbFooter?.stopRefresh()
                UIView.animate(withDuration: 0.35, animations: {
                    self?.contentInset = UIEdgeInsetsMake((self?.contentInset.top)!, 0, 0, 0)
                })
            }
        })
    }
    
    //MARK: private function
    fileprivate struct AssociatedKeys {
        static var JxbHeadRefreshName = "JxbHeadRefreshName"
        static var JxbGifHeadRefreshName = "JxbGifHeadRefreshName"
        static var JxbFootRefreshName = "JxbFootRefreshName"
        static var JxbFootRefreshEnableName = "JxbFootRefreshEnableName"
        static var JxbAlreadyAddObserverName = "JxbAlreadyAddObserverName"
    }

    fileprivate var jxbHeader: JxbRefreshHeader? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.JxbHeadRefreshName) as? JxbRefreshHeader
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self,&AssociatedKeys.JxbHeadRefreshName,newValue ,.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    fileprivate var jxbGifHeader: JxbRefreshGifHeader? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.JxbGifHeadRefreshName) as? JxbRefreshGifHeader
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self,&AssociatedKeys.JxbGifHeadRefreshName,newValue ,.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    fileprivate var jxbFooter: JxbNextRefreshFooter? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.JxbFootRefreshName) as? JxbNextRefreshFooter
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self,&AssociatedKeys.JxbFootRefreshName,newValue ,.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    fileprivate var footerEnable: Bool? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.JxbFootRefreshEnableName) as? Bool
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self,&AssociatedKeys.JxbFootRefreshEnableName,newValue ,.OBJC_ASSOCIATION_ASSIGN)
            }
        }
    }
    
    fileprivate var alreadayAddObserver: Bool? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.JxbAlreadyAddObserverName) as? Bool
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self,&AssociatedKeys.JxbAlreadyAddObserverName,newValue ,.OBJC_ASSOCIATION_ASSIGN)
            }
        }
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview == nil {
            self.p_removeObsever()
        }
    }

    fileprivate func p_addObsever() {
        if self.alreadayAddObserver == nil || self.alreadayAddObserver == false {
            self.alreadayAddObserver = true
            self.addObserver(self, forKeyPath: JxbContentOffset, options: .new, context: nil)
            self.addObserver(self, forKeyPath: JxbPanstate, options: .new, context: nil)
        }
    }
    
    fileprivate func p_removeObsever() {
        if self.alreadayAddObserver == true {
            self.removeObserver(self, forKeyPath: JxbContentOffset)
            self.removeObserver(self, forKeyPath: JxbPanstate)
        }
    }
  
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        let baseHeader: JxbRefreshBaseHeader? = self.p_getCurrentHeader()
        let baseFooter: JxbNextRefreshFooter? = self.jxbFooter
        if keyPath == JxbPanstate {
            if baseHeader?.state.rawValue > JxbRefreshPullState.willRefresh.rawValue {
                return
            }
            if baseFooter?.state.rawValue > JxbRefreshPullState.willRefresh.rawValue {
                return
            }
            switch self.panGestureRecognizer.state {
            case .began:
                baseHeader?.state = JxbRefreshPullState.pulling
                break
            case .changed:
                baseHeader?.state = JxbRefreshPullState.pulling
                break
            case .ended:
                print(self.contentOffset.y)
                if -self.contentOffset.y > self.contentInset.top + offset_heaer_y + offset_morepull_y {
                    baseHeader?.state = JxbRefreshPullState.willRefresh;
                }
                if self.contentOffset.y + self.frame.height + offset_morenext_y >= self.contentSize.height {
                    baseFooter?.state = JxbRefreshPullState.willRefresh;
                }
                break
            default :
                break
            }
        }

        if baseHeader != nil {
            self.p_adjustRefresh(baseHeader!)
        }
        if baseFooter != nil && footerEnable! {
            self.p_adjustFooterRefresh(baseFooter!)
        }
        
    }
   
    fileprivate func p_adjustRefresh(_ baseHeader: JxbRefreshBaseHeader) {
        if baseHeader.state != JxbRefreshPullState.refreshing {
            let progress = (-self.contentInset.top - self.contentOffset.y - offset_morepull_y) / offset_heaer_y
            if (progress > 0) {
                baseHeader.pulling(progress)
            }
        }
        if baseHeader.state == JxbRefreshPullState.willRefresh {
            baseHeader.state = JxbRefreshPullState.refreshing
            if baseHeader.jxbClosure != nil {
                print("Do JxbRefresh")
                baseHeader.jxbClosure!()
            }
            baseHeader.startRefresh()
            UIView.animate(withDuration: 0.35, animations: { [weak self] in
               self?.contentInset = UIEdgeInsetsMake((self?.contentInset.top)! + offset_heaer_y, 0, 0, 0)
            }, completion: { [weak self] (b) in
                self?.setContentOffset(CGPoint(x: 0, y: -(self?.contentInset.top)!), animated: true)
            })
        }
    }
    
    fileprivate func p_adjustFooterRefresh(_ baseFooter: JxbNextRefreshFooter) {
        if baseFooter.state == JxbRefreshPullState.willRefresh {
            baseFooter.state = JxbRefreshPullState.refreshing
            if baseFooter.jxbClosure != nil {
                print("Do Next JxbRefresh")
                baseFooter.jxbClosure!()
            }
            baseFooter.startRefresh()
            baseFooter.frame = CGRect(x: 0, y: self.contentSize.height, width: self.frame.width, height: offset_footer_y)
            self.addSubview(baseFooter)
            UIView.animate(withDuration: 0.35, animations: { [weak self] in
                self?.contentInset = UIEdgeInsetsMake((self?.contentInset.top)!, 0, offset_footer_y, 0)
            })
        }
    }
    
    fileprivate func p_getCurrentHeader() -> JxbRefreshBaseHeader? {
        var baseHeader: JxbRefreshBaseHeader?
        if self.jxbHeader != nil {
            baseHeader = self.jxbHeader
        }
        else if self.jxbGifHeader != nil {
            baseHeader = self.jxbGifHeader
        }
        return baseHeader
    }

}
