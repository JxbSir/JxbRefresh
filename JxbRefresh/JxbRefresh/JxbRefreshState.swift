//
//  JxbRefreshState.swift
//  JxbRefresh
//
//  Created by Peter on 16/6/12.
//  Copyright © 2016年 https://github.com/JxbSir. All rights reserved.
//

import Foundation

public typealias JxbRefreshClosure = () -> ()

enum JxbRefreshPullState : Int {
    case none
    case pulling
    case willRefresh
    case refreshing
}
