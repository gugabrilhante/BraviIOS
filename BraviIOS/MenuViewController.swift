//
//  MenuViewController.swift
//  AKSwiftSlideMenu
//
//  Created by Ashish on 21/09/15.
//  Copyright (c) 2015 Kode. All rights reserved.
//

import UIKit
import AlamofireRSSParser
import SDWebImage

protocol SlideMenuDelegate {
    func slideMenuItemSelectedAtIndex(_ index : Int32)
    func refreshData()
}

class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var rssItens = [RSSItemRealm]()
    
    private var refreshControl : UIRefreshControl!
    
    /**
    *  Array to display menu options
    */
    @IBOutlet var tblMenuOptions : UITableView!
    
    /**
    *  Transparent button to hide menu
    */
    @IBOutlet var btnCloseMenuOverlay : UIButton!
    
    /**
    *  Array containing menu options
    */
    var arrayMenuOptions = [Dictionary<String,String>]()
    
    /**
    *  Menu button which was tapped to display the menu
    */
    var btnMenu : UIButton!
    
    /**
    *  Delegate of the MenuVC
    */
    var delegate : SlideMenuDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblMenuOptions.tableFooterView = UIView()
        
        self.refreshControl = UIRefreshControl()
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            tblMenuOptions.refreshControl = refreshControl
        } else {
            tblMenuOptions.addSubview(refreshControl)
        }
        // Configure Refresh Control
        refreshControl.addTarget(self, action: #selector(refreshWeatherData(_:)), for: .valueChanged)

        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateArrayMenuOptions()
    }
    
    func updateArrayMenuOptions(){
//        arrayMenuOptions.append(["title":"Home", "icon":"HomeIcon"])
//        arrayMenuOptions.append(["title":"Play", "icon":"PlayIcon"])
        
        for item in self.rssItens{
            let dict = Rss.itemToDictionary(item: item)
            arrayMenuOptions.append(dict)
        }
        
        tblMenuOptions.reloadData()
    }
    
    @IBAction func onCloseMenuClick(_ button:UIButton!){
        btnMenu.tag = 0
        
        if (self.delegate != nil) {
            var index = (button.tag)
            if(button == self.btnCloseMenuOverlay){
                index = -1
            }
            delegate?.slideMenuItemSelectedAtIndex(Int32(index))
        }
        
        closeMenu()
    }
    
    func closeMenu(){
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.view.frame = CGRect(x: -UIScreen.main.bounds.size.width, y: 0, width: UIScreen.main.bounds.size.width,height: UIScreen.main.bounds.size.height)
            self.view.layoutIfNeeded()
            self.view.backgroundColor = UIColor.clear
        }, completion: { (finished) -> Void in
            self.view.removeFromSuperview()
            self.removeFromParentViewController()
        })
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cellMenu")!
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.layoutMargins = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
        cell.backgroundColor = UIColor.clear
        
        let lblTitle : UILabel = cell.contentView.viewWithTag(101) as! UILabel
        let lblDescription : UILabel = cell.contentView.viewWithTag(102) as! UILabel
        let lblDate : UILabel = cell.contentView.viewWithTag(103) as! UILabel
        let imgIcon : UIImageView = cell.contentView.viewWithTag(100) as! UIImageView
        
//        imgIcon.image = UIImage(named: arrayMenuOptions[indexPath.row]["icon"]!)
        if let url = arrayMenuOptions[indexPath.row]["icon"]{
            imgIcon.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "HomeIcon"))
        }
        
        if let title = arrayMenuOptions[indexPath.row]["title"]{
            lblTitle.text = title
        }
        if let description = arrayMenuOptions[indexPath.row]["description"]{
            lblDescription.text = description
        }
        if let date = arrayMenuOptions[indexPath.row]["date"]{
            lblDate.text = date
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let btn = UIButton(type: UIButtonType.custom)
        btn.tag = indexPath.row
        self.onCloseMenuClick(btn)
        self.delegate!.slideMenuItemSelectedAtIndex(Int32(indexPath.row))
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayMenuOptions.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    @objc private func refreshWeatherData(_ sender: Any) {
        // Fetch Weather Data
        self.delegate?.refreshData()
    }
    
    func stopRefreshing(){
        self.refreshControl.endRefreshing()
    }
    
}
