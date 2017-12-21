//
//  Service.swift
//  BraviIOS
//
//  Created by Gustavo Belo Brilhante on 18/12/17.
//  Copyright © 2017 Gustavo. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireRSSParser
import RxSwift

class Service {
    
    class func makeRssRequest(url:String) -> Observable<RSSFeed>{
        return Observable.create{ observer in
            Alamofire.request(url).responseRSS { (response) in
                if(response.result.isSuccess){
                    observer.onNext(response.result.value!)
                    observer.onCompleted()
                }else{
                    observer.onError(response.error!)
                }
            }
            
            return Disposables.create()
        }
    }
    
}
