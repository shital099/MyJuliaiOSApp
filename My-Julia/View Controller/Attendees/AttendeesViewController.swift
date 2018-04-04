//
//  AttendeesViewController.swift
//  My-Julia
//
//  Created by GCO on 24/04/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

class AttendeesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchResultsUpdating{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bgImageView: UIImageView!
    var searchController : UISearchController!

    var filtered:[PersonModel] = []
    var listArray:[PersonModel] = []
    var dataDict = [String: Array<PersonModel>]()
    var filteredDict = [String: Array<PersonModel>]()

    
//    let searchController = UISearchController(searchResultsController: nil)
    var arrIndexSection : NSArray = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
    var sectonArray : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Show menu icon in ipad and iphone
        self.setupMenuBarButtonItems()
        
        //        if IS_IPHONE {
        //            self.setupMenuBarButtonItems()
        //        }

        
        //Remove extra lines from tableview
        tableView.tableFooterView = UIView()

        //Update dyanamic height of tableview cell
        tableView.estimatedRowHeight = 600
        tableView.rowHeight = UITableViewAutomaticDimension

        // Setup the Search Controller
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
       // self.searchController.hidesNavigationBarDuringPresentation = false;
        //self.navigationItem.titleView = self.searchController.searchBar;
         tableView.tableHeaderView = searchController.searchBar

        //tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: false)
        

        //apply application theme on screen
        CommonModel.sharedInstance.applyThemeOnScreen(viewController: self, bgImage: bgImageView)
        
        //Set separator color according to background color
        CommonModel.sharedInstance.applyTableSeperatorColor(object: tableView)

