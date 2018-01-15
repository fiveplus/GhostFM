//
//  ChannelViewController.swift
//  DBFM
//
//  Created by 张珅旿 on 2017/8/22.
//  Copyright © 2017年 张珅旿. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

protocol ChannelProtocol {
    //回调方法，频道ID传回到代理中
    func onChangeChannel(channel_id:String,channelName:String)
}

class ChannelViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,HttpProtocol {
    //频道列表tableview组件
    @IBOutlet weak var tv: UITableView!
    //返回按钮
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var channelTableView: UITableView!
    
    //申明代理
    var delegate:ChannelProtocol?
    //网络操作类实例
    var eHttp:HttpController = HttpController()
    
    let channelUrl:String = "http://www.douban.com/j/app/radio/channels"
    //频道列表数据
    var channelData:[JSON] = []
    
    override func viewWillAppear(_ animated: Bool) {
        //视图加载完成 尚未显示
        print(channelData.count)
        if channelData.count == 0{
            //获取频道
            eHttp.onSearch(url:channelUrl)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.alpha = 0.8
        btnBack.addTarget(self, action: #selector(ChannelViewController.onBack), for: UIControlEvents.touchUpInside)
        
        //为网络操作类设置代理
        eHttp.delegate = self
    }
    
    func onBack(btn:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    //配置tableview数据的行数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channelData.count
    }
    //配置tableview单元格cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tv.dequeueReusableCell(withIdentifier: "channel")!
        let rowData:JSON = self.channelData[indexPath.row] as JSON
        //设置cell标题
        cell.textLabel?.text = rowData["name"].string
        return cell
    }
    //选中数据
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //获取行数据
        let rowData:JSON = self.channelData[indexPath.row] as JSON
        //获取选中行的频道ID
        let channel_id:String = rowData["channel_id"].stringValue
        let channelName:String = rowData["name"].stringValue
        //将频道ID反向传递到主界面
        delegate?.onChangeChannel(channel_id: channel_id,channelName:channelName)
        //关闭当前界面
        self.dismiss(animated: true,completion: nil)
    }
    
    func didRecieveResults(results: AnyObject) {
        let json = JSON(results)
        //判断是否是频道数据
        if let channels = json["channels"].array {
            self.channelData = channels
            self.channelTableView.reloadData()
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    

    
}
