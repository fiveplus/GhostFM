//
//  HttpController.swift
//  DBFM
//
//  Created by 张珅旿 on 2017/8/22.
//  Copyright © 2017年 张珅旿. All rights reserved.
//

import UIKit
import Alamofire
class HttpController: NSObject {
    //定义一个代理
    var delegate:HttpProtocol?
    //接收网址，回调代理方法传回数据
    func onSearch(url:String){
        Alamofire.request(url).responseJSON{(DataResponse) in
            //如果没有出现异常
            if DataResponse.error == nil {
                self.delegate?.didRecieveResults(results: DataResponse.result.value as AnyObject)
            }
        }
    }
}
//定义http协议
protocol HttpProtocol{
    //定义一个方法，接收一个参数：AnyObject
    func didRecieveResults(results:AnyObject)
}
