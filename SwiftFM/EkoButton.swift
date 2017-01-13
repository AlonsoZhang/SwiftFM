//
//  EkoButton.swift
//  FM
//
//  Created by Alonso on 15/12/10.
//  Copyright © 2015年 Alonso Zhang. All rights reserved.
//

import UIKit

class EkoButton: UIButton {
    var isPlay:Bool = true
    let imgPlay:UIImage = UIImage(named: "play")!
    let imgPause:UIImage = UIImage(named: "pause")!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addTarget(self, action: #selector(EkoButton.onClick), for: UIControlEvents.touchUpInside)
    }
    
    func onClick(){
        isPlay = !isPlay
        if isPlay{
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
