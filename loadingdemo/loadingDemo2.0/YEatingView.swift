//
//  YEatingView.swift
//  loadingdemo
//
//  Created by shusy on 2017/10/31.
//  Copyright © 2017年 杭州爱卿科技. All rights reserved.
//

import UIKit

class YEatingView: UIView {
    
    /// 是否绘制吃的路径
    public var isEating:Bool = false {
        didSet{
            if isEating == oldValue { return }
            setNeedsDisplay()
        }
    }
    
    /// 是否需要吐泡泡
    public var isBuble:Bool = true {
        didSet{
            if isBuble == oldValue { return }
            if isBuble {
                emitterLayer?.birthRate = 2
            }else{
                emitterLayer?.removeFromSuperlayer()
                emitterLayer = nil
            }
        }
    }
    
    /// 眼睛 大圆的颜色
    public var eyeBackColor:UIColor = UIColor.white {
        didSet{
            if eyeBackColor == oldValue { return }
            setNeedsDisplay()
        }
    }
    /// 眼睛 小圆的颜色
    public var eyeForwardColor:UIColor = UIColor.black {
        didSet{
            if eyeForwardColor == oldValue { return }
            setNeedsDisplay()
        }
    }
    
    /// 默认路径路径填充的颜色
    public var nomalFillColor:UIColor = UIColor.red {
        didSet{
            if nomalFillColor == oldValue { return }
            setNeedsDisplay()
        }
    }
    
    /// 吃的路径填充的颜色
    public var eatFillColor:UIColor = UIColor.red {
        didSet{
            if eatFillColor == oldValue { return }
            setNeedsDisplay()
        }
    }
    
    /// 嘴巴的颜色
    public var mouthColor:UIColor = UIColor.black {
        didSet{
            if mouthColor == oldValue { return }
            setNeedsDisplay()
        }
    }
    
    //里面圆的半径比总的当前视图尺寸小多少
    private var minusValue:CGFloat = 2 {
        didSet{
            if minusValue == oldValue { return }
            setNeedsDisplay()
        }
    }
    
    /// 粒子图层
    lazy private var emitterLayer: CAEmitterLayer?  = {
        let emitterLayer = CAEmitterLayer()
        emitterLayer.birthRate = 2
        emitterLayer.renderMode = kCAEmitterLayerOldestLast
        emitterLayer.emitterMode = kCAEmitterLayerLine
        emitterLayer.emitterShape = kCAEmitterLayerLine
        emitterLayer.accessibilityPath = self.bubblePath()
        
        let cell = CAEmitterCell()
        cell.contents =  createImage(color: UIColor.white.withAlphaComponent(0.45))?.cgImage
        cell.birthRate = 2
        cell.lifetime = 0.5
        cell.velocity = 50
        cell.emissionLatitude = CGFloat(90*Double.pi/180)
        cell.yAcceleration = -100
        cell.emissionRange = CGFloat(180*Double.pi/180);
        emitterLayer.emitterCells = [cell]
        self.layer.addSublayer(emitterLayer)
        return emitterLayer
    }()
    
    /// 绘制方法 系统自动调用
    ///
    /// - Parameter rect: 当前视图的frame
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if isEating {
            //绘制吃的路径
            movieEatPath()
        }else{
            //绘制默认的路径
            movieFixPath()
        }
        //获取中心点
        let center = CGPoint(x: rect.size.width*0.5, y: rect.size.height*0.23)
        
        //绘制眼睛
        let path = UIBezierPath(arcCenter: center, radius: rect.size.width*0.12, startAngle: 0, endAngle: CGFloat(Double.pi*2), clockwise: true)
        eyeBackColor.setFill()
        eyeBackColor.setStroke()
        path.fill()
        path.stroke()
        
        //绘制眼睛
        let path1 = UIBezierPath(arcCenter: center, radius: rect.size.width*0.05, startAngle: 0, endAngle: CGFloat(Double.pi*2), clockwise: true)
        eyeForwardColor.setFill()
        eyeForwardColor.setStroke()
        path1.fill()
        path1.stroke()
        
        //添加粒子效果
        emitterLayer?.birthRate = 2
        
    }
    
    /// 移动视图默认的路径
    func movieFixPath(){
        //绘制圆弧
        let  path = UIBezierPath()
        nomalFillColor.setFill()
        nomalFillColor.setStroke()
        let radius = bounds.size.width*0.5
        let center = CGPoint(x: radius, y: radius)
        let arcRadius = radius - minusValue
        path.move(to: center)
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        path.addArc(withCenter: center, radius: arcRadius, startAngle: CGFloat(Double.pi + Double.pi/4), endAngle: CGFloat(-Double.pi*0.5*2), clockwise: true)
        path.fill()
        path.stroke()
    }
    
    /// 移动视图吃的路径
    func movieEatPath(){
        //绘制圆
        let  path = UIBezierPath()
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        eatFillColor.setFill()
        eatFillColor.setStroke()
        let radius = bounds.size.width*0.5
        let center = CGPoint(x: radius, y: radius)
        let arcRadius = radius - minusValue
        path.move(to: center)
        path.addArc(withCenter: center, radius: arcRadius, startAngle: 0, endAngle: CGFloat(Double.pi*2), clockwise: true)
        path.fill()
        path.stroke()
        
        //绘制嘴巴
        let  path1 = UIBezierPath()
        mouthColor.setFill()
        mouthColor.setStroke()
        path1.move(to: center)
        path1.addLine(to: CGPoint(x: minusValue, y: radius))
        path1.fill()
        path1.stroke()
    }
    
    
    /// 绘制吐泡泡的路径
    func bubblePath()->UIBezierPath {
        UIGraphicsBeginImageContext(self.bounds.size)
        let radius = bounds.size.width*0.5
        let  path1 = UIBezierPath()
        UIColor.clear.setFill()
        UIColor.clear.setStroke()
        path1.move(to: center)
        path1.addLine(to: CGPoint(x: minusValue, y: radius))
        path1.fill()
        path1.stroke()
        UIGraphicsEndImageContext()
        return path1
    }
    
    /// 通过颜色创建一张图片
    func createImage(color: UIColor) -> UIImage? {
        let rect = CGRect(x: 0.0, y: 0, width: 5.0, height: 5.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fillEllipse(in: rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? nil
    }
    
}

