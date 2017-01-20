//
//  ViewController.swift
//  SwiftFM
//
//  Created by Alonso on 16/12/12.
//  Copyright © 2016年 Alonso. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import MediaPlayer

class ViewController: UIViewController, UITableViewDataSource,UITableViewDelegate, HttpProtocol,ChannelProtocol{
    //EkoImage组件，歌曲封面
    @IBOutlet weak var iv: EkoImage!
    //背景
    @IBOutlet weak var bg: UIImageView!
    //歌曲列表
    @IBOutlet weak var tv: UITableView!
    
    @IBOutlet weak var channelname: UILabel!
    
    //网络操作类的实例
    var eHttp:HTTPController = HTTPController()
    
    //定义一个变量，接收频道的列表数据
    var tableData:[JSON] = []
    
    //定义一个变量，接收频道的歌曲数据
    var songData:[JSON] = []
    
    //定义一个变量，接收频道的数据
    var channelData:[JSON] = []
    
    //定义一个图片缓存的字典
    var imageCache = Dictionary<String,UIImage>()
    
    //申明一个媒体播放器的实例
    var audioPlayer:AVPlayer =  AVPlayer()
    
    //申明一个计时器
    var timer:Timer?
    
    //申明下拉刷新
    var refreshControl = UIRefreshControl()
    
    var filePath: String = ""
    
    var songid: String = ""
    
    var onesongid: String = ""
    
    var songarray:[String] = []
    
    var listnum:Int = 1
    
    var listchoose:Int = 0
    
    @IBOutlet weak var progress: UIImageView!
    
    @IBOutlet weak var playTime: UILabel!
    
    //下一首按钮
    @IBOutlet weak var btnNext: UIButton!
    //播放按钮
    @IBOutlet weak var btnPlay: EkoButton!
    //上一首按钮
    @IBOutlet weak var btnPre: UIButton!
    //频道按钮
    @IBOutlet weak var BtnChannel: UIButton!
    //播放顺序按钮
    @IBOutlet weak var btnOrder: OrderButton!
    //收藏按钮
    @IBOutlet weak var btnLove: CollectButton!
    
    //当前在播放第几首
    var currIndex:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        iv.onRotation()
        //设置背景模糊
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame.size = CGSize(width: view.frame.width, height: view.frame.height)
        bg.addSubview(blurView)
        
        //设置tableView的数据源和代理
        tv.dataSource = self
        tv.delegate = self
        
        //为网络操作类设置代理
        eHttp.delegate = self
        //获取频道数据
        eHttp.onSearch(url: "http://fm.baidu.com/dev/api/?tn=channellist&hashcode=310d03041bffd10803bc3ee8913e2726&_=1428801468750")
        //获取频道为1歌曲列表
        eHttp.onSearch(url: "http://fm.baidu.com/dev/api/?tn=playlist&special=flash&prepend=&format=json&_=1378945264366&id=public_tuijian_suibiantingting")
        channelname.text = "随便听听"
        
        //让tableView背景透明
        tv.backgroundColor = UIColor.clear
        
