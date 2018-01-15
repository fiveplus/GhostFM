//
//  ViewController.swift
//  DBFM
//
//  Created by 张珅旿 on 2017/8/22.
//  Copyright © 2017年 张珅旿. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import MediaPlayer
import AVFoundation

class ViewController: UIViewController,HttpProtocol,ChannelProtocol{
    //EkoImage组件：歌曲封面
    @IBOutlet weak var iv: EkoImage!
    //背景
    @IBOutlet weak var bg: UIImageView!
    //网络操作类实例
    var eHttp:HttpController = HttpController()
    //定义变量接受频道歌曲数据
    var songData:[JSON] = []
    //定义变量接受频道数据
    var channelData:[JSON] = []
    //定义一个图片缓存字典
    var imageCache = Dictionary<String,UIImage>()
    //定义一个播放列表缓存
    var songCache:[JSON] = []
    //申明媒体播放器实例
    var audioPlayer:MPMoviePlayerController = MPMoviePlayerController()
    //申明一个计时器
    var timer:Timer?
    
    @IBOutlet weak var playTime: UILabel!
    @IBOutlet weak var progress: UIImageView!
    //播放按钮绑定
    @IBOutlet weak var btnPlay: EkoButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnLike: LikeButton!
    //初始化请求
    let channelUrl:String = "http://www.douban.com/j/app/radio/channels"
    let playlistUrl:String = "http://douban.fm/j/mine/playlist?type=n&channel=0&from=mainsite"
    var channelId:String = "0"
    
    @IBOutlet weak var btnPre: UIButton!
    //歌曲名字
    @IBOutlet weak var songLabel: UILabel!
    //歌手名字
    @IBOutlet weak var singerLabel: UILabel!
    //channelName
    @IBOutlet weak var channelNameLabel: UILabel!
    
    let likeColor = UIColor.init(red: 255/255.0, green: 123/255.0, blue: 123/255.0, alpha: 1.0)
    let noLikeColor = UIColor.init(red: 144/255.0, green: 130/255.0, blue: 130/255.0, alpha: 1.0)
    
    //当前播放下标
    var currentIndex:Int = -1
    
    //网络监听
    let reachability = Reachability()!
    
    
    //初始化Song CoreData //获得当前应用的AppDelegate对象
    let songManage = SongManage(delegate: UIApplication.shared.delegate as! AppDelegate)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //网络监听
        NetworkStatusListener()
        //开始旋转
        iv.onRotation()
        //设置背景模糊
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame.size = CGSize(width: view.frame.width, height: view.frame.height)
        bg.addSubview(blurView)
        
        //为网络操作类设置代理
        eHttp.delegate = self
        //获取频道
        eHttp.onSearch(url:channelUrl)
        //获取频道为0的歌曲数据
        eHttp.onSearch(url:playlistUrl)
        
