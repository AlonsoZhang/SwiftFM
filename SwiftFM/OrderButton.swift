//
//  OrderButton.swift
//  FM
//
//  Created by Alonso Zhang on 15/12/11.
//  Copyright © 2015年 Alonso Zhang. All rights reserved.
//

import UIKit

class OrderButton: UIButton {
    @objc var order:Int = 1
    
    @objc let order1:UIImage = UIImage(named: "order1")!
    @objc let order2:UIImage = UIImage(named: "order2")!
    @objc let order3:UIImage = UIImage(named: "order3")!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addTarget(self, action: #selector(OrderButton.onClick(sender:)), for: UIControlEvents.touchUpInside)
    }
    
    @objc func onClick(sender:UIButton){
        order += 1
        if order == 1{
            self.setImage(order1, for: UIControlState.normal)
        }else if order == 2 {
            self.setImage(order2, for: UIControlState.normal)
        }else if order == 3 {
            self.setImage(order3, for: UIControlState.normal)
        }else if order > 3 {
            order = 1
            self.setImage(order1, for: UIControlState.normal)
        }
    }
}
