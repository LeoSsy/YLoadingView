//
//  YLoadingView.swift
//  loadingdemo
//
//  Created by shusy on 2017/10/30.
//  Copyright © 2017年 杭州爱卿科技. All rights reserved.
//

import UIKit

/// 一个方块的位置信息
struct CircleSquareFrameInfo {
    var view:UIView
    var frame:CGRect
    var index:Int
    var col:Int
    var row:Int
}

/// 运动视图的layer动画
let YLoadingResSquareKeypath = "YLoadingResSquareKeypath"

class YLoadingEatingView: UIView,CAAnimationDelegate {
    
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
    private var frames = Array<CircleSquareFrameInfo>()
    //初始frame
    private var startFrame:CGRect = CGRect.zero
    //动画起始行
    private var startRow:Int = 0
    //动画起始列
    private var startCol:Int = 0
    //记录上一次隐藏的view
    private var lastView:UIView?
    //记录是否重新回到了起点
    private var backStartPoint:Bool = false
    //保存总列数 回随着每次吃完一圈的方框数量减少
    var totalCols:Int = 0
    //记录是否已经吃完了
    var isEatingAll:Bool = false
    //记录开始起始位置的view
    var tempV:UIView!
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
    static var loadingView : YLoadingEatingView {
        struct Static {
            static let instance : YLoadingEatingView = YLoadingEatingView()
        }
        return Static.instance
    }
    
