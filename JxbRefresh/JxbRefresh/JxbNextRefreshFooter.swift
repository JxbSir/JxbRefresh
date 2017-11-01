//
//  JxbNextRefreshFooter.swift
//  JxbRefresh
//
//  Created by Peter on 16/6/13.
//  Copyright © 2016年 https://github.com/JxbSir. All rights reserved.
//

import UIKit

class JxbNextRefreshFooter: JxbRefreshBaseHeader {

    fileprivate let indicator: UIActivityIndicatorView = UIActivityIndicatorView.init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.indicator.activityIndicatorViewStyle = .gray
        self.indicator.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        self.indicator.center = self.center
        self.addSubview(indicator)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func startRefresh() {
        self.indicator.startAnimating()
    }
    
    override func stopRefresh() {
        self.indicator.stopAnimating()
    }

}
