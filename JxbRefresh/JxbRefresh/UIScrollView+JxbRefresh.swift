//
//  UIScrollView+JxbRefresh.swift
//  JxbRefresh
//
//  Created by Peter on 16/6/12.
//  Copyright © 2016年 https://github.com/JxbSir. All rights reserved.
//

import Foundation
import UIKit

func afterTime(delay: Double) -> dispatch_time_t {
    return dispatch_time(DISPATCH_TIME_NOW,Int64(delay * Double(NSEC_PER_SEC)))
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
    public func addPullRefresh(closure: JxbRefreshClosure) -> Void {
        self.layoutIfNeeded()
        self.jxbHeader = JxbRefreshHeader.init(frame: CGRectMake(0, -offset_heaer_y, self.frame.width, offset_heaer_y))
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
    public func addGifPullRefresh(idleImages idleImages: NSArray, refreshImages: NSArray, closure: JxbRefreshClosure) -> Void {
        self.layoutIfNeeded()
        self.jxbGifHeader = JxbRefreshGifHeader.init(frame: CGRectMake(0, -offset_heaer_y, self.frame.width, offset_heaer_y))
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
            baseHeader?.state = .WillRefresh
            self.p_adjustRefresh(baseHeader!)
  
        }
    }
    
    /**
     上拉刷新函数 / the function of pull next page action
     - parameter closure: 执行闭包 / the function of closure
     */
    public func addFooterRefresh(closure closure:JxbRefreshClosure) ->Void {
        self.layoutIfNeeded()
        self.footerEnable = true
        self.jxbFooter = JxbNextRefreshFooter.init(frame: CGRectMake(0, 0, self.frame.width, offset_footer_y))
        self.jxbFooter?.backgroundColor = self.backgroundColor
        self.jxbFooter!.jxbClosure = closure
        self.p_addObsever()
    }
   
    /**
     当没有更多数据禁用上拉刷新 / disable the next refresh when it has no more data
     - parameter enbale: true or false
     */
    public func setFooterEnable(enbale: Bool) -> Void {
        self.footerEnable = enbale
    }
    
    /**
     结束下拉刷新 / Finish Refresh
     */
    public func stopPullRefresh() {
        let baseHeader: JxbRefreshBaseHeader? = self.p_getCurrentHeader()
        dispatch_async(dispatch_get_main_queue(), {[weak self, weak baseHeader] in
            if baseHeader?.state == JxbRefreshPullState.Refreshing {
                baseHeader?.state = JxbRefreshPullState.None
                baseHeader?.stopRefresh()
                UIView.animateWithDuration(0.35, animations: {
                    self?.contentInset = UIEdgeInsetsMake((self?.contentInset.top)! - offset_heaer_y, 0, 0, 0)
                })
            }
            else if self?.jxbFooter?.state == JxbRefreshPullState.Refreshing {
                self?.jxbFooter?.state = JxbRefreshPullState.None
                self?.jxbFooter?.stopRefresh()
                UIView.animateWithDuration(0.35, animations: {
                    self?.contentInset = UIEdgeInsetsMake((self?.contentInset.top)!, 0, 0, 0)
                })
            }
        })
    }
    
    //MARK: private function
    private struct AssociatedKeys {
        static var JxbHeadRefreshName = "JxbHeadRefreshName"
        static var JxbGifHeadRefreshName = "JxbGifHeadRefreshName"
        static var JxbFootRefreshName = "JxbFootRefreshName"
        static var JxbFootRefreshEnableName = "JxbFootRefreshEnableName"
        static var JxbAlreadyAddObserverName = "JxbAlreadyAddObserverName"
    }

    private var jxbHeader: JxbRefreshHeader? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.JxbHeadRefreshName) as? JxbRefreshHeader
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self,&AssociatedKeys.JxbHeadRefreshName,newValue ,.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    private var jxbGifHeader: JxbRefreshGifHeader? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.JxbGifHeadRefreshName) as? JxbRefreshGifHeader
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self,&AssociatedKeys.JxbGifHeadRefreshName,newValue ,.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    private var jxbFooter: JxbNextRefreshFooter? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.JxbFootRefreshName) as? JxbNextRefreshFooter
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self,&AssociatedKeys.JxbFootRefreshName,newValue ,.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    private var footerEnable: Bool? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.JxbFootRefreshEnableName) as? Bool
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self,&AssociatedKeys.JxbFootRefreshEnableName,newValue ,.OBJC_ASSOCIATION_ASSIGN)
            }
        }
    }
    
    private var alreadayAddObserver: Bool? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.JxbAlreadyAddObserverName) as? Bool
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self,&AssociatedKeys.JxbAlreadyAddObserverName,newValue ,.OBJC_ASSOCIATION_ASSIGN)
            }
        }
    }
    
    public override func willMoveToSuperview(newSuperview: UIView?) {
        if newSuperview == nil {
            self.p_removeObsever()
        }
    }

    private func p_addObsever() {
        if self.alreadayAddObserver == nil || self.alreadayAddObserver == false {
            self.alreadayAddObserver = true
            self.addObserver(self, forKeyPath: JxbContentOffset, options: .New, context: nil)
            self.addObserver(self, forKeyPath: JxbPanstate, options: .New, context: nil)
        }
    }
    
    private func p_removeObsever() {
        if self.alreadayAddObserver == true {
            self.removeObserver(self, forKeyPath: JxbContentOffset)
            self.removeObserver(self, forKeyPath: JxbPanstate)
        }
    }
  
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        let baseHeader: JxbRefreshBaseHeader? = self.p_getCurrentHeader()
        let baseFooter: JxbNextRefreshFooter? = self.jxbFooter
        if keyPath == JxbPanstate {
            if baseHeader?.state.rawValue > JxbRefreshPullState.WillRefresh.rawValue {
                return
            }
            if baseFooter?.state.rawValue > JxbRefreshPullState.WillRefresh.rawValue {
                return
            }
            switch self.panGestureRecognizer.state {
            case .Began:
                baseHeader?.state = JxbRefreshPullState.Pulling
                break
            case .Changed:
                baseHeader?.state = JxbRefreshPullState.Pulling
                break
            case .Ended:
                print(self.contentOffset.y)
                if -self.contentOffset.y > self.contentInset.top + offset_heaer_y + offset_morepull_y {
                    baseHeader?.state = JxbRefreshPullState.WillRefresh;
                }
                if self.contentOffset.y + self.frame.height + offset_morenext_y >= self.contentSize.height {
                    baseFooter?.state = JxbRefreshPullState.WillRefresh;
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
   
    private func p_adjustRefresh(baseHeader: JxbRefreshBaseHeader) {
        if baseHeader.state != JxbRefreshPullState.Refreshing {
            let progress = (-self.contentInset.top - self.contentOffset.y - offset_morepull_y) / offset_heaer_y
            if (progress > 0) {
                baseHeader.pulling(progress)
            }
        }
        if baseHeader.state == JxbRefreshPullState.WillRefresh {
            baseHeader.state = JxbRefreshPullState.Refreshing
            if baseHeader.jxbClosure != nil {
                print("Do JxbRefresh")
                baseHeader.jxbClosure!()
            }
            baseHeader.startRefresh()
            UIView.animateWithDuration(0.35, animations: { [weak self] in
               self?.contentInset = UIEdgeInsetsMake((self?.contentInset.top)! + offset_heaer_y, 0, 0, 0)
            }, completion: { [weak self] (b) in
                self?.setContentOffset(CGPointMake(0, -(self?.contentInset.top)!), animated: true)
            })
        }
    }
    
    private func p_adjustFooterRefresh(baseFooter: JxbNextRefreshFooter) {
        if baseFooter.state == JxbRefreshPullState.WillRefresh {
            baseFooter.state = JxbRefreshPullState.Refreshing
            if baseFooter.jxbClosure != nil {
                print("Do Next JxbRefresh")
                baseFooter.jxbClosure!()
            }
            baseFooter.startRefresh()
            baseFooter.frame = CGRectMake(0, self.contentSize.height, self.frame.width, offset_footer_y)
            self.addSubview(baseFooter)
            UIView.animateWithDuration(0.35, animations: { [weak self] in
                self?.contentInset = UIEdgeInsetsMake((self?.contentInset.top)!, 0, offset_footer_y, 0)
            })
        }
    }
    
    private func p_getCurrentHeader() -> JxbRefreshBaseHeader? {
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