//
//  CollectButton.swift
//  FM
//
//  Created by Alonso Zhang on 15/12/17.
//  Copyright © 2015年 Alonso Zhang. All rights reserved.
//

import UIKit

class CollectButton: UIButton {
    var isCollect:Bool = true
    let imgNoCollect:UIImage = UIImage(named: "heartgary")!
    let imgCollect:UIImage = UIImage(named: "heartred")!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addTarget(self, action: #selector(CollectButton.onClick), for: UIControlEvents.touchUpInside)
    }
    
    func onClick(){
        isCollect = !isCollect
        if isCollect{
            self.setImage(imgNoCollect, for: UIControlState.normal)
        }else{
            self.setImage(imgCollect, for: UIControlState.normal)
        }
    }
    
    func collect(){
        isCollect = true
        self.setImage(imgCollect, for: UIControlState.normal)
    }
    
    func nocollect(){
        isCollect = false
        self.setImage(imgNoCollect, for: UIControlState.normal)
    }
}
