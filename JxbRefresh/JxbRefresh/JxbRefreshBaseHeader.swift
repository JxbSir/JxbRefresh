//
//  JxbRefreshBaseHeader.swift
//  JxbRefresh
//
//  Created by Peter on 16/6/12.
//  Copyright © 2016年 https://github.com/JxbSir. All rights reserved.
//

import UIKit

class JxbRefreshBaseHeader: UIView {
    var state: JxbRefreshPullState = .None
    var jxbClosure: JxbRefreshClosure?

    func pulling(progress: CGFloat) {
    }
    
    func startRefresh() {
    }
    
    func stopRefresh() {
        
    }
}
