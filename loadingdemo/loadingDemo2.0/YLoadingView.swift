//
//  YLoadingView.swift
//  loadingdemo
//
//  Created by shusy on 2017/10/30.
//  Copyright © 2017年 杭州爱卿科技. All rights reserved.
//

import UIKit

/// 一个方块的位置信息
struct SquareFrameInfo {
    var view:UIView
    var frame:CGRect
    var index:Int
    var col:Int
    var row:Int
}

class YLoadingView: UIView {
    
    //================公共属性=========
    
    //总行数 列数和行数一样
    public var cols:CGFloat = 4 {
        didSet{
            if cols == oldValue { return }
            resentUI()
        }
    }
    /// 蒙版的颜色
    public var coverColor:UIColor = UIColor.black.withAlphaComponent(0.3) {
        didSet{
            if coverColor == oldValue { return }
            coverView.backgroundColor = coverColor
        }
    }
    
    /// 是否需要吐泡泡
    public var isBuble:Bool = true {
        didSet{
            if isBuble == oldValue { return }
            animatedView.isBuble = isBuble
        }
    }
    
    /// 每个方块之间的间距
    public var squareMargin:CGFloat = 8 {
        didSet{
            if squareMargin == oldValue { return }
            resentUI()
        }
    }
    
    //==============移动视图相关属性
    
    /// 眼睛 大圆的颜色
    public var eyeBackColor:UIColor = UIColor.white {
        didSet{
            if eyeBackColor == oldValue { return }
            animatedView.eyeBackColor = eyeBackColor
        }
    }
    /// 眼睛 小圆的颜色
    public var eyeForwardColor:UIColor = UIColor.white {
        didSet{
            if eyeForwardColor == oldValue { return }
            animatedView.eyeForwardColor = eyeForwardColor
        }
    }
    ///移动视图默认填充的颜色
    public var nomalFillColor:UIColor = UIColor.red {
        didSet{
            if nomalFillColor == oldValue { return }
            animatedView.nomalFillColor = nomalFillColor
        }
    }
    
    ///移动视图吃的填充的颜色
    public var eatFillColor:UIColor = UIColor.red {
        didSet{
            if eatFillColor == oldValue { return }
            animatedView.eatFillColor = eatFillColor
        }
    }
    
    /// 嘴巴的颜色
    public var mouthColor:UIColor = UIColor.black {
        didSet{
            if mouthColor == oldValue { return }
            setNeedsDisplay()
        }
    }
    
