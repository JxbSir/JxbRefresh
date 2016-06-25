//
//  JxbRefreshHeader.swift
//  JxbRefresh
//
//  Created by Peter on 16/6/12.
//  Copyright © 2016年 https://github.com/JxbSir. All rights reserved.
//

import UIKit

class JxbRefreshIcon: UIView {
    private let shapeLayer: CAShapeLayer = CAShapeLayer()
    private var layerStrokeFrom: CGFloat = 0.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.addSublayer(shapeLayer)
    }
    
    override func layoutSubviews() {
        self.shapeLayer.cornerRadius = self.frame.size.width / 2.0;
        self.shapeLayer.backgroundColor = UIColor.redColor().CGColor
        self.shapeLayer.fillColor = UIColor.clearColor().CGColor
        self.shapeLayer.strokeColor = self.layer.borderColor
        self.shapeLayer.strokeStart = 0
        self.shapeLayer.strokeEnd = 0
        self.shapeLayer.borderWidth = 1
        self.shapeLayer.lineWidth = 1
        self.shapeLayer.path = self.layouPath().CGPath;
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateProgress(progress: CGFloat) {
        var p = progress
        if p > 1 {
            p = 1.0
        }
        self.updatePath(p)
    }

    
    private func layouPath() -> UIBezierPath {
        let startAngle = CGFloat(1.5 * M_PI)
        let endAngle = CGFloat(3.5 * M_PI)
        let width = self.frame.width
        let borderWidth = self.shapeLayer.borderWidth
        return UIBezierPath.init(arcCenter: CGPointMake(width/2.0, width/2.0), radius: width/2.0-borderWidth, startAngle: startAngle, endAngle: endAngle, clockwise: true)
    }
    
    private func updatePath(progress: CGFloat) -> Void {
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey:kCATransactionDisableActions)
        self.shapeLayer.strokeEnd = progress
        CATransaction.commit()
    }
}

class JxbRefreshHeader: JxbRefreshBaseHeader {

    private let bundelpath = "JxbRefresh.bundle" as NSString
    private var viewRefresh: JxbRefreshIcon?
    private let imgRefresh: UIImageView = UIImageView.init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.viewRefresh = JxbRefreshIcon.init(frame: CGRectMake(frame.width / 2 - 16, frame.height / 2 - 12, 24, 24))
        self.viewRefresh!.layer.cornerRadius = 12
        self.addSubview(self.viewRefresh!)
       
        let icondata = NSData.init(base64EncodedString: iconRefresh, options: .IgnoreUnknownCharacters)
        self.imgRefresh.image = UIImage.init(data: icondata!)
        self.imgRefresh.frame = CGRectMake(4, 4, 16, 16)
        self.viewRefresh!.addSubview(self.imgRefresh)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func pulling(progress: CGFloat) {
        self.viewRefresh?.updateProgress(progress)
    }
    
    override func startRefresh() {
        let animation = CABasicAnimation.init(keyPath: "transform.rotation.z")
        animation.toValue = NSNumber.init(double: M_PI * 2.0)
        animation.duration = 1.0
        animation.repeatCount = 99999
        animation.cumulative = false
        animation.removedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        self.imgRefresh.layer.addAnimation(animation, forKey: "Rotation")
    }
    
    override func stopRefresh() {
        self.imgRefresh.layer.removeAllAnimations()
        dispatch_after(afterTime(0.35), dispatch_get_main_queue()) { [weak self] in
            self?.viewRefresh?.updateProgress(0)
        }
    }
    
}
