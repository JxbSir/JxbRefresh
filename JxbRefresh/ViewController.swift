//
//  ViewController.swift
//  JxbRefresh
//
//  Created by Peter on 16/6/12.
//  Copyright © 2016年 https://github.com/JxbSir. All rights reserved.
//

import UIKit

enum RefreshStyle : Int {
    case none
    case normal
    case gif
}

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    var type: RefreshStyle = RefreshStyle.none
    
    fileprivate var taleView: UITableView = {
        let table = UITableView.init(frame: CGRect.zero, style: UITableViewStyle.grouped)
        table.backgroundColor = UIColor.clear
        table.separatorStyle = UITableViewCellSeparatorStyle.singleLine;
        table.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        table.showsHorizontalScrollIndicator = false
        table.showsVerticalScrollIndicator = false
        
        return table
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.title = "JxbRefresh in Swift"
        self.taleView.delegate = self
        self.taleView.dataSource = self
        self.view.addSubview(taleView)
        self.taleView.frame = self.view.bounds
       
        if self.type.rawValue == RefreshStyle.normal.rawValue {
            //Styel 1 normal loading
            self.taleView.addPullRefresh({ [weak self] in
                DispatchQueue.main.asyncAfter(deadline: afterTime(3)) {
                    self?.taleView.stopPullRefresh()
                }
            })
        }
        else if self.type.rawValue == RefreshStyle.gif.rawValue {
            //Style 2  gif
            let arrIdle: NSMutableArray = NSMutableArray.init(capacity: 0)
            for i in 1...60 {
                let name = String.init(format: "dropdown_anim__000%zd", i)
                let image = UIImage.init(named: name)
                arrIdle.add(image!)
            }
    
            let arrRefresh: NSMutableArray = NSMutableArray.init(capacity: 0)
            for i in 1...3 {
                let name = String.init(format: "dropdown_loading_0%zd", i)
                let image = UIImage.init(named: name)
                arrRefresh.add(image!)
            }
    
            self.taleView.addGifPullRefresh(idleImages: arrIdle, refreshImages: arrRefresh, closure: { [weak self] in
                DispatchQueue.main.asyncAfter(deadline: afterTime(3)) {
                    self?.taleView.stopPullRefresh()
                }
            })
        }
        if (self.type.rawValue != RefreshStyle.none.rawValue) {
            self.taleView.addFooterRefresh(closure: {[weak self] in
                DispatchQueue.main.asyncAfter(deadline: afterTime(3)) {
                    self?.taleView.stopPullRefresh()
                }
            })
        }
    }


    //MARK: tableview
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.type.rawValue == RefreshStyle.none.rawValue {
            return 2
        }
        return 20
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "itemcell"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if (cell == nil) {
            cell = UITableViewCell.init(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
        }
        if self.type.rawValue == RefreshStyle.none.rawValue {
            if indexPath.row == 0 {
                cell?.textLabel?.text = "菊花模式 / Normal Style"
            }
            else if indexPath.row == 1 {
                cell?.textLabel?.text = "动态图模式 / Gif Style"
            }
        }
        else {
            cell?.textLabel?.text = "Test".appendingFormat("%zd", indexPath.row)
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView .deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            let vc:ViewController = ViewController()
            vc.type = RefreshStyle.normal
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if indexPath.row == 1 {
            let vc:ViewController = ViewController()
            vc.type = RefreshStyle.gif
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

