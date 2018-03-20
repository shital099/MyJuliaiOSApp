//
//  AgendaViewController.swift
//  EventApp
//
//  Created by GCO on 5/2/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

class AgendaViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource,UICollectionViewDelegate {
    
    @IBOutlet weak var selectedDateLbl: UILabel!
    @IBOutlet weak var collectionview: UICollectionView!
    @IBOutlet weak var tableviewObj: UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var messageLbl: UILabel!
    @IBOutlet weak var headerBgView: UIView!

    var dataDict = [String: Array<AgendaModel>]()
    var myScheduleDataDict = [String: Array<AgendaModel>]()

    var datesArray : NSMutableArray = []
    var daysArray : NSMutableArray = []
    var selectedDate : String = ""
    var isMySchedules : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        //apply application theme on screen
        CommonModel.sharedInstance.applyThemeOnScreen(viewController: self, bgImage: bgImageView)
        
        //Set segment tint color
        self.segmentControl.tintColor = AppTheme.sharedInstance.backgroundColor.darker(by: 40)!
        //self.segmentControl.tintColor = AppTheme.sharedInstance.backgroundColor.getDarkerColor()

        //Show menu icon in ipad and iphone
        self.setupMenuBarButtonItems()
        
        //        if IS_IPHONE {
        //            self.setupMenuBarButtonItems()
        //        }

        //Update dyanamic height of tableview cell
        self.tableviewObj.estimatedRowHeight = 300
        self.tableviewObj.rowHeight = UITableViewAutomaticDimension

        //Check If my schdeule or Agneda module available or not
        if !isMySchedulesPresent || !isAgendaPresent {
           self.segmentControl.isHidden = true
            self.tableviewObj.height += 56
            self.tableviewObj.updateConstraintsIfNeeded()
        }
        
        //If MySchedules selected then 2 tab selected
        if isMySchedules == true {
            self.title = "My Schedule"
            segmentControl.selectedSegmentIndex = 1
        }
        else {
            self.title = "Agenda"
            segmentControl.selectedSegmentIndex = 0
        }
        
        tableviewObj.separatorColor = UIColor.red // AppTheme.sharedInstance.backgroundColor.darker(by:10)
        