        //监听点击
        btnPlay.addTarget(self, action: #selector(ViewController.onPlay), for: UIControlEvents.touchUpInside)
        btnNext.addTarget(self, action: #selector(ViewController.onClick), for: UIControlEvents.touchUpInside)
        btnLike.addTarget(self, action: #selector(ViewController.onLike), for: UIControlEvents.touchUpInside)
    
        btnPre.addTarget(self, action: #selector(ViewController.onPre), for: UIControlEvents.touchUpInside)
    }
    
    func NetworkStatusListener() {
        // 1、设置网络状态消息监听 2、获得网络Reachability对象
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged),name: ReachabilityChangedNotification,object: reachability)
        do{
            // 3、开启网络状态消息监听
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
    }
    /******************* 网络状态监听部分（开始）*******************/
    // 移除消息通知
    deinit {
        // 关闭网络状态消息监听
        reachability.stopNotifier()
        // 移除网络状态消息通知
        NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: reachability)
    }
    
    // 主动检测网络状态
    func reachabilityChanged(note: NSNotification) {
        
        let reachability = note.object as! Reachability // 准备获取网络连接信息
        
        if reachability.isReachable { // 判断网络连接状态
            print("网络连接：可用")
            if reachability.isReachableViaWiFi { // 判断网络连接类型
                print("连接类型：WiFi")
                // strServerInternetAddrss = getHostAddress_WLAN() // 获取主机IP地址 192.168.31.2 小米路由器
                // processClientSocket(strServerInternetAddrss)    // 初始化Socket并连接，还得恢复按钮可用
            } else {
                print("连接类型：移动网络")
                // getHostAddrss_GPRS()  // 通过外网获取主机IP地址，并且初始化Socket并建立连接
                DispatchQueue.main.async { // 不加这句导致界面还没初始化完成就打开警告框，这样不行
                    self.alert_Netwrok() // 警告框，提示网络情况
                }
            }
        } else {
            print("网络连接：不可用")
            DispatchQueue.main.async { // 不加这句导致界面还没初始化完成就打开警告框，这样不行
                self.alert_noNetwrok() // 警告框，提示没有网络
            }
        }
    }
    
    // 警告框，提示没有连接网络 *********************
    func alert_noNetwrok() -> Void {
        let alert = UIAlertController(title: "系统提示", message: "网络错误，请检查网络连接！", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "网络设置", style: .cancel, handler: {
            action in
            let settingUrl = URL(string: "app-Prefs:root=WIFI")!
            if UIApplication.shared.canOpenURL(settingUrl)
            {
                UIApplication.shared.open(settingUrl, options: [:], completionHandler: {
                    (success) in
                    if(success){
                        //跳转成功
                        print("success")
                    }
                })
            }
        })
        let okAction = UIAlertAction(title: "退出", style: .default, handler: {
            action in
            exit(0)
        })
        
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func alert_Netwrok() -> Void {
        let alert = UIAlertController(title: "系统提示", message: "当前正在使用流量，建议在WI-FI下播放音乐。", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "确定", style: .default, handler: nil)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }

    
    /******************* 网络状态监听部分（结束）*******************/
    
    
    
    //界面数据加载
    func loadData(){
        //重新旋转
        iv.onRotation()
        //print(songData)
        let albumtitle = songData[0]["title"].string!
        //let title = songData[0]["title"].string
        //获取歌手名字
        let name = songData[0]["artist"].string!
        songLabel.text = albumtitle
        singerLabel.text = name
        //获取图片地址
        let imgUrl = songData[0]["picture"].string!
        //设置封面和背景
        onSetImage(url: imgUrl)
        //获取音乐地址
        let songUrl:String = songData[0]["url"].string!
        //播放音乐
        onSetAudio(url: songUrl)
    }
    
    func onPre(btn:UIButton){
        //点击上一首
        if songCache.count > 0 && currentIndex > 0 {
            songData[0] = songCache[currentIndex - 1]
            currentIndex -= 1
            loadData()
            //like处理
            //获取数据库是否存在该歌曲
            if songManage.isExist(sid: songData[0]["sid"].int32Value) {
                //增加Like颜色
                btnLike.onLike(isLike:true)
            }else{
                //去除Like颜色
                btnLike.onLike(isLike:false)
            }
        }else{
            alert(msg: "已是第一首歌曲！")
        }
    }
    
    func onLike(btn:LikeButton){
        //点击喜欢
        if btn.isLike {
            songManage.insert(songData: songData)
        }else{
            let alertController = UIAlertController(title: "确定从我喜欢中删除这首歌曲？", message: nil, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: {
                action in
                self.btnLike.onLike(isLike: true)
            })
            let okAction = UIAlertAction(title: "好的", style: .default, handler: {
                action in
                let sid = self.songData[0]["sid"].int32Value
                self.songManage.delete(sid: sid)
            })
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            //弹出提示框
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func onClick(btn:UIButton){
        //是否为当前缓存中最后一首
        if currentIndex == songCache.count - 1 {
            let url:String = "http://douban.fm/j/mine/playlist?type=n&channel=\(channelId)&from=mainsite";
            eHttp.onSearch(url: url)
        }else{
            songData[0] = songCache[currentIndex + 1]
            currentIndex += 1
            loadData()
        }
        //获取数据库是否存在该歌曲
        if(songData.count > 0){
            if songManage.isExist(sid: songData[0]["sid"].int32Value) {
                //增加Like颜色
                btnLike.onLike(isLike:true)
            }else{
                //去除Like颜色
                btnLike.onLike(isLike:false)
            }
        }
        
    }
    //下一首歌曲
    func onSearch(){
        //获取歌曲名字
        if(songData.count > 0){
            loadData()
            currentIndex += 1
            songCache.append(songData[0])
        }
    }
    
    func onPlay(btn:EkoButton){
        if btn.isPlay{
            audioPlayer.play()
            iv.onRotation()
        }else{
            audioPlayer.pause()
            iv.onPause()
            //后台播放显示进度停止
            setInfoCenterCredentials(playbackState:0)
        }
    }

    //设置歌曲封面和背景
    func onSetImage(url:String){
        onGetCacheImage(url: url, imgView: self.iv)
        onGetCacheImage(url: url, imgView: self.bg)
    }
    //播放音乐方法
    func onSetAudio(url:String){
        self.audioPlayer.stop()
        self.audioPlayer.contentURL = NSURL(string:url)! as URL
        self.audioPlayer.play()
        
        btnPlay.onPlay()
        
        //停止计时器
        timer?.invalidate()
        //计时器归零
        playTime.text="00:00"
        //启动计时器
        timer = Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(ViewController.onUpdate), userInfo: nil, repeats: true)
    }
    //计时器更新方法
    func onUpdate(){
        //获取播放器当前播放时间
        let c = audioPlayer.currentPlaybackTime
        if c>0.0 {
            
            //歌曲总时间
            let t = audioPlayer.duration
            //计算百分比
            let pro:CGFloat = CGFloat(c/t)
            
            //按百分比显示进度条宽度
            progress.frame.size.width = view.frame.size.width * pro
            
            //格式转换 00:00
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
                time += "0\(m)"
            }else{
                time += "\(m)"
            }
            //更新播放时间
            playTime.text = time
            //设置后台播放显示信息
            self.setInfoCenterCredentials(playbackState:1)
            if c == t {
                //播放结束，归0，播放下一曲
                onClick(btn: btnNext)
            }
        }
    }
    
    //图片缓存方法
    func onGetCacheImage(url:String,imgView:UIImageView){
        //通过图片地址去缓存图片
        let image = self.imageCache[url] as UIImage?
        if image == nil {
            //如果没油图片，就通过网络获取
            Alamofire.request(url).response{(DataResponse) in
                //将获取的数据赋值到imgView
                let img = UIImage(data: DataResponse.data!)
                imgView.image = img
                
                self.imageCache[url] = img
            }
        }else{
            //如果缓存中又，就直接用
            imgView.image = image!
        }
    }
    
    func didRecieveResults(results: AnyObject) {
        let json = JSON(results)
        //判断是否是频道数据
        if let channels = json["channels"].array {
            self.channelData = channels
        }else if let song = json["song"].array {
            if song.count > 0 {
                self.songData = song
                //数据更新
                onSearch()
            }else{
                alert(msg:"该频道没有歌曲！")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //获取跳转目标
        let channelC:ChannelViewController = segue.destination as! ChannelViewController
        //设置代理
        channelC.delegate = self
        //传输当前频道列表数据
        channelC.channelData = self.channelData
    }
    
    //频道列表协议的回调方法
    func onChangeChannel(channel_id: String,channelName:String) {
        //初始化缓存
        songCache = []
        currentIndex = -1
        //拼接URL
        channelId = channel_id
        //设置频道名字
        channelNameLabel.text = channelName
        if channel_id == "0" {
            //获取like列表 并缓存
            songCache = songManage.fetch()
            if songCache.count > 0 {
                //当前缓存有数据就初始化
                songData[0] = songCache[0]
                currentIndex = -1
                onSearch()
                btnLike.onLike(isLike: true)
            }else{
                let url:String = "http://douban.fm/j/mine/playlist?type=n&channel=\(channel_id)&from=mainsite"
                eHttp.onSearch(url:url)
                //去除Like颜色
                btnLike.onLike(isLike:false)
            }
            
        }else{
            let url:String = "http://douban.fm/j/mine/playlist?type=n&channel=\(channel_id)&from=mainsite"
            eHttp.onSearch(url:url)
            //去除Like颜色
            btnLike.onLike(isLike:false)
        }
        
    }
    
    //页面显示添加通知监听
    override func viewWillAppear(_ animated: Bool) {
        //告诉系统接受远程响应事件，并注册成为第一响应者
        UIApplication.shared.beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()
    }
    
    //页面消失时取消歌曲播放结束通知监听
    override func viewWillDisappear(_ animated: Bool) {
        //停止接受远程响应事件
        UIApplication.shared.endReceivingRemoteControlEvents()
        self.resignFirstResponder()
    }
    
    //是否能成为第一响应对象
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    // 设置后台播放显示信息
    func setInfoCenterCredentials(playbackState: Int) {
        let mpic = MPNowPlayingInfoCenter.default()
        
        //获取当前播放数据
        let albumtitle = songData[0]["title"].string!
        let name = songData[0]["artist"].string!
        let imgUrl = songData[0]["picture"].string
        //let songUrl:String = songData[0]["url"].string!
        
        //专辑封面
        let mySize = CGSize(width: 400, height: 400)
        //通过图片地址去缓存图片
        let image = self.imageCache[imgUrl!] as UIImage?
        var albumArt = MPMediaItemArtwork(boundsSize:mySize) { sz in
            return UIImage(named: "ghost")!
        }
        if image == nil {
            //如果没油图片，就通过网络获取
            Alamofire.request(imgUrl!).response{(DataResponse) in
                //将获取的数据赋值到imgView
                let img = UIImage(data: DataResponse.data!)
                self.imageCache[imgUrl!] = img
                albumArt = MPMediaItemArtwork(boundsSize:mySize) { sz in
                    return UIImage(data:DataResponse.data!)!
                }
            }
        }else{
            albumArt = MPMediaItemArtwork(boundsSize:mySize) { sz in
                return (image)!
            }
        }

        //获取进度
        let postion = audioPlayer.currentPlaybackTime
        let duration = audioPlayer.duration
        
        mpic.nowPlayingInfo = [MPMediaItemPropertyTitle: albumtitle,
                               MPMediaItemPropertyArtist: name,
                               MPMediaItemPropertyArtwork: albumArt,
                               MPNowPlayingInfoPropertyElapsedPlaybackTime: postion,
                               MPMediaItemPropertyPlaybackDuration: duration,
                               MPNowPlayingInfoPropertyPlaybackRate: playbackState]
    }
    
    //后台操作
    override func remoteControlReceived(with event: UIEvent?) {
        guard let event = event else {
            print("no event\n")
            return
        }
        
        if event.type == UIEventType.remoteControl {
            switch event.subtype {
            case .remoteControlTogglePlayPause:
                //暂停／播放
                break
            case .remoteControlPreviousTrack:
                //上一首
                onPre(btn: btnPre)
                break
            case .remoteControlNextTrack:
                //下一首
                onClick(btn: btnNext)
                setInfoCenterCredentials(playbackState: 1)
                break
            case .remoteControlPlay:
                //播放
                audioPlayer.play()
                iv.onRotation()
            case .remoteControlPause:
                //暂停
                audioPlayer.pause()
                iv.onPause()
                //后台播放显示信息进度停止
                setInfoCenterCredentials(playbackState: 0)
            default:
                break
            }
        }
    }
    
    func alert(msg:String){
        let alertController = UIAlertController(title: msg, message: nil, preferredStyle: .alert)
        //显示提示框
        self.present(alertController, animated: true, completion: nil)
        //两秒钟后自动消失
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.presentedViewController?.dismiss(animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

