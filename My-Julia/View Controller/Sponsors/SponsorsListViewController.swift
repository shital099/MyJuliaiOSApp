//
//  SponsorsListViewController.swift
//  My-Julia
//
//  Created by GCO on 4/19/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

class SponsorsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var tableViewObj: UITableView!

    var sponsorarray:[Sponsors] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Show menu icon in ipad and iphone
        self.setupMenuBarButtonItems()
        
        //        if IS_IPHONE {
        //            self.setupMenuBarButtonItems()
        //        }
        
        //apply application theme on screen
        CommonModel.sharedInstance.applyThemeOnScreen(viewController: self, bgImage: bgImageView)
        
        //Set separator color according to background color
        CommonModel.sharedInstance.applyTableSeperatorColor(object: tableViewObj)
        
        //Remove extra lines from tableview
        tableViewObj.tableFooterView = UIView()

        //Fetch data from Sqlite database
        self.sponsorarray = DBManager.sharedInstance.fetchSponsorsDataFromDB() as! [Sponsors]
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        CommonModel.sharedInstance.animateTable(tableView : self.tableViewObj)
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation UIBarButtonItems
    func setupMenuBarButtonItems() {
        
        // self.navigationItem.rightBarButtonItem = self.rightMenuBarButtonItem()
        let barItem = CommonModel.sharedInstance.leftMenuBarButtonItem()
        barItem.target = self;
        barItem.action = #selector(self.leftSideMenuButtonPressed(sender:))
        self.navigationItem.leftBarButtonItem = barItem
    }
    
    // MARK: - Navigation UIBarButtonItems
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sponsorarray.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath) as! SponsorsCustomCell
        cell.backgroundColor = cell.contentView.backgroundColor;

        let sponsor: Sponsors
        sponsor = sponsorarray[indexPath.row]

        cell.nameLabel!.text = sponsor.name
        //SDImageCache.shared().removeImage(forKey: sponsor.iconUrl, withCompletion: nil)
        cell.imageview.sd_setImage(with: NSURL(string:sponsor.iconUrl) as URL?, placeholderImage: #imageLiteral(resourceName: "empty_sponsors"))

        return cell
    }
    
    // MARK: - UITableView Delegate Methods

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        let row = indexPath.row
        let viewController = storyboard?.instantiateViewController(withIdentifier: "SponsorDetailsViewController") as! SponsorDetailsViewController
        viewController.sponsorModel = self.sponsorarray[indexPath.row]
        
        self.navigationController?.pushViewController(viewController, animated: true)
        print(sponsorarray[row])
    }
}

// MARK: - Custom Cell Classes

class SponsorsCustomCell: UITableViewCell {
    
    @IBOutlet var nameLabel:UILabel!
    @IBOutlet var imageview:UIImageView!
    
}

