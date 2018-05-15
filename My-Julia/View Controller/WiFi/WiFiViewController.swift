//
//  WiFiViewController.swift
//  My-Julia
//
//  Created by GCO on 24/04/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

class WiFiViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var wifiArray : NSMutableArray = []

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bgImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Setup delegates */
        tableView.delegate = self
        tableView.dataSource = self
        
        //Remove extra lines from tableview
        tableView.tableFooterView = UIView()

        //Show menu icon in ipad and iphone
        self.setupMenuBarButtonItems()
        
        //        if IS_IPHONE {
        //            self.setupMenuBarButtonItems()
        //        }

        
        //apply application theme on screen
        CommonModel.sharedInstance.applyThemeOnScreen(viewController: self, bgImage: bgImageView)
        
        //Set separator color according to background color
        CommonModel.sharedInstance.applyTableSeperatorColor(object: tableView)

        //Fetch data from Sqlite database
        self.wifiArray = DBManager.sharedInstance.fetchWifiDataFromDB().mutableCopy() as! NSMutableArray
    }

    // MARK: - Navigation UIBarButtonItems
    
    func setupMenuBarButtonItems() {
        // self.navigationItem.rightBarButtonItem = self.rightMenuBarButtonItem()
        let barItem = CommonModel.sharedInstance.leftMenuBarButtonItem()
        barItem.target = self;
        barItem.action = #selector(self.leftSideMenuButtonPressed(sender:))
        self.navigationItem.leftBarButtonItem = barItem
    }
    
    @objc func leftSideMenuButtonPressed(sender: UIBarButtonItem) {
        let masterVC : UIViewController!
        if IS_IPHONE {
            masterVC =  self.menuContainerViewController.leftMenuViewController as! MenuViewController?
        }
        else {
            masterVC = self.splitViewController?.viewControllers.first
        }
        
        if ((masterVC as? MenuViewController) != nil) {
            (masterVC as! MenuViewController).toggleLeftSplitMenuController()
        }
    }
    
    // MARK: - UITableView Delegate Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wifiArray.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath) as! WiFiCustomCell
        cell.backgroundColor = cell.contentView.backgroundColor;

        let wifi = wifiArray[indexPath.row] as! WiFiModel
        cell.nameLabel!.text = wifi.name
        cell.statusImageview.isHidden  = wifi.isRead
        return cell
    }
    
    // MARK: - UITableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let model = self.wifiArray[indexPath.row] as! WiFiModel
        //Update notification read/unread message count in side menu bar
        let dataDict:[String: Any] = ["Order": self.view.tag, "Flag":Update_WiFi_List]
        DBManager.sharedInstance.updateWiFiDataStatus(wifiId: model.id)
        NotificationCenter.default.post(name: UpdateNotificationCount, object: nil, userInfo: dataDict)

        model.isRead = true
        self.wifiArray.replaceObject(at: indexPath.row, with: model)
        self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)

        let viewController = storyboard?.instantiateViewController(withIdentifier: "WiFiDetailsViewController") as! WiFiDetailsViewController
        viewController.wifiModel = model
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: - Custom Cell Classes

class WiFiCustomCell: UITableViewCell {
    
    @IBOutlet var nameLabel:UILabel!
    @IBOutlet var statusImageview:UIImageView!
    
}
