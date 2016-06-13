# JxbRefresh
A control of pull to refresh. Writen by swift

-------
##CocoaPods
`pod 'JxbRefresh', '~> 1.0'`

-------
##Example Code

###Style1: pull refresh for normal
``` object-c
self.taleView.addPullRefresh({ [weak self] in 
    dispatch_after(afterTime(3), dispatch_get_global_queue(0, 0), {
        self?.taleView.stopPullRefresh()
    })
})
```

###Style2: pull refresh for gif
``` object-c
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
```

###Style3: pull refresh for load more data
``` object-c
        self.taleView.addFooterRefresh(closure: {[weak self] in
            dispatch_after(afterTime(3), dispatch_get_global_queue(0, 0), {
                self?.taleView.stopPullRefresh()
//                self?.taleView.setFooterEnable(false)
            })
        })
```
