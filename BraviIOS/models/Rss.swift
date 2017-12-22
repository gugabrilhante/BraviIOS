//
//  Rss.swift
//  BraviIOS
//
//  Created by Gustavo Belo Brilhante on 19/12/17.
//  Copyright © 2017 Gustavo. All rights reserved.
//

import Foundation
import AlamofireRSSParser

class Rss: NSObject{
    
    class func itemToDictionary(item:RSSItemRealm) -> [String:String]{
        var dict = [String:String]()
        if((item.title) != nil){
            dict["title"] = item.title!
        }
        if let description = item.itemDescription{
            dict["description"] = description
        }
        if let date = item.pubDate{
            dict["date"] = date.toString(dateFormat: "dd/MM/yyyy")
        }
        if((item.mediaContent) != nil){
            dict["icon"] = item.mediaContent!
        }
        return dict
    }
    

    
}
