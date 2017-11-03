# YLoadingView

 自定义的加载图层，可以灵活配置外观。

示例程序：

###### 默认 YLoadingView 类显示效果如下

![MacDown Screenshot](./yloading1.gif)


###### YLoadingEatingView 类显示效果如下
![MacDown Screenshot](./yloading2.gif)


因为集成到项目中很多地方用到，我这里直接创建的单粒
提示： 为了在项目使用中不用太依赖其他文件 所以这里YLoadingEatingView是单独重新写的，所以你会看到很多重复的代码，如果你需要在项目中使用
YLoadingView 或者 YLoadingEatingView 只需要将对应的文件导入到项目中即可

另外：YEatingView 这个类 就是那个移动的嘴巴视图 是两个样式都需要的

使用方式：

#### 1.直接调用显示方法

```objc
  YLoadingView.show()
  YLoadingEatingView()
```
#### 2.根据需要配置显示的外观
``` objc
	1. 首先获取单粒对象
	  let  loadV =  YLoadingView.loadingView
	2. 拿到单粒对象可以设置相关的属性，如：
		loadV.isBuble = false //设置不要吐泡泡
		loadV.squareMargin = 8 //设置每个方块之间的间距为8
		loadV.cols = 4 //设置总行数 列数和行数一样 为了美观我这里直接设置为行数和列数一致
 YLoadingEatingView 类使用方法类似

```

如果你在使用中遇到了什么问题，或者希望扩展其他功能，可以直接跟我联系。

更多功能敬请期待！ 