    /// 展示加载视图
    class func show(){
        let loadv = YLoadingEatingView.loadingView
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
        let loadv = YLoadingEatingView.loadingView
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
        //保存总列数
        totalCols =  Int(cols-1)
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
            let frameInfo = CircleSquareFrameInfo(view:tempView,frame: frame, index: i+1,col:Int(col),row:row)
            frames.append(frameInfo)
            //设置默认开始位置为右上角
            if row == 0 && col == cols-1 {
                tempView.isHidden = true
                tempView.alpha = 0.0
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
        
        //如果已经吃完了 就做动画
        if isEatingAll {
            //慢慢显示出所有已经被隐藏的方块
            var index = 0
            //记录开始的view
            for frm in frames {
                UIView.animate(withDuration: 0.15, delay: Double(index)*0.1, options: .curveEaseInOut, animations: {
                    frm.view.isHidden = false
                    frm.view.alpha = 1.0
                }, completion: { (_) in
                    
                })
                if frm.row == 0 && frm.col == Int(cols-1) {
                    tempV = frm.view
                    startFrame = frm.frame
                    startCol = Int(frm.col)
                    startRow = frm.row
                }
                index += 1
            }
            return
        }
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
    
    /// 判断是否列数跟最开始的不一样
    func isNoSame()->Bool{
        return Int(cols-1) != totalCols
    }
    
    /// 判断是否没有可以吃的方块了
    func isNoEatSquare()->Bool{
        var flag = true
        for frm in frames {
            if frm.view.isHidden == false {
                flag = false
            }
        }
        return flag
    }
    
    /// 计算下一个移动的frame
    ///
    /// - Parameter frame: 当前移动的起始frame
    /// - Returns: 下一个需要移动到的frame
    private func getNextFrame(frame:CGRect)->CGRect{
        var tempRect = startFrame
        //记录下一个位置
        var nextCol = 0
        var nextRow = 0
        //如果列数不相同 说明已经吃完了外层的方块
        if isNoSame() {
            let (row,col) = handleInSqure()
            nextRow = row
            nextCol = col
        }else{//如果没有吃完继续吃
            let (row,col) = handleOutSqure()
            nextRow = row
            nextCol = col
        }
        //获取下一行和列对应的位置
        for frm in frames {
            if frm.col == nextCol && frm.row == nextRow {
                tempRect = frm.frame
                startRow = frm.row
                startCol = frm.col
                frm.view.isHidden = true
                frm.view.alpha = 0.0
                break
            }
        }
        return tempRect
    }
    
    /// 处理外层的方块
    func handleOutSqure()->(row:Int,col:Int){
        var nextCol = 0
        var nextRow = 0
       for _ in frames {
            //判断是否在上面
            if startRow == 0 && startCol > 0 {
                //计算下一个位置
                nextRow = startRow
                nextCol = startCol-1
                //重新回到起点
                if (startCol == totalCols){
                    //先旋转回来
                    animatedView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi*2))
                }
                break
            }else if startRow < totalCols  && startCol == 0 { //在左边
                animatedView.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi*0.5))
                //计算下一个位置
                nextRow = startRow+1
                nextCol = startCol
                break
            }else if (startRow ==  totalCols && startCol < totalCols ){//判断是否在下边
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
                //如果已经吃完了最外面的 继续吃里面的方块
                if startRow == 1 {
                    if isEatingAllSquare() {
                        isEatingAll = true
                    }else{
                        if isNoEatSquare() {
                            isEatingAll = true
                            //执行动画
                            finishAnimation()
                        }
                    }
                    nextRow = startRow
                    nextCol = totalCols
                }
                break
            }
        }
        return (nextRow,nextCol)
    }
    
    /// 处理内层的方块
    func handleInSqure()->(row:Int,col:Int){
        var nextCol = 0
        var nextRow = 0
        //获取和原来的组和列的差值
        let oldCols = Int(cols-1)
        let minus = oldCols-totalCols
        for _ in frames {
            //判断是否在上面
            if startRow == minus && startCol > minus {
                //计算下一个位置
                nextRow = startRow
                nextCol = startCol-1
                break
            }else if startRow <  oldCols-minus  && startCol == minus { //在左边
                animatedView.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi*0.5))
                //计算下一个位置
                nextRow = startRow+1
                nextCol = startCol
                break
            }else if (startRow == oldCols-minus && startCol < oldCols-minus ){//判断是否在下边
                animatedView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                //计算下一个位置
                nextRow = startRow
                nextCol = startCol+1
                break
            }else if (startCol == oldCols-minus && startRow > minus){//判断是否在右边
                animatedView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi*0.5))
                //计算下一个位置
                if startCol < oldCols-minus  {
                    nextRow = startRow+1
                }else{
                    nextRow = startRow-1
                }
                nextCol = startCol
                //判断是否回到初始位置
                //如果是偶数直接就是可以吃完 否则
                if cols.truncatingRemainder(dividingBy: 2) == 0 {
                    
                }else{//基数可以继续chi
                    
                }
                if startRow == minus+1 {
                    if isEatingAllSquare() {
                        isEatingAll = true
                    }else{
                        if isNoEatSquare() {
                            isEatingAll = true
                            //执行动画
                            finishAnimation()
                        }
                    }
                    nextRow = startRow
                    nextCol = totalCols
                }
                break
            }
        }
        return (nextRow,nextCol)
    }
    
    /// 判断是否吃完了所有的方块
    func isEatingAllSquare()->Bool{
        //同时总列数减去1
        totalCols -= 1
        animatedView.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi*2))
        //循环遍历看是否直存在一个视图了
        var count = 0
        for frm in frames {
            if frm.view.isHidden == false {
                count += 1
            }
        }
        //如果总列数小于0 说明吃完了
        if count == 1 {
            //执行动画
            finishAnimation()
            return true
        }
        return false
    }
    
    /// 吃完方块之后的执行动画
   private func finishAnimation(){
        //将当前的行数和列数改为最上方
        DispatchQueue.main.asyncAfter(deadline: .now()+0.25, execute: {
            //粒子增大数量
            self.animatedView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi*0.5))
            self.animatedView.setEmitter(birthRate: 250, lifetime: 1)
            //添加属性动画
            let anim = CAKeyframeAnimation(keyPath: "position.y")
            let fromValue = self.animatedView.frame.origin.y
            let addValue:CGFloat = 15
            anim.values = [fromValue+addValue,fromValue,fromValue-addValue,fromValue+addValue,fromValue,fromValue-addValue,fromValue+addValue,fromValue,fromValue-addValue]
            anim.duration = 1.0
            //如果列数大于6 增大重复时间
            if Int(self.cols) > 6 {
                anim.repeatCount = Float(2.0+(self.cols/2))
            }else{
                anim.repeatCount = 2.0
            }
            anim.isRemovedOnCompletion = false
            anim.fillMode = kCAFillModeForwards
            anim.delegate = self
            self.animatedView.layer.add(anim, forKey: YLoadingResSquareKeypath)
            
        })
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - CAAnimationDelegate
extension YLoadingEatingView{
    
    /// 监听layer动画是否完成
    ///
    /// - Parameters:
    ///   - anim: 动画对象
    ///   - flag: 标志
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.25, execute: {
                //设置粒子数量
                self.animatedView.resentEmitter()
                self.animatedView.layer.removeAllAnimations()
                //保存总列数
                self.totalCols =  Int(self.cols-1)
                UIView.animate(withDuration: 0.25, animations: {
                    self.animatedView.frame = self.startFrame
                    //重新设置开始位置
                    self.tempV.isHidden = true
                    self.tempV.alpha = 0.0
                })
                //设置没有吃完
                self.isEatingAll = false
            })
        }
    }
}


