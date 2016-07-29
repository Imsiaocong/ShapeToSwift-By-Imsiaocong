//
//  ViewController.swift
//  ShapeToSwift
//
//  Created by 王笛 on 16/5/20.
//  Copyright © 2016年 王笛. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var shapeLayer: CAShapeLayer!
    var path: UIBezierPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let pan: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "panned:")
        self.view.addGestureRecognizer(pan)
        
        self.path = UIBezierPath()
        
        self.shapeLayer = CAShapeLayer()
        self.shapeLayer.fillColor = UIColor.blueColor().CGColor
        self.view.layer.insertSublayer(self.shapeLayer, atIndex: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func panned(pan: UIPanGestureRecognizer) {
        let h:CGFloat = CGRectGetHeight(self.view.frame)
        let innerControlPointRatio:CGFloat = 0.7
        let outerControlPointDistance:CGFloat = 75.0
        
        //我们希望得到触及点的Y坐标，但为了平滑的开始我们只希望得到沿着X轴的变化.
        let touchPoint:CGPoint = CGPointMake(pan.translationInView(pan.view).x, pan.translationInView(pan.view).y)
        
        if pan.state == UIGestureRecognizerState.Began || pan.state == UIGestureRecognizerState.Changed {
            self.path.removeAllPoints()
            self.path.moveToPoint(CGPointZero)
            
            //接下来的两步至关重要
            //贝希尔弧线从左上角到触点
            self.path.addCurveToPoint(CGPointMake(0, touchPoint.y), controlPoint1: CGPointMake(0, touchPoint.y*innerControlPointRatio), controlPoint2: CGPointMake(0, touchPoint.y-outerControlPointDistance))
            //还有从左下角到触点也做一个贝希尔弧线
            self.path.addCurveToPoint(CGPointMake(0, h), controlPoint1: CGPointMake(touchPoint.x, touchPoint.y * innerControlPointRatio), controlPoint2: CGPointMake(0, touchPoint.y + (h - touchPoint.y) * (1.0 - innerControlPointRatio)))
            self.path.closePath()
        }else if pan.state == UIGestureRecognizerState.Ended || pan.state == UIGestureRecognizerState.Cancelled {
            // When pan is done animate the shape layer back to line.
            // However, for path morphing animation to work, it needs
            // to have same number of points as current path (3).
            // Also, this could be done with just 2 lines, but we'll
            // use curves insted for morphing to be smoother.
            // With lines there would be a pointy tip visible towards end.
            self.path.removeAllPoints()
            self.path.moveToPoint(CGPointZero)
            self.path.addCurveToPoint(CGPointMake(0, touchPoint.y), controlPoint1: CGPointMake(0, touchPoint.y*innerControlPointRatio), controlPoint2: CGPointMake(0, touchPoint.y-outerControlPointDistance))
            self.path.addCurveToPoint(CGPointMake(0, h), controlPoint1: CGPointMake(0, touchPoint.y+outerControlPointDistance), controlPoint2: CGPointMake(0, touchPoint.y+(h-touchPoint.y)*(1.0-innerControlPointRatio)))
            self.path.closePath()
            let returnAnimation: CABasicAnimation = CABasicAnimation(keyPath: "path")
            returnAnimation.toValue = self.path
            self.shapeLayer.addAnimation(returnAnimation, forKey: nil)
        }
        // Give the new path to shape layer to draw.
        // Disable actions to prevent implicit animation
        // since we are drawing every frame manually during
        // pan, or adding explicit animation when pan ends.
        CATransaction.begin()
        CATransaction.disableActions()
        self.shapeLayer.path = self.path.CGPath
        CATransaction.commit()
    }
}



