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

    }

    override func viewDidAppear(_ animated: Bool) {

        //Update all notifcation as read
        DBManager.sharedInstance.updateNotificationStatus()

        //Update actiivty read/unread data count in side menu bar
        let dataDict:[String: Any] = ["Order": self.view.tag, "Flag":Update_Broadcast_List]
        NotificationCenter.default.post(name: UpdateNotificationCount, object: nil, userInfo: dataDict)

        //Update side menu notification count
       // self.notificationModelController.initializeModuleIndex(index : self.view.tag)

        //load data from db
        self.notificationModelController.loadItem()
        self.tableView.reloadData()

        //Fetch data from server
        self.getNotificationData()
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

    // MARK: -  WebService Methods

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
        print("model.title : ",model.title)
        print("message : ",model.message)
        cell.timeLabel.text  =  CommonModel.sharedInstance.getDateAndTime(dateStr:model.cretedDate)

       let sucess =  self.notificationModelController.checkLoadMoreViewModel(at: indexPath.row)

        //Last row scroll
        if sucess {
            self.getNotificationData()
        }

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
