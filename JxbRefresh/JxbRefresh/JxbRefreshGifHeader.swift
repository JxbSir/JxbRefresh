//
//  JxbRefreshGifHeader.swift
//  JxbRefresh
//
//  Created by Peter on 16/6/12.
//  Copyright © 2016年 https://github.com/JxbSir. All rights reserved.
//

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


class JxbRefreshGifHeader: JxbRefreshBaseHeader {

    var images_idle: [UIImage]?
    var images_refresh: [UIImage]?
    
    fileprivate let bundelpath = "JxbRefresh.bundle" as NSString
    fileprivate let imgRefresh: UIImageView = UIImageView.init()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.imgRefresh.image = UIImage.init()
        self.imgRefresh.frame = self.bounds
        self.imgRefresh.contentMode = .center
        self.imgRefresh.layer.masksToBounds = true
        self.addSubview(self.imgRefresh)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func pulling(_ progress: CGFloat) {
        let index = Int(CGFloat((images_idle?.count)!) * progress)
        if index < images_idle?.count {
            self.imgRefresh.image = images_idle![index]
        }
    }
    
    override func startRefresh() {
        self.imgRefresh.animationImages = images_refresh
        self.imgRefresh.animationDuration = Double((images_refresh?.count)!) * 0.1
        self.imgRefresh.startAnimating()
    }
    
    override func stopRefresh() {
        self.imgRefresh.stopAnimating()
        self.imgRefresh.animationImages = nil
    }
}
