//
//  JxbRefreshState.swift
//  JxbRefresh
//
//  Created by Peter on 16/6/12.
//  Copyright © 2016年 https://github.com/JxbSir. All rights reserved.
//

import Foundation

enum JxbRefreshPullState : Int {
    case None
    case Pulling
    case WillRefresh
    case Refreshing
}