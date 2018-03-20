//
//  EmergencyViewController.swift
//  EventApp
//
//  Created by GCO on 24/04/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

class EmergencyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableviewObj: UITableView!
    @IBOutlet weak var bgImageView: UIImageView!

    var dataArray = [EmergencyModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Show menu icon in ipad and iphone
        self.setupMenuBarButtonItems()
        
        //        if IS_IPHONE {
        //            self.setupMenuBarButtonItems()
        //        }

        
        //apply application theme on screen
        CommonModel.sharedInstance.applyThemeOnScreen(viewController: self, bgImage: bgImageView)
        
        //Fetch data from Sqlite database
        dataArray = DBManager.sharedInstance.fetchEmergencyDataFromDB() as! [EmergencyModel]
        
        //Set separator color according to background color
        CommonModel.sharedInstance.applyTableSeperatorColor(object: tableviewObj)
        
        //Remove extra lines from tableview
        tableviewObj.tableFooterView = UIView()

        //Set separator color according to background color
        CommonModel.sharedInstance.applyTableSeperatorColor(object: tableviewObj)
    
    }
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
            masterVC =  self.menuContainerViewController.leftMenuViewController as! MenuViewController!
        }
        else {
            masterVC = self.splitViewController?.viewControllers.first
        }
        
        if ((masterVC as? MenuViewController) != nil) {
            (masterVC as! MenuViewController).toggleLeftSplitMenuController()
        }
    }
    
    // MARK: - UITableView DataSource Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return dataArray.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIden", for: indexPath) as! EmergencyCustomCell
        cell.backgroundColor = cell.contentView.backgroundColor;

        var model : EmergencyModel
        model = dataArray[indexPath.row];
        cell.titleLabel?.text = model.title
        

        return cell
    }
    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        cell.alpha = 0
//        let transform = CATransform3DTranslate(CATransform3DIdentity, -250, 20, 0)
//        cell.layer.transform = transform
//        UIView.animate(withDuration: 1.0)
//        {
//            cell.alpha = 1.0
//            cell.layer.transform = CATransform3DIdentity
//        }
//    }
    
    // MARK: - UITableViewDelegate Methods
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        let viewController = storyboard?.instantiateViewController(withIdentifier: "EmergencyDetailsViewController") as! EmergencyDetailsViewController
                   viewController.model = self.dataArray[indexPath.row]
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - Custom Cell Classes

class EmergencyCustomCell: UITableViewCell {
    
    @IBOutlet var titleLabel:UILabel!
    
}