        //监听按钮点击
        btnPlay.addTarget(self, action: #selector(ViewController.onPlay(btn:)), for: UIControlEvents.touchUpInside)
        btnNext.addTarget(self, action: #selector(ViewController.onClick(btn:)), for: UIControlEvents.touchUpInside)
        btnPre.addTarget(self, action: #selector(ViewController.onClick(btn:)), for: UIControlEvents.touchUpInside)
        btnOrder.addTarget(self, action: #selector(ViewController.onOrder(btn:)), for: UIControlEvents.touchUpInside)
        btnLove.addTarget(self, action: #selector(ViewController.onLove(btn:)), for: UIControlEvents.touchUpInside)
        
        //长按手势
        let longpressGesutre = UILongPressGestureRecognizer(target: self, action: Selector(("handleLongpressGesture:")))
        //长按时间为1秒
        longpressGesutre.minimumPressDuration = 1
        self.btnNext.addGestureRecognizer(longpressGesutre)
        
        //播放结束通知
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.playFinish), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: audioPlayer.currentItem)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidBecomeActive, object: nil, queue: OperationQueue.main, using:{
            (notification) -> Void in
            self.iv.onRotation()
        })
        

//        NotificationCenter.default.addObserverForName(UIApplicationDidBecomeActiveNotification, object: nil, queue: OperationQueue.mainQueue, usingBlock: {
//            (notification: NSNotification!) in
//            self.iv.onRotation()
//        })
        
        //添加刷新
        refreshControl.addTarget(self, action: #selector(ViewController.refreshData), for: UIControlEvents.valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "松开后自动刷新")
        tv.addSubview(refreshControl)
        
        let adudiosession = AVAudioSession.sharedInstance()
        do {
            try adudiosession.setCategory(AVAudioSessionCategoryPlayback)
            
        } catch {
            
        }
        
        // 1、获得沙盒的根路径
        let home = NSHomeDirectory() as NSString
        // 2、获得Documents路径，使用NSString对象的stringByAppendingPathComponent()方法拼接路径
        let docPath = home.appendingPathComponent("Documents") as NSString
        // 3、获取文本文件路径
        filePath = docPath.appendingPathComponent("songlist.plist")
        
        
        
    }
    
    //    override func remoteControlReceivedWithEvent(event: UIEvent?) {
    //        if event!.type == UIEventType.RemoteControl {
    //            if event!.subtype == UIEventSubtype.RemoteControlPlay {
    //                print("received remote play")
    //                //                    RadioPlayer.sharedInstance.play()
    //            } else if event!.subtype == UIEventSubtype.RemoteControlPause {
    //                print("received remote pause")
    //                //                    RadioPlayer.sharedInstance.pause()
    //            } else if event!.subtype == UIEventSubtype.RemoteControlTogglePlayPause {
    //                print("received toggle")
    //                //                    RadioPlayer.sharedInstance.toggle()
    //            }
    //        }
    //    }
    
    //长按手势
    func handleLongpressGesture(sender : UILongPressGestureRecognizer){
        if sender.state == UIGestureRecognizerState.began{
            audioPlayer.pause()
        }
        
        if sender.state == UIGestureRecognizerState.changed{
            audioPlayer.rate = 25.0
        }
        
        if sender.state == UIGestureRecognizerState.ended{
            audioPlayer.play()
        }
    }
    
    func refreshData() {
        audioPlayer.pause()
        listchoose += 1
        let url:String = "http://music.baidu.com/data/music/fmlink?type=mp3&rate=1&format=json&songIds=\(songarray[listchoose])"
        eHttp.onSearch(url: url)
        if listchoose == (listnum - 1){
            listchoose = 0
        }
        self.refreshControl.endRefreshing()
    }
    
    //人为结束的三种情况 1 点击上一首，下一首按钮  2 选择了频道列表的时候  3 点击了歌曲列表中的某一行的时候
    func playFinish(){
        switch(btnOrder.order){
        case 1:
            //顺序播放
            currIndex += 1
            if currIndex > songData.count - 1 {
                self.currIndex = 0
            }
            onSelectRow(index: currIndex)
        case 2:
            //随机播放
            currIndex = Int(arc4random()%(UInt32(songData.count)))
            onSelectRow(index: currIndex)
        case 3:
            //单曲循环
            onSelectRow(index: currIndex)
        default:
            break
        }
    }
    
    func onOrder(btn:OrderButton){
        var message:String = ""
        switch(btn.order){
        case 1:
            message = "顺序播放"
        case 2:
            message = "随机播放"
        case 3:
            message = "单曲循环"
        default:
            message = "你说啥"
        }
        self.noticeTop(message, autoClear: true, autoClearTime: 1)
    }
    
    func onClick(btn:UIButton){
        if btn == btnNext {
            currIndex += 1
            if currIndex > self.songData.count - 1 {
                currIndex = 0
            }
        }else{
            currIndex -= 1
            if currIndex < 0 {
                currIndex = self.songData.count - 1
            }
        }
        onSelectRow(index: currIndex)
    }
    
    func onPlay(btn:EkoButton){
        if btn.isPlay{
            audioPlayer.play()
        }else{
            audioPlayer.pause()
        }
    }
    
    @IBAction func otherbtnPlay(sender: UIButton) {
        btnPlay.onClick()
        onPlay(btn: btnPlay)
    }
    
    func onLove(btn:CollectButton){
        var message:String = ""
        if btn.isCollect{
            message = "已取消收藏"
            self.noticeTop(message, autoClear: true, autoClearTime: 1)
            saveRemoveWithFile(channelID: onesongid)
        }else{
            message = "添加收藏成功"
            self.noticeSuccess(message, autoClear: true, autoClearTime: 1)
            saveAddWithFile(channelID: onesongid)
        }
    }
    
    //设置tableview的数据行数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songData.count
    }
    
    //配置tableView的单元格 cell
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tv.dequeueReusableCell(withIdentifier: "douban")! as UITableViewCell
        //让cell背景透明
        cell.backgroundColor = UIColor.clear
        
        //获取cell的数据
        let rowData:JSON = songData[indexPath.row]
        
        //设置cell的标题
        cell.textLabel?.text = rowData["songName"].stringValue
        cell.detailTextLabel?.text = rowData["artistName"].stringValue
        
        //封面的网址
        let url = rowData["songPicSmall"].stringValue
        
        //设置缩略图
        cell.imageView?.image = UIImage(named: "thumb")
        
        //        Alamofire.request(.GET, url!).response(queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), completionHandler: { (_, _, data, _) -> Void in
        //            //将图片数据赋予UIImage
        //            let img = UIImage(data: data!)
        //            dispatch_async(dispatch_get_main_queue(), { () -> Void in
        //                //设置封面的缩略图
        //                cell.imageView?.image =  img
        //            })
        //            //self.imageCache[url] = img
        //        })
        
        onGetCacheImage(url: url, imgView: cell.imageView!)
        
        if url.isEmpty{
            //设置缩略图
            cell.imageView?.image = UIImage(named: "thumb")
        }
        
        return cell
    }
    
