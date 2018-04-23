//
//  HTTPController.swift
//  MusicFM
//
//  Created by Alonso Zhang on 15/12/9.
//  Copyright © 2015年 Alonso Zhang. All rights reserved.
//

import UIKit
import Alamofire

class HTTPController:NSObject{
    //定义一个代理
    var delegate:HttpProtocol?
    //接收网址，回调代理的方法传回数据
    @objc func onSearch(url:String){

        Alamofire.request(url).responseJSON(options: .mutableContainers) { (request) -> Void in
            if request.result.error == nil {
                self.delegate?.didRecieveResults(results: request.result.value! as AnyObject)
            }else{
                self.delegate?.disableChannelBtn()
                //print(request.result)
                self.delegate?.alertmessage()
            }
        }
    }
}

//定义HTTP协议
protocol HttpProtocol{
    //定义一个方法，接受一个参数:AnyObject
    func didRecieveResults(results:AnyObject)
    func disableChannelBtn()
    func alertmessage()
}
