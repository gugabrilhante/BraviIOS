//
//  RSSItemRealm.swift
//  BraviIOS
//
//  Created by Gustavo Belo Brilhante on 21/12/17.
//  Copyright © 2017 Gustavo. All rights reserved.
//

import Foundation
import RealmSwift
import Realm
import AlamofireRSSParser
import RxSwift
import RxCocoa

class RSSItemRealm: Object{
    
    @objc dynamic var title: String? = nil
    @objc dynamic var itemDescription: String? = nil
    @objc dynamic var mediaContent: String? = nil
    @objc dynamic var pubDate: Date? = nil
    
    func setValues(item: RSSItem) {
        self.title           = item.title
        self.itemDescription = item.itemDescription
        self.mediaContent    = item.mediaContent
        self.pubDate         = item.pubDate
    }
    
    class func mapToRealmObject(itemList:[RSSItem]) -> [RSSItemRealm]{
        let itemRealmList = itemList.map { (item) -> RSSItemRealm in
            let itemRealm = RSSItemRealm()
            itemRealm.setValues(item: item)
            return itemRealm
        }
        return itemRealmList
    }
    
    /*class func mapToItemObject(itemList:[RSSItemRealm]) -> [RSSItem]{
        let itemRealmList = itemList.map { (itemRealm) -> RSSItem in
            let item = RSSItem()
            item.title = itemRealm.title
            item.content = itemRealm.content
            item.itemDescription = itemRealm.itemDescription
            item.pubDate = itemRealm.pubDate
            return item
        }
        return itemRealmList
    }*/
    
    class func writeListObservable(listRealm:[RSSItemRealm]) -> Observable<Bool>{
        return Observable.create{ observer in
            
            do{
                let realm = try! Realm()
                try! realm.write {
                    realm.deleteAll()
                    realm.add(listRealm)
                }
                observer.onNext(true)
                observer.onCompleted()
            
            } catch let error as NSError {
                observer.onError(error)
            }
            
            return Disposables.create()
        }
    }
    
    class func readListObservable() -> Observable<[RSSItemRealm]>{
        return Observable.create{ observer in
            
            do{
                let realm = try! Realm()
                
                let itens = realm.objects(RSSItemRealm.self)
                var list = [RSSItemRealm]()
                for item in itens {
                    list.append(item)
                }
                observer.onNext(list)
                observer.onCompleted()
                
            } catch let error as NSError {
                observer.onError(error)
            }
            
            return Disposables.create()
        }
    }
    
}
