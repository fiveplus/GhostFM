//
//  LayerAnimation.swift
//  DBFM
//
//  Created by 张珅旿 on 2017/8/24.
//  Copyright © 2017年 张珅旿. All rights reserved.
//  Layer扩展实现

import Foundation
import UIKit

extension CALayer{
    //暂停动画
    func pauseAnimation() {
        let pauseTime = convertTime(CACurrentMediaTime(), from: nil)
        speed = 0.0
        timeOffset = pauseTime
    }
    //恢复动画
    func resumeAnimation() {
        // 1.取出时间
        let pauseTime = timeOffset
        // 2.设置动画的属性
        speed = 1.0
        timeOffset = 0.0
        beginTime = 0.0
        // 3.设置开始动画
        let startTime = convertTime(CACurrentMediaTime(), from: nil) - pauseTime
        beginTime = startTime
    }
}
