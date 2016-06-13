//
//  ViewController.swift
//  JxbRefresh
//
//  Created by Peter on 16/6/12.
//  Copyright © 2016年 https://github.com/JxbSir. All rights reserved.
//

import UIKit


class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    private var taleView: UITableView = {
        let table = UITableView.init(frame: CGRectZero, style: UITableViewStyle.Grouped)
        table.backgroundColor = UIColor.clearColor()
        table.separatorStyle = UITableViewCellSeparatorStyle.SingleLine;
        table.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        table.showsHorizontalScrollIndicator = false
        table.showsVerticalScrollIndicator = false
        
        return table
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "JxbRefresh in Swift"
        self.taleView.delegate = self
        self.taleView.dataSource = self
        self.view.addSubview(taleView)
        self.taleView.frame = self.view.bounds
        
       //Styel 1 normal loading
        self.taleView.addPullRefresh({ [weak self] in 
            dispatch_after(afterTime(3), dispatch_get_global_queue(0, 0), {
                self?.taleView.stopPullRefresh()
            })
        })
        
//        //Style 2  gif
//        let arrIdle: NSMutableArray = NSMutableArray.init(capacity: 0)
//        for i in 1...60 {
//            let name = String.init(format: "dropdown_anim__000%zd", i)
//            let image = UIImage.init(named: name)
//            arrIdle.addObject(image!)
//        }
//        
//        let arrRefresh: NSMutableArray = NSMutableArray.init(capacity: 0)
//        for i in 1...3 {
//            let name = String.init(format: "dropdown_loading_0%zd", i)
//            let image = UIImage.init(named: name)
//            arrRefresh.addObject(image!)
//        }
//        
//        self.taleView.addGifPullRefresh(idleImages: arrIdle, refreshImages: arrRefresh, closure: { [weak self] in
//            dispatch_after(afterTime(3), dispatch_get_global_queue(0, 0), {
//                self?.taleView.stopPullRefresh()
//            })
//        })
        
        
        
        self.taleView.addFooterRefresh(closure: {[weak self] in
            dispatch_after(afterTime(3), dispatch_get_global_queue(0, 0), {
                self?.taleView.stopPullRefresh()
                
//                self?.taleView.setFooterEnable(false)
            })
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    //MARK: tableview
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "itemcell"
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier)
        if (cell == nil) {
            cell = UITableViewCell.init(style: UITableViewCellStyle.Default, reuseIdentifier: identifier)
        }
        cell?.textLabel?.text = "Test".stringByAppendingFormat("%zd", indexPath.row)
        return cell!
    }
}

