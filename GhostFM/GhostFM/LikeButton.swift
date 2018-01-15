//
//  likeButton.swift
//  DBFM
//
//  Created by 张珅旿 on 2017/8/23.
//  Copyright © 2017年 张珅旿. All rights reserved.
//

import UIKit

class LikeButton: UIButton {
    var isLike:Bool = false
    let noLike:UIImage = UIImage(named: "nolike")!
    let like:UIImage = UIImage(named:"like")!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addTarget(self, action: #selector(LikeButton.onClick), for: UIControlEvents.touchUpInside)
    }
    
    func onClick(){
        if isLike {
            self.setImage(noLike, for: UIControlState.normal)
        }else{
            self.setImage(like, for: UIControlState.normal)
        }
        isLike = !isLike
    }
    
    func onLike(isLike:Bool){
        self.isLike = isLike
        if !self.isLike {
            self.setImage(noLike, for: UIControlState.normal)
        }else{
            self.setImage(like, for: UIControlState.normal)
        }
    }
    
}
