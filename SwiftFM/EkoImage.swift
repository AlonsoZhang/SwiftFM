//
//  EkoImage.swift
//  MusicFM
//
//  Created by Alonso Zhang on 15/12/9.
//  Copyright © 2015年 Alonso Zhang. All rights reserved.
//

import UIKit

class EkoImage: UIImageView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //设置圆角
        self.clipsToBounds = true
        self.layer.cornerRadius = self.frame.size.width/2
        
        //边框
        self.layer.borderWidth = 4
        self.layer.borderColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.7).cgColor
    }
    
    //旋转
    @objc func onRotation(){
        //动画实例关键字
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        //初始值
        animation.fromValue = 0.0
        //结束值
        animation.toValue = Double.pi*2.0
        //动画执行时间
        animation.duration = 20
        //动画重复次数
        animation.repeatCount = 10000
        self.layer.add(animation, forKey: nil)
    }
}
