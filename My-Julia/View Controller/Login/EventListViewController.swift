//
//  EventListViewController.swift
//  My-Julia
//
//  Created by GCO on 08/03/2018.
//  Copyright © 2018 GCO. All rights reserved.
//

import UIKit
import Crashlytics

class EventListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,TKAlertDelegate, UISearchBarDelegate, CustomAlertViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var appVersionName: UILabel!

    var listArray:[EventModel] = []
    var searchListArray:[EventModel] = []

    var isSearching : Bool = false

    var downloadButtonTapped: ((EventsCustomCell) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = APP_NAME

        //Fetch event details data from Sqlite database and if it empty show error message
        self.listArray = DBManager.sharedInstance.fetchAllEventsListFromDB() as! [EventModel]

        //Update dyanamic height of tableview cell
        tableView.estimatedRowHeight = 300
        tableView.rowHeight = UITableViewAutomaticDimension

        //Remove extra lines from tableview
        self.tableView.tableFooterView = UIView()

        //App log out
        isAppLogin = false

        //Clear privious attendee and eventdetails
        EventData.sharedInstance.resetEventDetails()
        AttendeeInfo.sharedInstance.resetAttendeeDetails()

        //Show application version
        self.appVersionName.text = APP_VERSION

        //Open last open event automatically if attendee credential is stored
        let userCredential = CredentialHelper.shared.defaultCredential
        print("Default credential : ",userCredential?.user ?? "")
        CommonModel.sharedInstance.showActitvityIndicator()

        if userCredential?.user != nil {
            //Fetch login attendee details from database
            DBManager.sharedInstance.fetchLoginAttendeeDetailsFromDB(attendeeCode: (userCredential?.user)!)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        
        //Check logged in user details found or not in db
        if EventData.sharedInstance.eventId != "" {
            //Check last login attendee status and open event
            //self.checkLoginAttendeeStatus()

            //Check event is expire or not
             let result = DBManager.sharedInstance.checkEventDateIsExpiryInDB()
            if result == false {
                //Check last login attendee status and open event
                self.checkLoginAttendeeStatus()
            }
            else {
                print("Event Expire....")
                CommonModel.sharedInstance.dissmissActitvityIndicator()
                //Remove all credential off login in attendee
                CredentialHelper.shared.removeAllCredentials()
            }
        }
        else {
            CommonModel.sharedInstance.dissmissActitvityIndicator()
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UITableview Methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if self.isSearching == true {
            if self.searchListArray.count == 0 {
                return 1
            }
            else {
                return self.searchListArray.count
            }
        }
        else {
            return self.listArray.count
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return YES if you want the specified item to be editable.
        if self.isSearching == true {
            return false
        }
        else {
            return true
        }
    }

    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == UITableViewCellEditingStyle.delete {
            //Show confiramation alert before delete event from list
            self.showAlertView(indexPath: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        //Show empty cell
        if self.isSearching == true && self.searchListArray.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoDataFound", for: indexPath) as! EventsCustomCell
            return cell
        }
        else {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "EventsCustomCell", for: indexPath) as! EventsCustomCell
            cell.tag = indexPath.row
            return self.configureProfileCell(cell: cell, indexPath: indexPath)
        }
    }

    func configureProfileCell(cell : EventsCustomCell, indexPath : IndexPath) -> EventsCustomCell {
        let model : EventModel!
        if self.isSearching == false {
            model = self.listArray[indexPath.row] as EventModel
            cell.downloadBtn.setTitle("Open", for: .normal)

            if model.isPastEvent == true {
                cell.pastEventview.isHidden = false
                cell.currentEventview.alpha = 0.3
            }
            else {
                cell.pastEventview.isHidden = true
                cell.currentEventview.alpha = 1.0
            }
        }
        else {
            model = self.searchListArray[indexPath.row] as EventModel
            cell.downloadBtn.setTitle("Download", for: .normal)

            cell.pastEventview.isHidden = true
            cell.currentEventview.alpha = 1.0
        }

        cell.nameLabel?.text = model.eventName
        cell.addressLbl.text = model.eventVenue
        cell.datesLbl.text = CommonModel.sharedInstance.getEventDate(dateStr: model.eventStartDate).appendingFormat(" - %@", CommonModel.sharedInstance.getEventDate(dateStr: model.eventEndDate))

//        if !model.eventLogoUrl.isEmpty {
//            cell.imageview.sd_setImage(with: URL(string:model.eventLogoUrl), placeholderImage: #imageLiteral(resourceName: "event_icon"))
//        }
//        else  {
//            cell.imageview.image = #imageLiteral(resourceName: "event_icon")
//        }

        cell.downloadBtnTapped = { [unowned self] (selectedCell) -> Void in

            let customAlert = self.storyboard?.instantiateViewController(withIdentifier: "CustomAlertID") as! CustomAlertView
            customAlert.providesPresentationContextTransitionStyle = true
            customAlert.definesPresentationContext = true
            customAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            customAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            customAlert.delegate = self

            if self.isSearching == false {
                customAlert.eventId = self.listArray[selectedCell.tag].eventId
            }
            else {
                customAlert.eventId = self.searchListArray[selectedCell.tag].eventId
            }
            self.present(customAlert, animated: true, completion: nil)
        }

//        let blurEffect = UIBlurEffect(style: .light)
//        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
//        blurredEffectView.frame = cell.pastEventview.frame
//        blurredEffectView.backgroundColor = .gray
//        cell.addSubview(blurredEffectView)

        return cell
    }

    // MARK: - AlertView Methods

    func showAlertView( indexPath: IndexPath) {

        let refreshAlert = UIAlertController(title: "Delete event", message: "Are you sure want to delete event from list? ", preferredStyle: UIAlertControllerStyle.alert)

        refreshAlert.addAction(UIAlertAction(title: "YES", style: .default, handler: { (action: UIAlertAction!) in

            //Delete past event Data
            let model = self.listArray[indexPath.row] as EventModel?
            DBManager.sharedInstance.deleteEventAllDetails(eventId: (model?.eventId)!)

            self.listArray.remove(at: indexPath.row)
           // self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.bottom)
            self.tableView.reloadData()
        }))

        refreshAlert.addAction(UIAlertAction(title: "NO", style: .default, handler: { (action: UIAlertAction!) in
            refreshAlert .dismiss(animated: true, completion: nil)
        }))

        present(refreshAlert, animated: true, completion: nil)
    }

    // MARK: - Webservice Methods

    func searchEvent() {
        CommonModel.sharedInstance.showActitvityIndicator()
        print("Start searching event : ",CommonModel.sharedInstance.getCurrentDateInMM())

        let parameters : NSDictionary? = [ "SearchText": self.searchBar.text!]
        NetworkingHelper.postData(urlString:Search_Event_Url, param:parameters!, withHeader: false, isAlertShow: true, controller:self, callback: { [weak self] response in
            self?.isSearching = true
            print(" before parsing : ", CommonModel.sharedInstance.getCurrentDateInMM())

            //Remove all objects
            if self?.searchListArray.count != 0 {
                self?.searchListArray.removeAll()
            }

            if response is NSArray {
                self?.parseEventListData(response: response)
            }
            else {
            }

            print(" before stop indicator : ", CommonModel.sharedInstance.getCurrentDateInMM())
            CommonModel.sharedInstance.dissmissActitvityIndicator()
        }, errorBack: { error in
            NSLog("error in Auth token: %@", error)
            CommonModel.sharedInstance.dissmissActitvityIndicator()
        })
    }

    func parseEventListData(response: AnyObject) {
        for item in response as! NSArray {

            let  dict = item as! NSDictionary
            let model = EventModel()
            
            model.eventId = DBManager.sharedInstance.isNullString(str: dict.value(forKey: "EventId") as Any)
            model.eventName = DBManager.sharedInstance.isNullString(str: dict.value(forKey: "EventName") as Any)
            model.eventStartDate = DBManager.sharedInstance.isNullString(str: dict.value(forKey: "StartDateTime") as Any)
            model.eventEndDate = DBManager.sharedInstance.isNullString(str: dict.value(forKey: "EndDateTime") as Any)
            model.eventVenue = DBManager.sharedInstance.isNullString(str: dict.value(forKey: "Location") as Any)
            model.eventLogoUrl = DBManager.sharedInstance.appendImagePath(path: dict.value(forKey: "Logo_ImgPath") as Any)

            self.searchListArray.append(model)
        }
        self.tableView.reloadData()

     //   print("Search event list : ",self.searchListArray)
        print(" After parse list : ", CommonModel.sharedInstance.getCurrentDateInMM())
    }

    func getEventDetailsData() {
        CommonModel.sharedInstance.showActitvityIndicator()

        print("Login Auto token : ",EventData.sharedInstance.auth_token)

        NetworkingHelper.getRequestFromUrl(name:Get_Login_Details_Url, urlString: Get_Login_Details_Url, callback: { [weak self] response in
             //print("\nEvent Theme Details : ",response)
            print("Event login details : ",CommonModel.sharedInstance.getCurrentDateInMM())

            self?.getEventModuleData()

        }, errorBack: { error in
            CommonModel.sharedInstance.dissmissActitvityIndicator()
            CommonModel.sharedInstance.showAlertWithStatus(title: "Error", message: Internet_Error_Message, vc: self)
        })
    }

    func getEventModuleData() {
        CommonModel.sharedInstance.showActitvityIndicator()
        let urlStr = Get_AllModuleDetails_url.appendingFormat("Flag=%@",Get_AllDetails_url)

        NetworkingHelper.getRequestFromUrl(name:Get_AllModuleDetails_url, urlString: urlStr, callback: { [weak self] response in
            // print("\n All Data response Data - ",response)
            //Check login user status accepted terms and conditions
            print("Event module details : ",CommonModel.sharedInstance.getCurrentDateInMM())

            self?.checkLoginAttendeeStatus()
        }, errorBack: { error in
            CommonModel.sharedInstance.dissmissActitvityIndicator()
            CommonModel.sharedInstance.showAlertWithStatus(title: "Error", message: Internet_Error_Message, vc: self)
        })
    }

    func updateUserStaursDetails() {
        //Show Indicator
        CommonModel.sharedInstance.showActitvityIndicator()

        let parameters : NSMutableDictionary? = [ "AttendeeId": EventData.sharedInstance.attendeeId, "EventId":EventData.sharedInstance.eventId, "IsAccept" : true]

        NetworkingHelper.postData(urlString:Post_TermsAndCondition_Url, param:parameters!, withHeader: false, isAlertShow: true, controller:self, callback: { [weak self] response in
            //dismiss Indicator
            CommonModel.sharedInstance.dissmissActitvityIndicator()

            print("\n Terms and condition response : ", response)
            let responseCode = Int(response.value(forKey: "responseCode") as! String)

            if responseCode == 0 {
                EventData.sharedInstance.attendeeStatus = true

                //Update terms and condiiton status in database
                DBManager.sharedInstance.updateTermsAndCoditionsAttendeeStatusIntoDB()

                self?.navigateToNextScreen()
            }
        }, errorBack: { error in
            //dismiss Indicator
            CommonModel.sharedInstance.dissmissActitvityIndicator()
        })
    }

    // MARK: - Logical Methods

    func checkLoginAttendeeStatus() {

        //Call terms and condition accept view
        if EventData.sharedInstance.attendeeStatus == false {
            CommonModel.sharedInstance.dissmissActitvityIndicator()

            let alertView : TKAlert! = self.initialiseTermsAndConditionAlert()
            var vc : TermsAndConditionsViewController!
            if IS_IPAD {
                vc = TermsAndConditionsViewController(nibName: "TermsAndConditionViewController_iPad", bundle: nil)
            }
            else {
                vc = TermsAndConditionsViewController(nibName: "TermsAndConditionViewController_iPhone", bundle: nil)
            }
            vc.view.frame = CGRect(x: 0, y: 0, width:alertView.customFrame.size.width, height: alertView.customFrame.size.height)
            vc.scrollView.updateConstraints()
            alertView.contentView.addSubview(vc.view)
            alertView.delegate = self
            alertView.show(true)
        }
        else {
            self.navigateToNextScreen()
        }
    }


    func navigateToNextScreen() {
        print("navigateToNextScreen method : ",CommonModel.sharedInstance.getCurrentDateInMM())

        //App login
        isAppLogin = true

        //Fetch event details data from Sqlite database and if it empty show error message
        _ = DBManager.sharedInstance.fetchEventDetailsDataFromDB()
        _ = DBManager.sharedInstance.fetchProfileDataFromDB()

        //Fetch application theme data from Sqlite database
        _ = DBManager.sharedInstance.fetchAppThemeDataFromDB()

        // inject an authorisation header for images
        SDWebImageDownloader.shared().setValue("Basic ".appending(EventData.sharedInstance.auth_token), forHTTPHeaderField: "Authorization")

        //Apply navigation theme
        CommonModel.sharedInstance.applyNavigationTheme()

      //  CommonModel.sharedInstance.dissmissActitvityIndicator()

        let appDelegate = AppDelegate.getAppDelegateInstance();
        if IS_IPHONE {
            let leftMenuViewController = self.storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
            let navController = self.storyboard?.instantiateViewController(withIdentifier: "NavigationController") as! UINavigationController
            let container = MFSideMenuContainerViewController.container(withCenter: navController, leftMenuViewController: leftMenuViewController, rightMenuViewController: nil)
            appDelegate.window?.rootViewController = container
        }
        else {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SplitViewController") as! SplitViewController
            vc.preferredDisplayMode = .allVisible
            appDelegate.window?.rootViewController = vc
        }
    }

    // MARK: - Custom Terms and condition Methods

    func initialiseTermsAndConditionAlert() -> TKAlert {
        // >> alert-custom-content-swift
        var alert = TKAlert()
        alert.title = "Terms and Conditions"
        alert.style.headerHeight = 40

        alert.contentView.backgroundColor = .cyan
        alert.tintColor = UIColor(red: 0.5, green: 0.7, blue: 0.2, alpha: 1)

        var width : CGFloat = 320
        var height : CGFloat = 450
        if IS_IPAD {
            width = 550
            height = 700
        }

        alert.customFrame = CGRect(x: ((self.view.frame.size.width - width)/2), y: (self.view.frame.size.height - height)/2, width: width , height: height)

        alert.style.centerFrame = true

        // >> alert-animation-swift
        alert.style.showAnimation = TKAlertAnimation.scale;
        alert.style.dismissAnimation = TKAlertAnimation.scale;
        // << alert-animation-swift

        // >> alert-tint-dim-swift
        alert.style.backgroundDimAlpha = 0.7;
        alert.style.backgroundTintColor = UIColor.lightGray
        // << alert-tint-dim-swift

        // >> alert-anim-duration-swift
        alert.animationDuration = 0.3;
        // << alert-anim-duration-swift

        alert.addAction(withTitle: "Close") { (TKAlert, TKAlertAction) -> Bool in
            alert.dismiss(true)
            return true
        }

        alert.addAction(withTitle: "I Accept") { (TKAlert, TKAlertAction) -> Bool in

            //Update accept terms and condition to server
            self.updateUserStaursDetails()
            return true
        }
        return alert
    }

    // MARK: - UISearch bar delegate Methods

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        searchBar.resignFirstResponder()

        //Search event with search text
        self.searchEvent()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.isSearching = false

        //Remove all objects
        if self.searchListArray.count != 0 {
            self.searchListArray.removeAll()
        }

        self.searchBar.text = ""
        self.tableView.reloadData()
        searchBar.resignFirstResponder()
    }

// MARK: - Custom AlertView Delegate methods

    func loginButtonTapped(selectedOption: String, textFieldValue: String) {
        //Download event details

        //Save Login credintial in database
        DBManager.sharedInstance.saveLoginAttendeeDataIntoDB()

        //Store Attendee credential for auto login
        UserDefaults.standard.set("StoreCrential", forKey: "isAppUninstall")
        UserDefaults.standard.synchronize()
        CredentialHelper.shared.storeDefaultCredential(key: EventData.sharedInstance.attendeeCode, value: EventData.sharedInstance.eventId)

        self.getEventDetailsData()
    }

    func cancelButtonTapped() {
    }
}

// MARK: - Custom Cell Classes

class EventsCustomCell: UITableViewCell {

    var downloadBtnTapped: ((EventsCustomCell) -> Void)?

    @IBOutlet weak var nameLabel : UILabel!
    @IBOutlet weak var addressLbl : UILabel!
    @IBOutlet weak var datesLbl : UILabel!
    @IBOutlet weak var imageview : UIImageView!
    @IBOutlet var downloadBtn : UIButton!

    @IBOutlet weak var currentEventview : UIView!
    @IBOutlet weak var pastEventview : UIView!

    @IBAction func downloadBtnTapped(sender: AnyObject) {
        downloadBtnTapped?(self)
    }
}

