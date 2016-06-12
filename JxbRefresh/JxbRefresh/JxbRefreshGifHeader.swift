//
//  JxbRefreshGifHeader.swift
//  JxbRefresh
//
//  Created by Peter on 16/6/12.
//  Copyright © 2016年 https://github.com/JxbSir. All rights reserved.
//

import UIKit

class JxbRefreshGifHeader: JxbRefreshBaseHeader {

    var images_idle: [UIImage]?
    var images_refresh: [UIImage]?
    
    private let bundelpath = "JxbRefresh.bundle" as NSString
    private let imgRefresh: UIImageView = UIImageView.init()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.imgRefresh.image = UIImage.init()
        self.imgRefresh.frame = self.bounds
        self.imgRefresh.contentMode = .Center
        self.imgRefresh.layer.masksToBounds = true
        self.addSubview(self.imgRefresh)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func pulling(progress: CGFloat) {
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
