//
//  SongManage.swift
//  DBFM
//
//  Created by 张珅旿 on 2017/8/25.
//  Copyright © 2017年 张珅旿. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON
class SongManage{
    var delegate:AppDelegate? = nil
    init(delegate:AppDelegate) {
        self.delegate = delegate
    }
    func insert(songData:[JSON]){
        let song = NSEntityDescription.insertNewObject(forEntityName: "Song", into: (delegate?.persistentContainer.viewContext)!) as! Song
        //查询id是否存在
        let sid = songData[0]["sid"].int32Value
        if !isExist(sid: sid) {
            song.sid = sid
            song.albumtitle = songData[0]["albumtitle"].stringValue
            song.artist = songData[0]["artist"].stringValue
            song.url = songData[0]["url"].stringValue
            song.title = songData[0]["title"].stringValue
            song.picture = songData[0]["picture"].stringValue
            delegate?.saveContext()
        }
    }
    func delete(sid:Int32){
        let request:NSFetchRequest<Song> = Song.fetchRequest()
        let entity = NSEntityDescription.entity(forEntityName: "Song", in: (delegate?.persistentContainer.viewContext)!)
        request.entity = entity
        let arr = try! delegate?.persistentContainer.viewContext.fetch(request)
        for song in arr! {
            if song.sid == sid {
                //print("delete OK")
                delegate?.persistentContainer.viewContext.delete(song)
                try! delegate?.persistentContainer.viewContext.save()
                break
            }
        }
    }
    //查询所有数据
    func fetch() -> [JSON]{
        let request:NSFetchRequest<Song> = Song.fetchRequest()
        let entity = NSEntityDescription.entity(forEntityName: "Song", in: (delegate?.persistentContainer.viewContext)!)
        request.entity = entity
        let arr  = try! delegate?.persistentContainer.viewContext.fetch(request)
        var songDatas:[JSON] = []
        for song in arr! {
            var sarr:Dictionary<String,String> = [:]
            sarr["albumtitle"] = song.albumtitle!
            sarr["title"] = song.title!
            sarr["url"] = song.url!
            sarr["sid"] = String(song.sid)
            sarr["artist"] = song.artist!
            sarr["picture"] = song.picture!
            songDatas.append(JSON(sarr))
        }
        
        return songDatas
    }
    //判断是否存在数据
    func isExist(sid:Int32) -> Bool{
        var flag:Bool = false
        let request:NSFetchRequest<Song> = Song.fetchRequest()
        let entity = NSEntityDescription.entity(forEntityName: "Song", in: (delegate?.persistentContainer.viewContext)!)
        request.entity = entity
        let arr = try! delegate?.persistentContainer.viewContext.fetch(request)
        for song in arr! {
            if song.sid == sid {
                flag = true
                break
            }
        }
        return flag
    }
    
}
