//
//  MapViewController.swift
//  My-Julia
//
//  Created by GCO on 24/04/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

class MapViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bgImageView: UIImageView!

    var listArray : NSMutableArray = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Setup delegates */
        tableView.delegate = self
        tableView.dataSource = self

        //Show menu icon in ipad and iphone
        self.setupMenuBarButtonItems()
        
        //        if IS_IPHONE {
        //            self.setupMenuBarButtonItems()
        //        }
        
        //apply application theme on screen
        CommonModel.sharedInstance.applyThemeOnScreen(viewController: self, bgImage: bgImageView)
        
        //Set separator color according to background color
        CommonModel.sharedInstance.applyTableSeperatorColor(object: tableView)

        //Remove extra lines from tableview
        tableView.tableFooterView = UIView()

        //Fetch data from Sqlite database
        listArray = DBManager.sharedInstance.fetchMapDataFromDB().mutableCopy() as! NSMutableArray

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
        return listArray.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath) as! MapCustomCell
        cell.backgroundColor = cell.contentView.backgroundColor;

        let model = self.listArray[indexPath.row] as! Map
        cell.nameLabel?.text = model.name

        cell.statusImageview.isHidden  = model.isRead

        return cell
    }
    
    // MARK: - UITableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)

        let model = self.listArray[indexPath.row] as! Map

        //Update map read status
        DBManager.sharedInstance.updateMapNotificationStatus(mapId: model.id)

        //Update notification read/unread message count in side menu bar
        let dataDict:[String: Any] = ["Order": self.view.tag, "Flag":Update_Map_List]
        NotificationCenter.default.post(name: UpdateNotificationCount, object: nil, userInfo: dataDict)

        model.isRead = true
        self.listArray.replaceObject(at: indexPath.row, with: model)
        self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)

        let nextViewController = storyboard?.instantiateViewController(withIdentifier: "MapDetailsViewController") as! MapDetailsViewController
        nextViewController.nameStr = model.name
        nextViewController.imgStr = model.iconUrl
        nextViewController.mapId = model.id
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - Custom Cell Classes

class MapCustomCell: UITableViewCell {
    
    @IBOutlet var nameLabel:UILabel!
    @IBOutlet var imageview:UIImageView!
    @IBOutlet var statusImageview:UIImageView!

}
