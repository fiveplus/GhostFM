//
//  EkoImage.swift
//  DBFM
//
//  Created by 张珅旿 on 2017/8/22.
//  Copyright © 2017年 张珅旿. All rights reserved.
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
        self.layer.removeAnimation(forKey: "rotation")
        //动画实例关键字
        let anamation = CABasicAnimation(keyPath: "transform.rotation")
        //初始值
        anamation.fromValue = 0.0
        //结束值
        anamation.toValue = Double.pi*2.0
        //动画执行时间
        anamation.duration = 20
        //动画重复次数
        anamation.repeatCount = 10000
        anamation.isRemovedOnCompletion = false
        self.layer.add(anamation, forKey: "rotation")
    }
    //继续旋转
    func onRotation(){
        self.layer.resumeAnimation()
    }
    //停止旋转
    func onPause(){
        self.layer.pauseAnimation()
    }
    

}
