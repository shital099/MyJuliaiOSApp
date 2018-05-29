//
//  SessionListViewController.swift
//  My-Julia
//
//  Created by GCO on 8/24/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

class SessionListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bgImageView: UIImageView!

    //var listArray:NSMutableArray = []
    var dataList: NSMutableDictionary = [:]
    var sortedSections : Array<Any> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //Show menu icon in ipad and iphone
        self.setupMenuBarButtonItems()
        
        //        if IS_IPHONE {
        //            self.setupMenuBarButtonItems()
        //        }

        //Update dyanamic height of tableview cell
        self.tableView.estimatedRowHeight = 400
        self.tableView.rowHeight = UITableViewAutomaticDimension

        //apply application theme on screen
        CommonModel.sharedInstance.applyThemeOnScreen(viewController: self, bgImage: bgImageView)
        
        //Register header cell
        tableView.register(UINib(nibName: "CustomHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "HeaderCellId")
        
        //Remove extra lines from tableview
        tableView.tableFooterView = UIView()
        tableView.tableFooterView?.tintColor = .clear

        self.tableView.tintColor = AppTheme.sharedInstance.menuBackgroundColor.darker(by: 15)
        
    }

    override func viewDidAppear(_ animated: Bool) {
        //Fetch all completed activity from db
        self.sortData(dataArray: DBManager.sharedInstance.fetchAllPastActivitiesDataFromDB())
        
        //   if listArray.count == 0 {
        //Show Indicator
        // CommonModel.sharedInstance.showActitvityIndicator()
        // }

        // Move to a background thread to do some long running work
        DispatchQueue.global(qos: .background).async {
            ///Fetch Questions data from json
            self.fetchAllCompletedSessionList()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func fetchCurrentSession() {
                
        let array = DBManager.sharedInstance.fetchCurrentActivity()
        for item in array  {
            let model = item as! SessionsModel
            if model.sortActivityDate != nil {
                
                //let dateStr = model.day.appendingFormat(", %@", CommonModel.sharedInstance.getListHeaderDate(dateStr: model.sortActivityDate))
                let dateStr = CommonModel.sharedInstance.getListHeaderDate(dateStr: model.sortActivityDate)
                if (dataList.value(forKey: dateStr) != nil) {
                    let array = dataList.value(forKey: dateStr) as! NSMutableArray
                    array.add(model)
                    dataList.setValue(array, forKey: dateStr)
                }
                else {
                    let array = NSMutableArray()
                    array.add(model)
                    dataList.setValue(array, forKey: dateStr)
                    sortedSections.append(dateStr)
                }
            }
        }
    }
    
    // MARK: - Webservice Methods
    func fetchAllCompletedSessionList() {

        let urlStr = Get_AllModuleDetails_url.appendingFormat("Flag=%@",GetQuestionActivities_url)
        NetworkingHelper.getRequestFromUrl(name:GetQuestionActivities_url,  urlString:urlStr, callback: { [weak self] response in
            CommonModel.sharedInstance.dissmissActitvityIndicator()

            //   print("Questions Activities:", response)
            // Bounce back to the main thread to update the UI
            DispatchQueue.main.async {
                //Fetch all completed activity from db
                self?.sortData(dataArray: DBManager.sharedInstance.fetchAllPastActivitiesDataFromDB())
            }
        }, errorBack: { error in
            NSLog("error : %@", error)
            CommonModel.sharedInstance.dissmissActitvityIndicator()
        })
    }

    func sortData(dataArray : NSArray)  {
        
        //Clear previous data
        if sortedSections.count != 0 {
            sortedSections.removeAll()
        }
        if dataList.count != 0 {
            dataList.removeAllObjects()
        }
        
        //Check currently anu session going on
        self.fetchCurrentSession()

        for item in dataArray  {
            
            let model = item as! SessionsModel
            let dateStr = CommonModel.sharedInstance.getListHeaderDate(dateStr: model.sortActivityDate)
            if (dataList.value(forKey: dateStr) != nil) {
                let array = dataList.value(forKey: dateStr) as! NSMutableArray
                array.add(item)
                dataList.setValue(array, forKey: dateStr)
            }
            else {
                let array = NSMutableArray()
                array.add(item)
                dataList.setValue(array, forKey: dateStr)
                sortedSections.append(dateStr)
            }
        }
        
        tableView.reloadData()
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

    // MARK: - UITableView Data Source Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.sortedSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return ((self.dataList.value(forKey: sortedSections[section] as! String))! as AnyObject).count
    }
  
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 28
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HeaderCellId") as! CustomHeaderView
       // headerView.backgroundColor = AppTheme.sharedInstance.menuBackgroundColor.darker(by: 15)

        headerView.headerLabel.text = self.sortedSections[section] as? String
        headerView.headerLabel.font = headerView.headerLabel.font.withSize(14)
        
        headerView.setGradientColor()

        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
       // let cell = tableView.dequeueReusableCell(withIdentifier: "ActiveCellIdentifier", for: indexPath) as! SessionCustomCell

        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath) as! SessionCustomCell
        cell.bgImage?.layer.cornerRadius = 5.0 
        cell.backgroundColor = cell.contentView.backgroundColor;

        let model : SessionsModel = ((self.dataList[sortedSections[indexPath.section]]) as! Array)[indexPath.row]

        cell.activityNameLbl.text = model.activityName
        cell.agenaNameLbl.text = model.agendaName
        
        cell.timeLbl.text = String(format: "%@ - %@",CommonModel.sharedInstance.getTimeInDisplayFormat(dateStr: model.startTime),CommonModel.sharedInstance.getTimeInDisplayFormat(dateStr: model.endTime))

        cell.locationLbl.text = model.location

        if model.isActive {
            cell.timeLbl.isHighlighted = true
            cell.statusImage.isHighlighted = true
        }
        else {
            cell.timeLbl.isHighlighted = false
            cell.statusImage.isHighlighted = false
        }
        
        return cell
    }
    
    // MARK: - TableView Delegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let viewController = storyboard?.instantiateViewController(withIdentifier: "QuestionsViewController") as! QuestionsViewController
        viewController.sessionModel = ((self.dataList[sortedSections[indexPath.section]]) as! Array)[indexPath.row]
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - Custom Cell Classes

class SessionCustomCell: UITableViewCell {
    
    @IBOutlet weak var activityNameLbl:UILabel!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var statusImage: UIImageView!
    @IBOutlet weak var agenaNameLbl:UILabel!

}

