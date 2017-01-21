//
//  ChannelController.swift
//  MusicFM
//
//  Created by Alonso Zhang on 15/12/9.
//  Copyright © 2015年 Alonso Zhang. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol ChannelProtocol{
    //回调方法，将频道id传回到代理中
    func onChangeChannel(channel_id:String)
    func onChangeChannelname(channel_name:String)
    func loadLovelist()
}


class ChannelController: UIViewController ,UITableViewDelegate,UITableViewDataSource{
    //频道列表tableview组件
    @IBOutlet weak var tv: UITableView!
    
    //申明代理
    var delegate:ChannelProtocol?
    
    //频道列表数据
    var channelData:[JSON] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.alpha = 0.8
        
    }
    
    
    func editChannel(sender: UIBarButtonItem){
        self.isEditing = !self.isEditing
    }
    
    //配置tableview数据的行数
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channelData.count
    }

    
    //配置cell的数据
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tv.dequeueReusableCell(withIdentifier: "channel")! as UITableViewCell
        //获取行数据
        let rowData:JSON = self.channelData[indexPath.row] as JSON
        //设置cell的标题
        cell.textLabel?.text = rowData["channel_name"].string
        return cell
    }
    
    //选中了具体的频道
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //获取行数据
        let rowData:JSON = self.channelData[indexPath.row] as JSON
        //获取选中行的频道id
        let channel_id:String = rowData["channel_id"].stringValue
        //将频道id反向传给主界面
        delegate?.onChangeChannel(channel_id: channel_id)
        
        let channel_name:String = rowData["channel_name"].stringValue
        delegate?.onChangeChannelname(channel_name: channel_name)
        
        //关闭当前界面
        self.dismiss(animated: true, completion: nil)
    }
    
    //设置cell的显示动画
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //设置cell的显示动画为3d缩放，xy方向的缩放动画，初始值为0.1 结束值为1
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
        })
        
    }
    
    @IBAction func mylove(sender: UIButton) {
        delegate?.loadLovelist()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backtoplay(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
