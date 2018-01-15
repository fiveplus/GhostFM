//
//  EkoButton.swift
//  DBFM
//
//  Created by 张珅旿 on 2017/8/23.
//  Copyright © 2017年 张珅旿. All rights reserved.
//

import UIKit

class EkoButton: UIButton {
    var isPlay:Bool = true
    let imgPlay:UIImage = UIImage(named: "play")!
    let imgPause:UIImage = UIImage(named:"pause")!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.addTarget(self, action: #selector(EkoButton.onClick), for: UIControlEvents.touchUpInside)
    }
    func onClick(){
        isPlay = !isPlay
        if isPlay {
            self.setImage(imgPause, for: UIControlState.normal)
        }else{
            self.setImage(imgPlay, for: UIControlState.normal)
        }
    }
    func onPlay(){
        isPlay = true
        self.setImage(imgPause, for: UIControlState.normal)
    }

}
