//
//  ViewController.swift
//  loadingDemo2.0
//
//  Created by shusy on 2017/11/1.
//  Copyright © 2017年 杭州爱卿科技. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        YLoadingView.show()
        let  loadV =  YLoadingView.loadingView
        loadV.squareMargin = 5
        
    }
    
}

