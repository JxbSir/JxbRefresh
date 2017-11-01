//
//  JxbRefreshHeader.swift
//  JxbRefresh
//
//  Created by Peter on 16/6/12.
//  Copyright © 2016年 https://github.com/JxbSir. All rights reserved.
//

import UIKit

class JxbRefreshIcon: UIView {
    fileprivate let shapeLayer: CAShapeLayer = CAShapeLayer()
    fileprivate var layerStrokeFrom: CGFloat = 0.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.addSublayer(shapeLayer)
    }
    
    override func layoutSubviews() {
        self.shapeLayer.cornerRadius = self.frame.size.width / 2.0;
        self.shapeLayer.backgroundColor = UIColor.red.cgColor
        self.shapeLayer.fillColor = UIColor.clear.cgColor
        self.shapeLayer.strokeColor = self.layer.borderColor
        self.shapeLayer.strokeStart = 0
        self.shapeLayer.strokeEnd = 0
        self.shapeLayer.borderWidth = 1
        self.shapeLayer.lineWidth = 1
        self.shapeLayer.path = self.layouPath().cgPath;
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateProgress(_ progress: CGFloat) {
        var p = progress
        if p > 1 {
            p = 1.0
        }
        self.updatePath(p)
    }

    
    fileprivate func layouPath() -> UIBezierPath {
        let startAngle = CGFloat(1.5 * M_PI)
        let endAngle = CGFloat(3.5 * M_PI)
        let width = self.frame.width
        let borderWidth = self.shapeLayer.borderWidth
        return UIBezierPath.init(arcCenter: CGPoint(x: width/2.0, y: width/2.0), radius: width/2.0-borderWidth, startAngle: startAngle, endAngle: endAngle, clockwise: true)
    }
    
    fileprivate func updatePath(_ progress: CGFloat) -> Void {
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey:kCATransactionDisableActions)
        self.shapeLayer.strokeEnd = progress
        CATransaction.commit()
    }
}

class JxbRefreshHeader: JxbRefreshBaseHeader {

    fileprivate let bundelpath = "JxbRefresh.bundle" as NSString
    fileprivate var viewRefresh: JxbRefreshIcon?
    fileprivate let imgRefresh: UIImageView = UIImageView.init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.viewRefresh = JxbRefreshIcon.init(frame: CGRect(x: frame.width / 2 - 16, y: frame.height / 2 - 12, width: 24, height: 24))
        self.viewRefresh!.layer.cornerRadius = 12
        self.addSubview(self.viewRefresh!)
       
        let icondata = Data.init(base64Encoded: iconRefresh, options: .ignoreUnknownCharacters)
        self.imgRefresh.image = UIImage.init(data: icondata!)
        self.imgRefresh.frame = CGRect(x: 4, y: 4, width: 16, height: 16)
        self.viewRefresh!.addSubview(self.imgRefresh)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func pulling(_ progress: CGFloat) {
        self.viewRefresh?.updateProgress(progress)
    }
    
    override func startRefresh() {
        let animation = CABasicAnimation.init(keyPath: "transform.rotation.z")
        animation.toValue = NSNumber.init(value: M_PI * 2.0 as Double)
        animation.duration = 1.0
        animation.repeatCount = 99999
        animation.isCumulative = false
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        self.imgRefresh.layer.add(animation, forKey: "Rotation")
    }
    
    override func stopRefresh() {
        self.imgRefresh.layer.removeAllAnimations()
        DispatchQueue.main.asyncAfter(deadline: afterTime(0.35)) { [weak self] in
            self?.viewRefresh?.updateProgress(0)
        }
    }
    
}
