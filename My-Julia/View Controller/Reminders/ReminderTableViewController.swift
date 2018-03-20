//
//  ReminderTableViewController.swift
//  sections by dates
//
//  Created by GCO on 24/04/17.
//  Copyright © 2017 GCO. All rights reserved.


import UIKit

class ReminderTableViewController: UIViewController , UITableViewDelegate , UITableViewDataSource{
    
    @IBOutlet weak var tableviewObj: UITableView!
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var messageLbl: UILabel!

    @IBOutlet weak var addBtn: UIBarButtonItem!
    
    var dataList: NSMutableDictionary = [:]
    var sortedSections : Array<Any> = []

    var reminderarray:[ReminderModel] = []

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
        CommonModel.sharedInstance.applyTableSeperatorColor(object: tableviewObj)

        //Register header cell
        self.tableviewObj.register(UINib(nibName: "CustomHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "HeaderCellId")


        //Remove extra lines from tableview
        tableviewObj.tableFooterView = UIView()
        
        //Set separator color according to background color
        CommonModel.sharedInstance.applyTableSeperatorColor(object: tableviewObj)
        
        //Remove add reminder functionality
      //  navigationItem.rightBarButtonItem = nil
    }

    override func viewDidAppear(_ animated: Bool) {

        if dataList.count != 0 {
            dataList.removeAllObjects()
        }

        //Fetch data from Sqlite database
        reminderarray = DBManager.sharedInstance.fetchAllRemindersListFromDB() as! [ReminderModel]

        if self.reminderarray.count == 0 {
            self.messageLbl.text = No_Reminder_Text
            self.messageLbl.isHidden = false
        }else {
            self.messageLbl.isHidden = true
        }

        for item in reminderarray  {

            let dateStr = CommonModel.sharedInstance.getListHeaderDate(dateStr: item.sortDate)
            if (dataList.value(forKey: dateStr) != nil) {
                let array = dataList.value(forKey: dateStr) as! NSMutableArray
                array.add(item)
                dataList.setValue(array, forKey: dateStr)
            }
            else {
                let array = NSMutableArray()
                array.add(item)
                dataList.setValue(array, forKey: dateStr)
            }
        }

        sortedSections = dataList.allKeys
        self.tableviewObj.reloadData()
    }

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
    

    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Configure the cell...
        //        let todoArray = toDoList[sortedSections[indexPath.section]]!
        //        cell.textLabel?.text = todoArray[indexPath.row]
        //
        //        return cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath) as! ReminderCustomCell
        cell.backgroundColor = cell.contentView.backgroundColor;

        var model : ReminderModel
        
        model = ((self.dataList[sortedSections[indexPath.section]]) as! Array)[indexPath.row] as ReminderModel
        
        let hours = Int( model.reminderTime)! / 60
        let mins = Int( model.reminderTime)! % 60

        if hours != 0 && mins == 0{
            cell.dateLabel.text = String(format:"%@ - before %d hours",CommonModel.sharedInstance.getTimeInDisplayFormat(dateStr: model.activityStartTime),hours )
        }
        else if hours == 0 && mins != 0 {
            cell.dateLabel.text = String(format:"%@ - before %d mins",CommonModel.sharedInstance.getTimeInDisplayFormat(dateStr: model.activityStartTime), mins )
        }
        else {
            cell.dateLabel.text = String(format:"%@ - before %d hour %d mins",CommonModel.sharedInstance.getTimeInDisplayFormat(dateStr: model.activityStartTime), hours, mins)
        }
        
        cell.titleLabel.text = model.title
        cell.selectionStyle = UITableViewCellSelectionStyle.none

        return cell
    }
}


// MARK: - Custom Cell Classes

class ReminderCustomCell: UITableViewCell {
    
    @IBOutlet var dateLabel:UILabel!
    @IBOutlet var titleLabel:UILabel!
    @IBOutlet var descriptionLabel:UILabel!
    
}