        self.fetchAgendaDataList()

    }
    
    override func viewDidAppear(_ animated: Bool) {
      
        
        if datesArray.count != 0 {
            
            //Show today's date activities
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy"
            let todaysDate = formatter.string(from: date)
            if   self.datesArray.contains(todaysDate) {
                self.selectedDate = todaysDate
            }
            else {
                self.selectedDate = self.datesArray.lastObject as! String
            }
            
            self.collectionView(self.collectionview, didSelectItemAt: NSIndexPath(item: self.datesArray.index(of: self.selectedDate), section: 0) as IndexPath)
            self.onChangeOnBottomTab(segmentControl)
        }
    }

    func fetchAgendaDataList()  {
        //Fetch all dates from DB
        // self.datesArray = DBManager.sharedInstance.fetchEventDatesFromDB()
        
        //Add Some sample date selected
        self.selectedDate = "11-13-2000"//self.datesArray[0] as! String
        
        // self.daysArray = DBManager.sharedInstance.fetchEventDayFromDB()
        
        //Calculate days between events start and end date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        var startDate = dateFormatter.date(from: EventData.sharedInstance.eventStartDate)
        let endDate = dateFormatter.date(from: EventData.sharedInstance.eventEndDate)
        
        let diffInDays = Calendar.current.dateComponents([.day], from: startDate!, to: endDate!).day
       // print("diffInDays : ",diffInDays)
        
        for _ in 0...diffInDays! {
            
            dateFormatter.dateFormat = "dd-MM-yyyy"
            let dateStr:String = dateFormatter.string(from: startDate!)
            self.datesArray.add(dateStr)
            
            dateFormatter.dateFormat = "EEEE"
            let dayStr:String = dateFormatter.string(from: startDate!)
            self.daysArray.add(dayStr)
            // print("date : ",dateStr)
            //  print("days : ",dayStr)
            startDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate!)!
        }
        
        if daysArray.count != 0 {
            self.messageLbl.isHidden = true
            self.headerBgView.isHidden = false
            self.fetchActivitiesListAndSort()
        }
    }
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let destinationVC = segue.destination as! AgendaDetailsViewController
        let indexPath = tableviewObj.indexPathForSelectedRow
        if isMySchedules {
            destinationVC.agendaModel = (self.myScheduleDataDict[self.selectedDate]?[(indexPath?.row)!])!
        }
        else {
            destinationVC.agendaModel = (self.dataDict[self.selectedDate]?[(indexPath?.row)!])!
        }

        destinationVC.isMySchedules = self.isMySchedules
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
    
    func fetchActivitiesListAndSort() {
    
        //Fetch data from Sqlite database
        let listArray = DBManager.sharedInstance.fetchAllScheduleListFromDB(isAddedMySchedule: isMySchedules) as! [AgendaModel]

        for index in 0...datesArray.count - 1 {
            
            let date : String = datesArray[index] as! String
            let predicate:NSPredicate = NSPredicate(format: "sortDate = %@", date)
            let filteredArray = listArray.filter { predicate.evaluate(with: $0) };

            if isMySchedules {
                self.myScheduleDataDict[date] = filteredArray
            }
            else {
                self.dataDict[date] = filteredArray
            }
        }
      //  print("Agenda : ", self.dataDict)
    }
    
    
    // MARK: - Button Action Method
    
    @IBAction func onChangeOnBottomTab(_ sender: Any) {
        
        if segmentControl.selectedSegmentIndex == 0 {
            self.title = "Agenda"
            self.isMySchedules = false
        }
        else {
            self.title = "My Schedule"
            self.isMySchedules = true
        }
        
        if daysArray.count != 0 {
            //Fetch Activity data from db and refresh tableview
            self.fetchActivitiesListAndSort()
        }
        tableviewObj.reloadData()
    }
    
    @objc func onClickOfAddToScheduleBtn(sender: AnyObject) {
        // let _ = UIButton.circleButtonInView(self.view, title: "Show Alert", target: self, action: #selector(self.show(_:)))
      
        var model : AgendaModel!
        
        let indexPath = IndexPath(row: sender.tag, section: 0)

        if isMySchedules {
             model = self.myScheduleDataDict[self.selectedDate]![sender.tag]
            var array = self.myScheduleDataDict[selectedDate]
            array?.remove(at: indexPath.row)
            self.myScheduleDataDict[selectedDate] = array
            
            CommonModel.sharedInstance.showAlertNotification(view: self.view, title: Agenda_Sucess, message: Deleted_Agenda_Text, alertType: TKAlertType.TKAlertTypeError.rawValue)
        }
        else {
            model = self.dataDict[self.selectedDate]![sender.tag]

            if model.isAddedToSchedule {
                CommonModel.sharedInstance.showAlertNotification(view: self.view, title: Agenda_Sucess, message: Deleted_Agenda_Text, alertType: TKAlertType.TKAlertTypeError.rawValue)
            }
            else {
                CommonModel.sharedInstance.showAlertNotification(view: self.view, title: Agenda_Sucess, message: Added_Agenda_Text, alertType: TKAlertType.TKAlertTypeSucess.rawValue)
            }
        }
        
        model.isAddedToSchedule = !model.isAddedToSchedule
        
        //add this activity to my schedule
        DBManager.sharedInstance.addToMyScheduleDataIntoDB(model: model)

        //Fetch Activity data from db and refresh tableview
        self.fetchActivitiesListAndSort()
        tableviewObj.reloadData()
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return self.datesArray.count
    }
    
    //3
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomDateCell", for: indexPath) as! CustomDateCell
        // cell.backgroundColor = UIColor.black
    
        cell.dayLbl.text = self.daysArray[indexPath.row] as? String
        cell.dateLbl.text =  CommonModel.sharedInstance.getAgendaDayOnly(dateStr: self.datesArray[indexPath.row] as! String)
        
        if self.datesArray[indexPath.row] as! String ==  self.selectedDate {
            cell.circleImageview.isHighlighted = true;
            cell.dateLbl.isHighlighted = true;
        }
        else {
            cell.circleImageview.isHighlighted = false;
            cell.dateLbl.isHighlighted = false;
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.selectedDateLbl.text = String(format: "%@, %@", arguments: [self.daysArray[indexPath.row] as! CVarArg,CommonModel.sharedInstance.getAgendaSelectedDate(dateStr: self.datesArray[indexPath.row] as! String)])
        
        collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
        self.selectedDate = self.datesArray[indexPath.row] as! String
        self.collectionview.reloadData()
        self.tableviewObj.reloadData()
    }
    
    // MARK: - TableView DataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isMySchedules {
            if (self.myScheduleDataDict[self.selectedDate] != nil) {
                return self.myScheduleDataDict[self.selectedDate]!.count
            }
        }
        else {
            if (self.dataDict[self.selectedDate] != nil) {
                return self.dataDict[self.selectedDate]!.count
            }
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AgendaCustomCell", for: indexPath) as! AgendaCustomCell
        cell.backgroundColor = cell.contentView.backgroundColor;

        let model : AgendaModel!
        
        if self.isMySchedules {
            model = self.myScheduleDataDict[self.selectedDate]![indexPath.row]
        }
        else {
            model = self.dataDict[self.selectedDate]![indexPath.row]
        }

        cell.nameLabel!.text = model.activityName
        cell.agendaNameLabel!.text = model.agendaName
        cell.addressLbl.text = model.location //.appendingFormat("- Date : %@", model.startActivityDate)
        cell.timeLbl.text = CommonModel.sharedInstance.getTimeInDisplayFormat(dateStr: model.startTime)
        cell.endTimeLbl.text = CommonModel.sharedInstance.getTimeInDisplayFormat(dateStr: model.endTime)
        
        //Check If my schdeule or Agneda module available or not
        if !isMySchedulesPresent {
            cell.addBtn.isHidden = true
        }
        else {
            cell.addBtn.tag = indexPath.row
            cell.addBtn.addTarget(self, action: #selector(onClickOfAddToScheduleBtn(sender:)), for: UIControlEvents.touchUpInside)
        }

        //Highlight Current on going activity
        cell.statusImg.isHighlighted = model.activityStatus
        
        if model.isAddedToSchedule {
            cell.addBtn.isSelected = true
            UIColor().setIconColorImageToButton(button: cell.addBtn, image:"remove_schedule")
        }
        else {
            cell.addBtn.isSelected = false
            UIColor().setIconColorImageToButton(button: cell.addBtn, image:"add_schedule")
        }

        //Set separator color according to background color
        CommonModel.sharedInstance.applyTableSeperatorColor(object: cell.seperatorImg)
        
        return cell
    }
}

// MARK: - Custom Cell Classes

class AgendaCustomCell: UITableViewCell {
    
    @IBOutlet var nameLabel:UILabel!
    @IBOutlet var agendaNameLabel:UILabel!
    @IBOutlet var addressLbl:UILabel!
    @IBOutlet var timeLbl:UILabel!
    @IBOutlet var endTimeLbl:UILabel!
    @IBOutlet var addBtn:UIButton!
    @IBOutlet var seperatorImg:UIImageView!
    @IBOutlet var statusImg:UIImageView!
}

class CustomDateCell: UICollectionViewCell {
    
    @IBOutlet var dayLbl:UILabel!
    @IBOutlet var dateLbl:UILabel!
    @IBOutlet var circleImageview:UIImageView!
}

