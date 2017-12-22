//
//  ViewController.swift
//  BraviIOS
//
//  Created by Gustavo Belo Brilhante on 18/12/17.
//  Copyright © 2017 Gustavo. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireRSSParser
import RxSwift
import RxCocoa
import SDWebImage
import MBProgressHUD

class ViewController: BaseViewController, SlideMenuDelegate {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    
    var url:String = "http://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml"
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
    var progressHUD:MBProgressHUD?
    
    var searchHeight:CGFloat?
    @IBOutlet weak var searchHeightConstrant: NSLayoutConstraint!
    
    var viewCollapsed:Bool! = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.delegate = self
        
        self.searchHeight = searchHeightConstrant.constant
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "URL", style: .done, target: self, action: #selector(ViewController.setUrlAction))

        self.searchTextField.text = self.url
        
        self.readFromRealm()
        
//        self.loadRss();
        
        /*Alamofire.request("http://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml").responseRSS { (response) in
            if let rssFeedXML = response.result.value {
                // Successful response - process the feed in your completion handler
//                completionHandler(rssFeedXML, .success)
                print(rssFeedXML.items)
                self.addSlideMenuButton(rssItens: rssFeedXML.items)
                if(rssFeedXML.items.count > 0){
                    let dict = Rss.itemToDictionary(item: rssFeedXML.items[0])
                    self.setDataToViews(dict: dict)
                }
            } else {
                // There was an error, so feel free to handle it in your completion handler
//                completionHandler(nil, .error(string: response.result.error?.localizedDescription))
            }
        }*/
    
        
    
        
    }
    
    func readFromRealm(){
        RSSItemRealm.readListObservable()
            .observeOn(CurrentThreadScheduler.instance)
            .subscribeOn(MainScheduler.instance)
            .subscribe(
            onNext: { (itensRealm:[RSSItemRealm]) in
                if(itensRealm.count > 0){
                    self.addSlideMenuButton(rssItens: itensRealm)
                    let dict = Rss.itemToDictionary(item: itensRealm[0])
                    self.setDataToViews(dict: dict)
                }
            },
            onError: {(error) in
                
            },
            onCompleted: {
                
            },
            onDisposed: {
                print("Disposed")
            });
        
    }
    
    func writeToRealm(list:[RSSItemRealm]){
        RSSItemRealm.writeListObservable(listRealm: list)
            .observeOn(CurrentThreadScheduler.instance)
            .subscribeOn(MainScheduler.instance)
            .subscribe(
            onNext: { (success) in
                    
            },
            onError: {(error) in
                
            },
            onCompleted: {
                
            });
        
    }
    
    
    func loadRss(isRefresh:Bool){
        self.progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        progressHUD?.label.text = "Baixando notícias"
        Service.makeRssRequest(url: self.url)
            .observeOn(CurrentThreadScheduler.instance)
            .subscribeOn(MainScheduler.instance)
            .subscribe(
                onNext:{(rssFeed) in
                    if(rssFeed.items.count > 0){
                        let itensRealm = RSSItemRealm.mapToRealmObject(itemList: rssFeed.items)
                        self.addSlideMenuButton(rssItens: itensRealm)
                        let dict = Rss.itemToDictionary(item: itensRealm[0])
                        self.setDataToViews(dict: dict)
                        self.writeToRealm(list: itensRealm)
                        if(isRefresh){
                            self.stopRefreshing()
                        }
                    }
                    print("Next")
                },
                onError:{(error) in
                    self.setErrorToViews()
                    print(error)
                    print("Error")
                },
                onCompleted:{
                    print("Completed")
                    self.progressHUD?.hide(animated: true)
                    
                },
                onDisposed: {
                    print("Disposed")
                    self.progressHUD?.hide(animated: true)
                }
            );
    }
    
    func refreshData(){
        loadRss(isRefresh: true);
    }
    
    func setErrorToViews(){
        self.lblTitle.text = "Ocorreu algum erro ao baixar as notícias."
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    func setDataToViews(dict:[String:String]){
        if(self.viewCollapsed){
            self.setUrlAction()
        }
        if let url = dict["icon"]{
            imageView.isHidden = false
            imageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "HomeIcon"))
        }else{
            imageView.isHidden = true
        }
        
        if let title = dict["title"]{
            lblTitle.text = title
        }
        if let description = dict["description"]{
            lblDescription.text = description
        }
        if let date = dict["date"]{
            lblDate.text = date
        
        }
    }
    
    @IBAction func searchButtonAction(_ sender: UIButton) {
        self.url = self.searchTextField.text!
        self.loadRss(isRefresh: false)
    }
    
    @objc func setUrlAction() {
        if(self.viewCollapsed){
            UIView.animate(withDuration: 0.3, animations: {
                self.searchHeightConstrant.constant = 0;
                self.searchTextField.alpha = 0;
                self.searchButton.alpha = 0;
                self.view.layoutIfNeeded()
                
            },completion: { (finished) in
                self.viewCollapsed = false
            })
        }else{
            UIView.animate(withDuration: 0.3, animations: {
                self.searchHeightConstrant.constant = self.searchHeight!;
                self.searchTextField.alpha = 1;
                self.searchButton.alpha = 1;
                self.view.layoutIfNeeded()
            },completion: { (finished) in
                self.viewCollapsed = true
            })
        }
    }
    
    func slideMenuItemSelectedAtIndex(_ index: Int32) {
        if(index>=0){
            let dict = Rss.itemToDictionary(item: super.rssItens[Int(index)])
            self.setDataToViews(dict: dict)
            if(self.viewCollapsed){
                self.setUrlAction()
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