    //===============外部视图==================
    //固定方块的颜色
    public var fixColor:UIColor = UIColor.gray {
        didSet{
            if fixColor == oldValue { return }
            for view in subviews {
                view.backgroundColor = fixColor
            }
        }
    }
    //方块的宽高
    public var squareWH:CGFloat = 50 {
        didSet{
            if squareWH == oldValue { return }
            resentUI()
        }
    }
    //固定方块的圆角半径
    public var fixSquareRadius:CGFloat = 6{
        didSet{
            if fixSquareRadius == oldValue { return }
            for view in subviews {
                view.layer.cornerRadius = fixSquareRadius
            }
            setupUI()
        }
    }
    //方块动画时间 多久移动一次 方块动画时间 animDuration 不得小于0.5 如果设置的值小于0.5 会自动设置为0.5
    public var animDuration:TimeInterval = 0.5 {
        didSet{
            if animDuration == oldValue { return }
            if animDuration < 0.5 { animDuration = 0.5 }
            //重新启动定时器
            timer?.invalidate()
            timer = nil
            timer = Timer.scheduledTimer(timeInterval: animDuration, target: self, selector: #selector(animationHandle), userInfo: nil, repeats: true)
            timer?.fire()
        }
    }
    //================私有属性
    //蒙版视图
    private var coverView:UIView!
    //动画视图
    private var animatedView:YEatingView!
    //所有的frame
    private var frames = Array<SquareFrameInfo>()
    //初始frame
    private var startFrame:CGRect = CGRect.zero
    //动画起始行
    private var startRow:Int = 0
    //动画起始列
    private var startCol:Int = 0
    //记录上一次隐藏的view
    private var lastView:UIView?
    //定时器
    private var timer:Timer?
    /// 是否开始动画 true 开始动画 false  结束动画
    private var isAnimating:Bool = false {
        didSet{
            if isAnimating {
                timer = Timer.scheduledTimer(timeInterval: animDuration, target: self, selector: #selector(animationHandle), userInfo: nil, repeats: true)
                timer?.fire()
            }else{
                timer?.invalidate()
                timer = nil
            }
        }
    }
    /// 初始化方法
    ///
    /// - Parameter frame: frame
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    /// 单粒对象
    static var loadingView : YLoadingView {
        struct Static {
            static let instance : YLoadingView = YLoadingView()
        }
        return Static.instance
    }
    
    /// 展示加载视图
    class func show(){
        let loadv = YLoadingView.loadingView
        loadv.cols = 5
        loadv.nomalFillColor = UIColor.orange
        loadv.eatFillColor = UIColor.green
        loadv.fixColor = UIColor.lightGray
        loadv.frame = UIScreen.main.bounds
        loadv.squareWH = 30
        loadv.startAnimation()
        UIApplication.shared.keyWindow?.addSubview(loadv)
    }
    
    /// 关闭加载视图
    class func dismiss(){
        let loadv = YLoadingView.loadingView
        //停止定时器
        loadv.stopAnimation()
        //恢复到初始位置
        loadv.animatedView.frame = loadv.frames[0].frame
        loadv.startCol = 0
        loadv.startRow = 0
        loadv.isHidden = false
        loadv.removeFromSuperview()
    }
    
    /// 开始动画
    func startAnimation(){
        self.isAnimating = true
    }
    
    /// 停止动画
    func stopAnimation(){
        self.isAnimating = false
    }
    
    /// 重置界面
    func resentUI(){
        for view in subviews {
            view.removeFromSuperview()
        }
        frames.removeAll()
        lastView = nil
        setupUI()
    }
    
    /// 初始化九宫格视图
    private  func setupUI(){
        
        //创建蒙版视图
        coverView = UIView(frame: UIScreen.main.bounds)
        coverView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        addSubview(coverView)
        //计算间距
        let leftMargin = (UIScreen.main.bounds.size.width - (cols*squareWH+(cols-1)*squareMargin))*0.5
        let topMargin = (UIScreen.main.bounds.size.height - (cols*squareWH+(cols-1)*squareMargin))*0.5
        for i  in 0..<(Int(cols*cols)){
            let tempView = UIView()
            tempView.layer.cornerRadius = fixSquareRadius
            tempView.backgroundColor = fixColor
            let row = i/Int(cols)
            let col = CGFloat(i).truncatingRemainder(dividingBy: cols)
            let x =  CGFloat(col)*(squareWH+squareMargin)+leftMargin
            let y = CGFloat(row)*(squareWH+squareMargin)+topMargin
            let frame = CGRect(x: x, y: y, width: squareWH, height: squareWH)
            tempView.frame = frame
            addSubview(tempView)
            //保存frames
            let frameInfo = SquareFrameInfo(view:tempView,frame: frame, index: i+1,col:Int(col),row:row)
            frames.append(frameInfo)
            //设置默认开始位置为右上角
            if row == 0 && col == cols-1 {
                startFrame = frame
                startCol = Int(col)
                startRow = row
            }
        }
        //添加占位视图到九宫格中
        animatedView = YEatingView()
        animatedView.frame = startFrame
        animatedView.backgroundColor = UIColor.clear
        addSubview(animatedView)
    }
    
    /// 动画处理方法
    @objc func animationHandle(){
        let rect = getNextFrame(frame: startFrame)
        self.bringSubview(toFront: animatedView)
        //执行动画
        UIView.animate(withDuration: animDuration, animations: {
            self.animatedView.frame = rect
        }) { (_) in
            self.startFrame = rect
        }
        if self.animatedView.isEating  {
            self.animatedView.isEating = false
        }else{
            self.animatedView.isEating = true
        }
    }
    
    /// 计算下一个移动的frame
    ///
    /// - Parameter frame: 当前移动的起始frame
    /// - Returns: 下一个需要移动到的frame
    private func getNextFrame(frame:CGRect)->CGRect{
        if lastView != nil { lastView?.isHidden = false }
        var tempRect = startFrame
        //记录下一个位置
        var nextCol = 0
        var nextRow = 0
        for _ in frames {
            //总列数
            let totalCols = Int(cols-1)
            //判断是否在上面
            if startRow == 0 && startCol > 0 {
                //计算下一个位置
                nextRow = startRow
                nextCol = startCol-1
                if (startCol == totalCols){
                    if self.lastView != nil {
                        animatedView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi*2))
                    }
                }
                break
            }else if startRow < totalCols  && startCol == 0 { //在左边
                animatedView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                //计算下一个位置
                nextRow = startRow+1
                nextCol = startCol
                break
            }else if (startRow == totalCols && startCol < totalCols ){//判断是否在下边
                animatedView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                //计算下一个位置
                nextRow = startRow
                nextCol = startCol+1
                break
            }else if (startCol == totalCols && startRow > 0){//判断是否在右边
                animatedView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi*0.5))
                //计算下一个位置
                if startCol < totalCols  {
                    nextRow = startRow+1
                }else{
                    nextRow = startRow-1
                }
                nextCol = startCol
                break
            }
        }
        //获取下一行和列对应的位置
        for frm in frames {
            if frm.col == nextCol && frm.row == nextRow {
                tempRect = frm.frame
                startRow = frm.row
                startCol = frm.col
                frm.view.isHidden = true
                lastView = frm.view
                break
            }
        }
        return tempRect
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

