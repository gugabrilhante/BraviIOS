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

class ViewController: BaseViewController, SlideMenuDelegate {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    
    var url:String = "http://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml"
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
    
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
    
    func loadRss(){
        Service.makeRssRequest(url: self.url)
            .observeOn(CurrentThreadScheduler.instance)
            .subscribeOn(MainScheduler.instance)
            .subscribe(
                onNext:{(rssFeed) in
                    self.addSlideMenuButton(rssItens: rssFeed.items)
                    if(rssFeed.items.count > 0){
                        let dict = Rss.itemToDictionary(item: rssFeed.items[0])
                        self.setDataToViews(dict: dict)
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
                    
                },
                onDisposed: {
                    print("Disposed")
                }
            );
    }
    
    func setErrorToViews(){
        self.lblTitle.text = "Ocorreu algum erro ao baixar as notícias."
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
        self.loadRss()
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

