//
//  SpeakersListViewController.swift
//  My-Julia
//
//  Created by GCO on 4/19/17.
//  Copyright © 2017 GCO. All rights reserved.
//Commit checkout

import UIKit


class SpeakersListViewController: UIViewController, UISearchBarDelegate, UISearchResultsUpdating, UITableViewDataSource, UITableViewDelegate {
 
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var tableViewObj: UITableView!

    // MARK: - Properties
    var listArray = [PersonModel]()
    var filteredArray = [PersonModel]()
    let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - View Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        //Show menu icon in ipad and iphone
        self.setupMenuBarButtonItems()
        
        //        if IS_IPHONE {
        //            self.setupMenuBarButtonItems()
        //        }
        
        //apply application theme on screen
        CommonModel.sharedInstance.applyThemeOnScreen(viewController: self, bgImage: bgImageView)

        //Update dyanamic height of tableview cell
        tableViewObj.estimatedRowHeight = 600
        tableViewObj.rowHeight = UITableViewAutomaticDimension

        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        
        //Remove extra lines from tableview
        tableViewObj.tableFooterView = UIView()
        
        // Setup the Scope Bar
        tableViewObj.tableHeaderView = searchController.searchBar
        
        //Set separator color according to background color
        CommonModel.sharedInstance.applyTableSeperatorColor(object: tableViewObj)

        //Fetch data from Sqlite database
        listArray = DBManager.sharedInstance.fetchAllSpeakersDataFromDB() as! [PersonModel]
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      //  CommonModel.sharedInstance.animateTable(tableView : self.tableViewObj)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
            masterVC =  self.menuContainerViewController.leftMenuViewController as! MenuViewController?
        }
        else {
            masterVC = self.splitViewController?.viewControllers.first
        }
        
        if ((masterVC as? MenuViewController) != nil) {
            (masterVC as! MenuViewController).toggleLeftSplitMenuController()
        }
    }
    
    // MARK: - Table View
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredArray.count
        }
        return listArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath) as! SpeakerCustomCell
        cell.backgroundColor = cell.contentView.backgroundColor;

        let speaker: PersonModel
        
        if searchController.isActive && searchController.searchBar.text != "" {
            speaker = filteredArray[indexPath.row]
        } else {
            speaker = listArray[indexPath.row]
        }
        cell.nameLabel!.text = speaker.name
        cell.designationLabel.text = speaker.designation
        cell.statusImg.isHighlighted = speaker.isActiveSpeaker
    
        cell.statusImg.isHighlighted = speaker.isActiveSpeaker == true ? true : false
        if speaker.privacySetting == true && !speaker.iconUrl.isEmpty {
//        if !speaker.iconUrl.isEmpty {
            cell.imageview.sd_setImage(with: URL(string:speaker.iconUrl), placeholderImage: #imageLiteral(resourceName: "user"))
            cell.imageview?.layer.cornerRadius = cell.imageview.frame.size.height/2
            cell.imageview.contentMode = UIViewContentMode.scaleAspectFill
            cell.imageview.clipsToBounds = true
            cell.imageview.layer.borderColor = UIColor.gray.cgColor
            cell.imageview.layer.borderWidth = 1.0
        }
        else {
           cell.imageview.image = #imageLiteral(resourceName: "user")
        }

        return cell
    }

    // MARK: - Search Method
    
    func filterContentForSearchText(_ searchText: String) {
        filteredArray = listArray.filter({( model : PersonModel) -> Bool in
            return model.name.lowercased().contains(searchText.lowercased())
        })
        tableViewObj.reloadData()
    }
    
    // MARK: - UITableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
//        let viewController = storyboard?.instantiateViewController(withIdentifier: "SpeakerDetailsViewController") as! SpeakerDetailsViewController
//        if searchController.isActive && searchController.searchBar.text != "" {
//            viewController.personModel = filteredArray[indexPath.row]
//        } else {
//            viewController.personModel = listArray[indexPath.row]
//        }
        let viewController = storyboard?.instantiateViewController(withIdentifier: "AttendeeDetailsViewController") as! AttendeeDetailsViewController
        if searchController.isActive && searchController.searchBar.text != "" {
            viewController.personModel = filteredArray[indexPath.row]
        } else {
            viewController.personModel = listArray[indexPath.row]
        }
        viewController.isSpeakerDetails = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "showDetail" {
//            if let indexPath = tableView.indexPathForSelectedRow {
//                let candy: Speaker
//                if searchController.isActive && searchController.searchBar.text != "" {
//                    candy = filteredCandies[indexPath.row]
//                } else {
//                    candy = candies[indexPath.row]
//                }
//                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
//                controller.detailCandy = candy
//                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
//                controller.navigationItem.leftItemsSupplementBackButton = true
//            }
//        }
    }
    
    
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!)
    }
    
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

// MARK: - Custom Cell Classes

class SpeakerCustomCell: UITableViewCell {
    
    @IBOutlet var nameLabel:UILabel!
    @IBOutlet var designationLabel:UILabel!
    @IBOutlet var imageview:UIImageView!
    @IBOutlet var statusImg:UIImageView!

    
    
}
