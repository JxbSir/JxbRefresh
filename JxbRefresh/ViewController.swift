//
//  ViewController.swift
//  JxbRefresh
//
//  Created by Peter on 16/6/12.
//  Copyright © 2016年 https://github.com/JxbSir. All rights reserved.
//

import UIKit

enum RefreshStyle : Int {
    case None
    case Normal
    case Gif
}

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    var type: RefreshStyle = RefreshStyle.None
    
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
       
        if self.type.rawValue == RefreshStyle.Normal.rawValue {
            //Styel 1 normal loading
            self.taleView.addPullRefresh({ [weak self] in
                dispatch_after(afterTime(3), dispatch_get_global_queue(0, 0), {
                    self?.taleView.stopPullRefresh()
                })
            })
        }
        else if self.type.rawValue == RefreshStyle.Gif.rawValue {
            //Style 2  gif
            let arrIdle: NSMutableArray = NSMutableArray.init(capacity: 0)
            for i in 1...60 {
                let name = String.init(format: "dropdown_anim__000%zd", i)
                let image = UIImage.init(named: name)
                arrIdle.addObject(image!)
            }
    
            let arrRefresh: NSMutableArray = NSMutableArray.init(capacity: 0)
            for i in 1...3 {
                let name = String.init(format: "dropdown_loading_0%zd", i)
                let image = UIImage.init(named: name)
                arrRefresh.addObject(image!)
            }
    
            self.taleView.addGifPullRefresh(idleImages: arrIdle, refreshImages: arrRefresh, closure: { [weak self] in
                dispatch_after(afterTime(3), dispatch_get_global_queue(0, 0), {
                    self?.taleView.stopPullRefresh()
                })
            })
        }
        if (self.type.rawValue != RefreshStyle.None.rawValue) {
            self.taleView.addFooterRefresh(closure: {[weak self] in
                dispatch_after(afterTime(3), dispatch_get_global_queue(0, 0), {
                    self?.taleView.stopPullRefresh()
                    //self?.taleView.setFooterEnable(false)
                })
            })
        }
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
        if self.type.rawValue == RefreshStyle.None.rawValue {
            return 2
        }
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
        if self.type.rawValue == RefreshStyle.None.rawValue {
            if indexPath.row == 0 {
                cell?.textLabel?.text = "菊花模式 / Normal Style"
            }
            else if indexPath.row == 1 {
                cell?.textLabel?.text = "动态图模式 / Gif Style"
            }
        }
        else {
            cell?.textLabel?.text = "Test".stringByAppendingFormat("%zd", indexPath.row)
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView .deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.row == 0 {
            let vc:ViewController = ViewController()
            vc.type = RefreshStyle.Normal
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if indexPath.row == 1 {
            let vc:ViewController = ViewController()
            vc.type = RefreshStyle.Gif
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

