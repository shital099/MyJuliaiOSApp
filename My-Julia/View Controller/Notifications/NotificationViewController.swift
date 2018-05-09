//
//  NotificationViewController.swift
//  My-Julia
//
//  Created by GCO on 24/04/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

class NotificationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bgImageView: UIImageView!
    
    //var dataArray:[NotificationsModel] = []
    //var dataList: NSMutableDictionary = [:]
  //  var sortedSections : Array<Any> = []
  //  var dataArray:NSMutableArray = []

//    var pageNo : NSInteger = 0
//    var isLastPage : Bool = false
    fileprivate let notificationModelController = NotificationViewModelController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Setup delegates */
        tableView.delegate = self
        tableView.dataSource = self
        
        //Show menu icon in ipad and iphone
        self.setupMenuBarButtonItems()

        //apply application theme on screen
        CommonModel.sharedInstance.applyThemeOnScreen(viewController: self, bgImage: bgImageView)
        
        //Update dyanamic height of tableview cell
        tableView.estimatedRowHeight = 600
        tableView.rowHeight = UITableViewAutomaticDimension
        
        //Remove extra lines from tableview
        tableView.tableFooterView = UIView()
        
        //Set separator color according to background color
        CommonModel.sharedInstance.applyTableSeperatorColor(object: tableView)
        
        //Register header cell
        self.tableView.register(UINib(nibName: "CustomHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "HeaderCellId")

        //Fetch notification data from database
       // self.dataArray = DBManager.sharedInstance.fetchNotificationDataFromDB(limit: Activity_Page_Limit, offset: pageNo).mutableCopy() as! NSMutableArray
        //self.sortData()

        //load data from db
        self.notificationModelController.loadItem()

        //Fetch data from server
        self.getNotificationData()

        self.changeNotificationCount()
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

    // MARK: -  WebService Methods

    /*func loadItem()  {
        // print("before fetch Data array count : ", self.dataArray.count)

        //Calculate page offset offset
        print("Page no : ",self.pageNo)
        let offset = self.pageNo * Activity_Page_Limit
        print("Offset : ",offset)

        let array = DBManager.sharedInstance.fetchNotificationDataFromDB(limit: Activity_Page_Limit, offset: offset).mutableCopy() as! NSMutableArray
        if array.count < Activity_Page_Limit {
            self.isLastPage = true
        }
        self.dataArray.addObjects(from: array as! [Any])
        self.tableView.reloadData()
        // print("After load Data array count : ", self.dataArray.count)
    }*/


    func getNotificationData() {

        notificationModelController.retrieveNotifications { [weak self] (success, error) in
            guard let strongSelf = self else { return }
            if !success {
                DispatchQueue.main.async {
                }
            } else {
                DispatchQueue.main.async {
                    //load data from db
                   // strongSelf.notificationModelController.loadItem()
                    strongSelf.tableView.reloadData()
                }
            }
        }
    }
    
    func changeNotificationCount() {
        //Change notification count in side menu
        let dataDict:[String: Any] = ["Order": self.view.tag, "Flag":Update_Broadcast_List]
        NotificationCenter.default.post(name: UpdateNotificationCount, object: nil, userInfo: dataDict)
    }


    // MARK: - UITableView Delegate Methods
    // MARK: - Table view data source
    
   /* func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.sortedSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return ((self.dataList.value(forKey: sortedSections[section] as! String))! as AnyObject).count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return YES if you want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.delete {
            DBManager.sharedInstance.deleteReminderDataIntoDB(reminder:((self.dataList[sortedSections[indexPath.section]]) as! Array)[indexPath.row])
            // tableView.reloadData()
            let array = dataList.value(forKey: sortedSections[indexPath.section] as! String) as! NSMutableArray
            array.removeObject(at: indexPath.row)
            if array.count == 0 {
                sortedSections.remove(at: indexPath.section)
                tableView.reloadData()
            }
            else {
                dataList.setValue(array, forKey: sortedSections[indexPath.section] as! String)
                tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.bottom)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 23
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HeaderCellId") as! CustomHeaderView
        headerView.backgroundColor = AppTheme.sharedInstance.menuBackgroundColor.darker(by: 15)
        headerView.headerLabel.text = self.sortedSections[section] as? String
        headerView.setGradientColor()
        
        return headerView
    }
*/

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notificationModelController.viewModelsCount
       // return dataArray.count;
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath) as! NotificationCustomCell
        cell.backgroundColor = UIColor.clear

        var model : NotificationsModel
//        model = ((self.dataList[sortedSections[indexPath.section]]) as! Array)[indexPath.row] as NotificationsModel
        model = notificationModelController.viewModel(at: indexPath.row)!

        cell.titleLabel.text = model.title
        cell.messageLabel.text = model.message
        cell.messageLabel.sizeToFit()
        cell.statusImg.isHidden  = model.isRead

        //let timeStr = CommonModel.sharedInstance.getNotificationDate(dateStr: model.cretedDate).appendingFormat("%@", CommonModel.sharedInstance.getSessionsTime(dateStr: model.cretedDate))
       // print("Time ",timeStr)
        cell.timeLabel.text  =  CommonModel.sharedInstance.getDateAndTime(dateStr:model.cretedDate)

       let sucess =  self.notificationModelController.checkLoadMoreViewModel(at: indexPath.row)

        //Last row scroll
        if sucess {
            self.getNotificationData()
        }

//        if indexPath.row == self.dataArray.count - 1 { // last cell
//
//            if isLastPage == false { // more items to fetch
//                // more items to fetch
//                self.pageNo += 1
//                getNotificationData() // increment `fromIndex` by 20 before server call
//            }
//        }

        return cell
    }
    
    // MARK: - UITableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - Custom Cell Classes

class NotificationCustomCell: UITableViewCell {
    
    @IBOutlet var titleLabel:UILabel!
    @IBOutlet var messageLabel:UILabel!
    @IBOutlet var timeLabel:UILabel!
    @IBOutlet var statusImg:UIImageView!

}
