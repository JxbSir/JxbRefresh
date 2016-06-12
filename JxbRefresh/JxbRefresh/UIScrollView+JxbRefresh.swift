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

typealias JxbRefreshClosure = () -> ()

private let offset_heaer_y: CGFloat = 54.0
private let offset_morepull_y: CGFloat = 20.0
private let JxbContentOffset = "contentOffset";
private let JxbPanstate = "panGestureRecognizer.state";

extension UIScrollView {
    //MARK: public function
    
    /**
     下拉刷新函数 / the function of pull action
     
     - parameter closure: 执行闭包 / the function of closure
     */
    func addPullRefresh(closure: JxbRefreshClosure) -> Void {
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
    func addGifPullRefresh(idleImages idleImages: NSArray, refreshImages: NSArray, closure: JxbRefreshClosure) -> Void {
        self.jxbGifHeader = JxbRefreshGifHeader.init(frame: CGRectMake(0, -offset_heaer_y, self.frame.width, offset_heaer_y))
        self.jxbGifHeader!.backgroundColor = self.backgroundColor
        self.jxbGifHeader!.jxbClosure = closure
        self.jxbGifHeader!.images_idle = (idleImages as! [UIImage])
        self.jxbGifHeader!.images_refresh = (refreshImages as! [UIImage])
        self.addSubview(self.jxbGifHeader!)
        self.p_addObsever()
    }
    
    /**
     结束下拉刷新 / Finish Refresh
     */
    func stopPullRefresh() {
        let baseHeader: JxbRefreshBaseHeader? = self.p_getCurrentHeader()
        baseHeader?.state = JxbRefreshPullState.None
        dispatch_async(dispatch_get_main_queue(), {[weak self, weak baseHeader] in
            baseHeader?.stopRefresh()
            UIView.animateWithDuration(0.35, animations: {
                self?.contentInset = UIEdgeInsetsMake((self?.contentInset.top)! - offset_heaer_y, 0, 0, 0)
            })
        })
    }
    
    //MARK: private function
    private struct AssociatedKeys {
        static var JxbHeadRefreshName = "JxbHeadRefreshName"
        static var JxbGifHeadRefreshName = "JxbGifHeadRefreshName"
        static var JxbFootRefreshName = "JxbFootRefreshName"
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
    
    private func p_addObsever() {
        self.addObserver(self, forKeyPath: JxbContentOffset, options: .New, context: nil)
        self.addObserver(self, forKeyPath: JxbPanstate, options: .New, context: nil)
    }
  
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        let baseHeader: JxbRefreshBaseHeader? = self.p_getCurrentHeader()
        if keyPath == JxbPanstate {
            if baseHeader?.state.rawValue > JxbRefreshPullState.WillRefresh.rawValue {
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
                baseHeader?.state = JxbRefreshPullState.WillRefresh
                break
            default :
                break
            }
        }

        self.p_adjustRefresh(baseHeader)
        
    }
    
    private func p_adjustRefresh(baseHeader: JxbRefreshBaseHeader?) {
        if baseHeader?.state != JxbRefreshPullState.Refreshing {
            let progress = (-self.contentInset.top - self.contentOffset.y - offset_morepull_y) / offset_heaer_y
            if (progress > 0) {
                baseHeader?.pulling(progress)
            }
        }
        if baseHeader?.state == JxbRefreshPullState.WillRefresh {
            if -self.contentOffset.y < self.contentInset.top + offset_heaer_y + offset_morepull_y {
                baseHeader?.state = JxbRefreshPullState.None;
                return;
            }
            baseHeader?.state = JxbRefreshPullState.Refreshing
            if baseHeader?.jxbClosure != nil {
                print("Do JxbRefresh")
                baseHeader?.jxbClosure!()
            }
            baseHeader?.startRefresh()
            UIView.animateWithDuration(0.35, animations: { [weak self] in
                self?.contentInset = UIEdgeInsetsMake((self?.contentInset.top)! + offset_heaer_y, 0, 0, 0)
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