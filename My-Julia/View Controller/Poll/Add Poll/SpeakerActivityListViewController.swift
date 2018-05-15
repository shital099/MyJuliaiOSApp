//
//  SpeakerActivityListViewController.swift
//  My-Julia
//
//  Created by gco on 24/01/18.
//  Copyright © 2018 GCO. All rights reserved.
//

import UIKit

class SpeakerActivityListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bgImageView: UIImageView!
    var statusAlert : UIAlertController!
    var placeholderLabel : UILabel!
    var alert : TKAlert!
    //var listArray : [AgendaModel] = []

//    var listArray:NSMutableArray = []
    var array : NSMutableArray = []

    var dataList: NSMutableDictionary = [:]
    var sortedSections : Array<Any> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /* Setup delegates */
        tableView.delegate = self
        tableView.dataSource = self
        
        self.title = "Activity List"
        
        //Remove extra lines from tableview
        tableView.tableFooterView = UIView()
        
        //Update dyanamic height of tableview cell
        self.tableView.estimatedRowHeight = 400
        self.tableView.rowHeight = UITableViewAutomaticDimension

        //apply application theme on screen
        CommonModel.sharedInstance.applyThemeOnScreen(viewController: self, bgImage: bgImageView) 

        //Register header cell
        tableView.register(UINib(nibName: "CustomHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "HeaderCellId")
        
        //Set separator color according to background color
        CommonModel.sharedInstance.applyTableSeperatorColor(object: tableView)
        //Register header cell
        tableView.register(UINib(nibName: "CustomHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "HeaderCellId")

        //Fetch data from Sqlite database
//        listArray = DBManager.sharedInstance.saveSpeakerActivitiesIntoDB(response: AnyObject as AnyObject).
        //now
//        listArray = DBManager.sharedInstance.fetchSpeakerPollActListFromDB() as! [AgendaModel]
//

        let listArray = DBManager.sharedInstance.fetchSpeakerPollActListFromDB() as! [AgendaModel]
        self.sortData(dataArray: listArray as NSArray)

        self.fetchSpeakerActData()
        
    }
    
    func sortData(dataArray : NSArray)  {
        
        //Clear previous data
        if sortedSections.count != 0 {
            sortedSections.removeAll()
        }
        if dataList.count != 0 {
            dataList.removeAllObjects()
        }
        
        for item in dataArray  {
            
            let model = item as! AgendaModel
            let dateStr = self.getSectionHeaderDate(dateStr: model.startActivityDate)
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

    func getSectionHeaderDate(dateStr: String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.locale = Locale.init(identifier: "en_GB")
        let date = dateFormatter.date(from: dateStr)
        dateFormatter.dateFormat = "EEEE, MMM dd, yyyy"
        let result:String = dateFormatter.string(from: date!)
        
        return result
    }
    
       // MARK: - UITableView Delegate Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sortedSections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ((self.dataList.value(forKey: sortedSections[section] as! String))! as AnyObject).count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HeaderCellId") as! CustomHeaderView
        
        headerView.backgroundColor = AppTheme.sharedInstance.menuBackgroundColor.darker(by: 15)
        
        headerView.headerLabel.text = self.sortedSections[section] as? String
        headerView.headerLabel.font = headerView.headerLabel.font.withSize(14)
        
        headerView.setGradientColor()
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func getTime(dateStr: String) -> String {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.locale = Locale.init(identifier: "en_GB")
        let date = dateFormatter.date(from: dateStr)
        dateFormatter.dateFormat = "hh:mm a"
        let result:String = dateFormatter.string(from: date!)
        return result
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "selectActCell", for: indexPath) as! SelectActCell
        cell.backgroundColor = cell.contentView.backgroundColor
        cell.bgImage?.layer.cornerRadius = 5.0
        let model : AgendaModel = ((self.dataList[sortedSections[indexPath.section]]) as! Array)[indexPath.row]
        cell.actnameLbl.text = model.activityName
        cell.actstartDateLbl.text =  self.getTime(dateStr: model.startActivityDate).appendingFormat(" - %@", self.getTime(dateStr: model.endActivityDate))
//        cell.actendDateLbl.text = CommonModel.sharedInstance.getAgendaDate(dateStr: model.endActivityDate)

       cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let viewController = storyboard?.instantiateViewController(withIdentifier: "ActivityQuestionsListViewController") as! ActivityQuestionsListViewController
        viewController.model = ((self.dataList[sortedSections[indexPath.section]]) as! Array)[indexPath.row]
        self.navigationController?.pushViewController(viewController, animated: true)
    }
  
    func fetchSpeakerActData()
    {

        let parameter = ["EventId" : EventData.sharedInstance.eventId, "SpeakerId" : AttendeeInfo.sharedInstance.speakerId]
        print(AttendeeInfo.sharedInstance.speakerId)
        NetworkingHelper.postData(urlString: Get_Speaker_Activity_url, param: parameter as AnyObject, withHeader: true, isAlertShow: false, controller:self, callback: { response in
            print("Activity list :", response)
            if response is Array<Any> {
                self.sortData(dataArray: DBManager.sharedInstance.fetchSpeakerPollActListFromDB() as! [AgendaModel] as NSArray)
//                self.parseSpeakerData(response: response)
            }
        }, errorBack: { error in
            NSLog("error : %@", error)
        })
    }

//    func parseSpeakerData(response : AnyObject)
//    {
//            for item in response as! NSArray{
//            let dict = item as! NSDictionary
//            let model = AgendaModel()
//            model.activityName = dict.value(forKey: "Text") as! String!
//            model.activityId = dict.value(forKey: "Value") as! String!
//
//           self.listArray.append(model)
//        }
//        self.tableView.reloadData()
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
 
}

// MARK: - Custom Cell Classes
class SelectActCell: UITableViewCell {
    
    @IBOutlet weak var actnameLbl: UILabel!
    @IBOutlet weak var actstartDateLbl: UILabel!
    @IBOutlet weak var actendDateLbl: UILabel!
    @IBOutlet weak var bgImage: UIImageView!

    
}