    //点击了哪一首歌曲
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onSelectRow(index: indexPath.row)
    }
    
    //设置cell的显示动画
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //设置cell的显示动画为3d缩放，xy方向的缩放动画，初始值为0.1 结束值为1
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
        })
    }
    
    //选中了哪一行
    func onSelectRow(index:Int){
        //构建一个indexPath
        let indexPath = NSIndexPath(row: index, section: 0)
        //选中的效果
        tv.selectRow(at: indexPath as IndexPath, animated: false, scrollPosition: UITableViewScrollPosition.middle)
        //获取行数据
        var rowData:JSON = self.songData[index] as JSON
        //获取该行图片的地址
        let imgUrl = rowData["songPicBig"].string
        //获取歌曲编号
        onesongid = rowData["songId"].stringValue
        
        for (index,_) in readWithFile().enumerated(){
            if readWithFile()[index] as! String == onesongid{
                btnLove.collect()
                btnLove.onClick()
                break
            }else{
                btnLove.nocollect()
                btnLove.onClick()
            }
        }
        //设置封面以及背景
        onSetImage(url: imgUrl!)
        //获取音乐的文件地址
        let url:String = rowData["songLink"].string!
        //播放音乐
        onSetAudio(url: url)
        currIndex = index
    }
    
    //设置歌曲的封面以及背景
    func onSetImage(url:String){
        //        Alamofire.request(Method.GET, url).response { (_, _, data, error) -> Void in
        //            //将获取的数据赋予UIImage
        //            let img = UIImage(data: data!)
        //            self.iv.image = img
        //            self.bg.image = img
        //        }
        onGetCacheImage(url: url, imgView: self.iv)
        onGetCacheImage(url: url, imgView: self.bg)
    }
    
    //播放音乐的方法
    func onSetAudio(url:String) {
        audioPlayer.pause()
        
        //let musicURL = NSURL(string: url.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
        let musicURL = NSURL(string: url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlFragmentAllowed)!)
        audioPlayer = AVPlayer(url: musicURL as! URL)
        audioPlayer.play()
        
        btnPlay.onPlay()
        
        //先停掉计时器
        timer?.invalidate()
        //将计时器归零
        playTime.text = "00:00"
        
        //启动计时器
        timer = Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(ViewController.onUpdate), userInfo: nil, repeats: true)
    }
    
    //计时器更新方法
    func onUpdate(){
        // 00:00 获取播放器当前的播放时间
        let c = CMTimeGetSeconds((audioPlayer.currentItem?.currentTime())!)
        if c > 0.0 {
            //歌曲的总时间
            let t = CMTimeGetSeconds((audioPlayer.currentItem?.duration)!)
            //计算百分比
            let pro:CGFloat = CGFloat(c/t)
            //按百分比显示进度条的宽度
            progress.frame.size.width = view.frame.size.width * pro
            //这是一个小算法，来实现 00:00 这种样式的播放时间
            let all:Int = Int(c)
            let m:Int = all % 60
            let f:Int = Int(all/60)
            
            var time:String = ""
            if f<10 {
                time = "0\(f):"
            }else{
                time = "\(f):"
            }
            
            if m<10 {
                time+="0\(m)"
            }else{
                time+="\(m)"
            }
            //更新播放时间
            playTime.text = time
        }
    }
    
    //图片缓存策略方法
    func onGetCacheImage(url:String,imgView:UIImageView){
        //通过图片地址去缓存中取图片
        let image = self.imageCache[url] as UIImage?
        
        if image == nil {
            //如果缓存中没有这张图片，就通过网络获取
            print("pic")
//            Alamofire.request(url).response{ (_, _, data, error) -> Void in
//                //将获取的图像数据赋予imgView
//                let img = UIImage(data: data!)
//                imgView.image = img
//                self.imageCache[url] = img
//                if url.isEmpty{
//                    imgView.image = UIImage(named: "thumb")
//                }
//            }
//            Alamofire.request(Method.GET, url).response{ (_, _, data, error) -> Void in
//                //将获取的图像数据赋予imgView
//                let img = UIImage(data: data!)
//                imgView.image = img
//                self.imageCache[url] = img
//                if url.isEmpty{
//                    imgView.image = UIImage(named: "thumb")
//                }
//            }
        }else{
            //如果缓存中有，就直接用
            imgView.image = image!
        }
    }
    
    func didRecieveResults(results:AnyObject){
        //print("获取到得数据：\(results)")
        let json = JSON(results)
        //判断是否是频道数据
        if let channels = json["channel_list"].array {
            self.channelData = channels
        }else if let list = json["list"].array {
            self.tableData = list
            for id in tableData.enumerated()
            {
                let rowData:JSON = id.1
                if songid.isEmpty {
                    songid = rowData["id"].stringValue
                }else
                {
                    songid += ","
                    songid += rowData["id"].stringValue
                }
            }
            let songlist = songid.components(separatedBy: ",")
            var count = 0
            listnum = songlist.count / 9
            for _ in 0 ..< listnum {
                songarray.append(songlist[count...(count + 8)].joined(separator: ","))
                count += 9
            }
            //print(songarray)
            let url:String = "http://music.baidu.com/data/music/fmlink?type=mp3&rate=1&format=json&songIds=\(songarray[0])"
            eHttp.onSearch(url: url)
            
        }else {
            for item in json{
                if let songlist = item.1["songList"].array {
                    self.songData = songlist
                    //刷新tv的数据
                    self.tv.reloadData()
                    //设置第一首歌的图片以及背景
                    onSelectRow(index: 0)
                }
            }
        }
        
        BtnChannel.isEnabled = true
        btnNext.isEnabled = true
        btnOrder.isEnabled = true
        btnPlay.isEnabled = true
        btnPre.isEnabled = true
        btnLove.isEnabled = true
    }
    
    func disableChannelBtn(){
        BtnChannel.isEnabled = false
        btnNext.isEnabled = false
        btnOrder.isEnabled = false
        btnPlay.isEnabled = false
        btnPre.isEnabled = false
        btnLove.isEnabled = false
        refreshControl.removeFromSuperview()
    }
    
    func alertmessage(){
        self.noticeOnlyText("无网络连接")
        //self.noticeError("无网络连接", autoClear: true, autoClearTime: nil)
    }
    
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        songarray = []
        songid = ""
        listchoose = 0
        //获取跳转目标
        let channelC:ChannelController = segue.destination as! ChannelController
        //设置代理
        channelC.delegate = self
        //传输频道列表数据
        channelC.channelData = self.channelData
    }
    
    //频道列表协议的回调方法
    func onChangeChannel(channel_id:String){
        //拼凑频道列表的歌曲数据网络地址
        //http://douban.fm/j/mine/playlist?type=n&channel= 频道id &from=mainsite
        let url:String = "http://fm.baidu.com/dev/api/?tn=playlist&special=flash&prepend=&format=json&_=1378945264366&id=\(channel_id)"
        eHttp.onSearch(url: url)
    }
    
    func onChangeChannelname(channel_name:String){
        channelname.text = channel_name
    }
    
    func loadLovelist(){
        channelname.text = "我的最爱"
        //let count = dataSource.count
        print(dataSource)
        for (index,_) in dataSource.enumerated(){
            if index == 0 {
                songid = dataSource[0] as! String
            }else{
                songid = "\(songid),\(dataSource[index])"
            }
        }
        
        print(songid)
        let url:String = "http://music.baidu.com/data/music/fmlink?type=mp3&rate=1&format=json&songIds=\(songid)"
        eHttp.onSearch(url: url)
        self.tv.reloadData()
    }
    
    var dataSource :NSMutableArray = []
    
    func saveAddWithFile(channelID:String) {
        dataSource = readWithFile()
        dataSource.add(channelID)
        // 4、将数据写入文件中
        dataSource.write(toFile: filePath, atomically: true)
        print("Add:\(dataSource)")
    }
    
    func saveRemoveWithFile(channelID:String) {
        dataSource = readWithFile()
        dataSource.remove(channelID)
        // 4、将数据写入文件中
        dataSource.write(toFile: filePath, atomically: true)
        print("Remove:\(dataSource)")
    }
    
    func readWithFile() ->NSMutableArray{
        let file = NSMutableArray(contentsOfFile: filePath)
        if file != nil{
            dataSource = file!
        }else{
            dataSource = []
        }
        return dataSource
    }
    
    override func viewWillAppear(_ animated: Bool) {
        iv.onRotation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