        //Register header cell
        tableView.register(UINib(nibName: "CustomHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "HeaderCellId")
        
        self.fetchAttendeeListAndSortAlphabetically()
        
        let queue = OperationQueue()
        //Profile
        queue.addOperation { () -> Void in
            let urlStr = Get_AllModuleDetails_url.appendingFormat("Flag=%@",Attendees_List_url)
            NetworkingHelper.getRequestFromUrl(name:Attendees_List_url,  urlString: urlStr, callback: { response in
                self.fetchAttendeeListAndSortAlphabetically()
            }, errorBack: { error in
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //CommonModel.sharedInstance.animateTable(tableView : self.tableView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   func fetchAttendeeListAndSortAlphabetically() {
        
        if self.dataDict.keys.count != 0 {
            self.dataDict.removeAll()
        }
        if self.sectonArray.count != 0 {
            self.sectonArray.removeAll()
        }

        //Fetch data from Sqlite database
        listArray = DBManager.sharedInstance.fetchAttendeesDataFromDB() as! [PersonModel]
        
        for i in 0...arrIndexSection.count - 1 {

            let  index : String = arrIndexSection[i] as! String

            let predicate:NSPredicate = NSPredicate(format: "name BEGINSWITH[cd] %@", index)
            let filteredArray = listArray.filter { predicate.evaluate(with: $0) };
            if filteredArray.count != 0 {
                sectonArray.append(index)
                self.dataDict[index] = filteredArray
            }
        }
      //  print("Attedee Data Dict : ", self.dataDict)
        self.tableView.reloadData()
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

    // Tableview Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectonArray.count
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.arrIndexSection as? [String] //Side Section title
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int
    {
        return index
    }
        
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HeaderCellId") as! CustomHeaderView
       // headerView.translatesAutoresizingMaskIntoConstraints = false

        headerView.backgroundColor = AppTheme.sharedInstance.menuBackgroundColor.darker(by: 15)
        
        headerView.headerLabel.text = sectonArray[section]
        
        headerView.setGradientColor()
        
        return headerView
    }
    
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return self.filteredDict[self.sectonArray[section]]!.count;
        }
        else if (self.dataDict[self.sectonArray[section]] != nil) {
            return self.dataDict[self.sectonArray[section]]!.count;
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath) as! AttendeesCustomCell
        cell.backgroundColor = cell.contentView.backgroundColor

        var model : PersonModel
        
        if searchController.isActive && searchController.searchBar.text != "" {
            model = (self.filteredDict[self.sectonArray[indexPath.section]]?[indexPath.row])!
        } else {
            model = (self.dataDict[self.sectonArray[indexPath.section]]?[indexPath.row])!
        }
        
        cell.nameLabel?.text = model.name

        //cell.designationLabel.text = model.designation
        if model.privacySetting == true && !model.iconUrl.isEmpty {
            
            cell.imageview.sd_setImage(with: URL(string:model.iconUrl), placeholderImage: #imageLiteral(resourceName: "user"))
            cell.imageview?.layer.cornerRadius = cell.imageview.frame.size.height/2
            cell.imageview.clipsToBounds = true
            cell.imageview.layer.borderColor = UIColor.gray.cgColor
            cell.imageview.layer.borderWidth = 1.0
        }
        else  {
            cell.imageview.image = #imageLiteral(resourceName: "user")
        }
        return cell
    }
    
    
    // MARK: - UITableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        let viewController = storyboard?.instantiateViewController(withIdentifier: "AttendeeDetailsViewController") as! AttendeeDetailsViewController
        
        if searchController.isActive && searchController.searchBar.text != "" {
            viewController.personModel = (self.filteredDict[self.sectonArray[indexPath.section]]?[indexPath.row])!
        } else {
            viewController.personModel = (self.dataDict[self.sectonArray[indexPath.section]]?[indexPath.row])!
        }
        viewController.isSpeakerDetails = viewController.personModel.isSpeaker
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!)
    }
    
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func filterContentForSearchText(_ searchText: String) {
        
//        let filteredKeys = self.dataDict.filter { (key, value) in value.contains(where: { $0.name.contains(searchText.lowercased()) }) }.map { $0.0 }
//        print("filteredKeys ",filteredKeys);

//        filtered = self.listArray.filter({( model : PersonModel) -> Bool in
//            return model.name.lowercased().contains(searchText.lowercased())
//        })

        let filteredKeys : [String] = self.dataDict.flatMap { (key, arr) -> String? in
            
            //if arr.contains(where: { $0.name.contains(searchText.lowercased()) }) {
            //print("arr ",arr.count);
            let filteredArr = arr.filter({( model : PersonModel) -> Bool in
                return model.name.lowercased().contains(searchText.lowercased())
            })
            
            if filteredArr.count != 0 {
                filteredDict[key] = filteredArr
                return key
            }
            return nil
            //  }
        }
        
        sectonArray = filteredKeys.sorted()

//      let result = self.dataDict.flatMap({ $0.1.filter({ $0.name.contains(searchText.lowercased())}) })
//        print("result ",result)
        
        if searchController.searchBar.text == "" {
            sectonArray = self.dataDict.keys.sorted()
        }
        tableView.reloadData()
    }
    
}

//
//extension UILocalizedIndexedCollation {
//    //func for partition array in sections
//    func partitionObjects(array:[AnyObject], collationStringSelector:Selector) -> [AnyObject] {
//        var unsortedSections = [[AnyObject]]()
//        //1. Create a array to hold the data for each section
//        for _ in self.sectionTitles {
//            unsortedSections.append([]) //appending an empty array
//        }
//        //2. put each objects into a section
//        for item in array {
//            let index:Int = self.section(for: item, collationStringSelector:collationStringSelector)
//            unsortedSections[index].append(item)
//        }
//        //3. sort the array of each sections
//        var sections = [AnyObject]()
//        for index in 0 ..< unsortedSections.count {
//            sections.append(self.sortedArray(from: unsortedSections[index], collationStringSelector: collationStringSelector) as AnyObject)
//        }
//        return sections
//    }
//}
// MARK: - Custom Cell Classes

class AttendeesCustomCell: UITableViewCell {
    
    @IBOutlet var nameLabel:UILabel!
    @IBOutlet var imageview:UIImageView!
    @IBOutlet var designationLabel:UILabel!
}

