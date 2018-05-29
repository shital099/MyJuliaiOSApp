//
//  SideMenuViewController.swift
//  My-Julia
//
//  Created by GCO on 4/10/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit
import  UserNotifications
import UserNotificationsUI //framework to customize the notification

//protocol SideMenuControllerDelegate: class {
//    func sideMenuControllerDidHide(_ sideMenuController: SideMenuController)
//    func sideMenuControllerDidReveal(_ sideMenuController: SideMenuController)
//}

let OtherModuleNotification = NSNotification.Name(rawValue: "OpenNotificationReceived")
let ShowNotificationCount = NSNotification.Name(rawValue: "OtherNotificationReceived")
let UpdateNotificationCount = NSNotification.Name(rawValue: "UpdateNotificationCountReceived")

class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SideMenuControllerDelegate, TKAlertDelegate, UNUserNotificationCenterDelegate {
    
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var eventLogoImage: UIImageView!
    @IBOutlet weak var eventNameLbl: UILabel!
    @IBOutlet weak var eventButton: UIButton!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var logoBgView: UIView!
    @IBOutlet weak var profileBgView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userProfileIcon: UIImageView!
    @IBOutlet weak var appVersionName: UILabel!

    //    @IBOutlet weak var qrView: QRView!
    // var profileView: UserProfileView!
    var qrView: QRView!
    var profileVC : UserProfileViewController!
    
    //let queue = OperationQueue()
    var queue : OperationQueue! = nil
    var chatCount : Int = 0

    var menuArray : NSArray!
    var homeMenuArray : NSArray!
    var selectedIndexPath = IndexPath.init(row: -1, section: 0)
    var profileAlert : TKAlert!
    var qrCodeAlert : TKAlert!
    let timerObjectsArray : NSMutableArray = []

    let requestIdentifier = "SampleRequest" //identifier is to cancel the notification request

    override func viewDidLoad() {
        super.viewDidLoad()

        qrCodeAlert = self.initialiseAlert()
        profileAlert = self.initialiseAlert()
        
        userProfileIcon.layer.cornerRadius = userProfileIcon.frame.size.width / 2
        userProfileIcon.clipsToBounds = true

        //        self.createAlertView()
        //Apply navigation theme
        CommonModel.sharedInstance.applyNavigationTheme()

        //Show application version
        self.appVersionName.text = APP_VERSION

        self.setMenuList()
        
        self.triggerPopAfterActivityFinish()
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
    
    /*
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     }
     */
    
    override func viewDidAppear(_ animated: Bool) {

        //Add observer
        self.addNotificationObserver()
    }

    func addNotificationObserver()  {
        //Change notification and chat message read/unread count
//        NotificationCenter.default.addObserver(self, selector:#selector(MenuViewController.changeSideMenuCountInSideMenu(notification:)), name:BroadcastNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(MenuViewController.changeSideMenuCountInSideMenu(notification:)), name:ChatNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MenuViewController.openNotificationModuleScreenInSideMenu(notification:)), name:OtherModuleNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(MenuViewController.changeSideMenuUnreadMessageCount(notification:)), name:ShowNotificationCount, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MenuViewController.changeSideMenuNotificationCount(notification:)), name:UpdateNotificationCount, object: nil)

    }

    func toggleLeftSplitMenuController()  {
        
        if IS_IPHONE {
            self.menuContainerViewController.toggleLeftSideMenuCompletion {
                //self.setupMenuBarButtonItems()
            }
        }
        else {
            if self.splitViewController?.displayMode == UISplitViewControllerDisplayMode.primaryHidden {
                self.splitViewController?.preferredDisplayMode = UISplitViewControllerDisplayMode.allVisible
            }
            else {
                self.splitViewController?.preferredDisplayMode = UISplitViewControllerDisplayMode.primaryHidden
            }
        }

    }

    // MARK: - Operation queue oberver
    func setMenuList()  {
        
       // DispatchQueue.main.async  {
            //Change header color
            if IS_IPHONE {
                var navController = UINavigationController()
                //Back Button
                //            navController.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
                //            navController.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
                //            navController.navigationBar.backItem?.title = " "

                navController = (self.menuContainerViewController.centerViewController as? UINavigationController)!
                // Set Navigation bar background Image
                if AppTheme.sharedInstance.isHeaderColor == false {
                    if AppTheme.sharedInstance.headerImage != "" {
                        if let url = NSURL(string: AppTheme.sharedInstance.headerImage) {
                            var request = URLRequest(url: url as URL)
                            request.addValue("Basic ".appending(EventData.sharedInstance.auth_token), forHTTPHeaderField: "Authorization")
                            let queue = OperationQueue()

                            NSURLConnection.sendAsynchronousRequest(request, queue: queue) {
                                response, data, error -> Void in
                                if (data as NSData?) != nil {
                                    navController.navigationBar.setBackgroundImage(UIImage(data: (data)!), for: .default)
                                }
                            }
                        }
                    }
                    else {
                        navController.navigationBar.setBackgroundImage(nil, for: .default)
                        navController.navigationBar.barTintColor = AppTheme.sharedInstance.headerColor
                    }
                }
                else {
                    navController.navigationBar.setBackgroundImage(nil, for: .default)
                    navController = (self.menuContainerViewController.centerViewController as? UINavigationController)!
                    navController.navigationBar.barTintColor = AppTheme.sharedInstance.headerColor
                }

                //Apply back button color
                navController.navigationBar.tintColor = AppTheme.sharedInstance.headerTextColor

                //Apply header text color and Font
                let font : UIFont = UIFont.getFont(fontName: AppTheme.sharedInstance.headerFontName, fontStyle: AppTheme.sharedInstance.headerFontStyle, fontSize: CGFloat(AppTheme.sharedInstance.headerFontSize))

                navController.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:AppTheme.sharedInstance.headerTextColor, NSAttributedStringKey.font: font ]

                //add this line because chat bottom bar hides when image added on navigation bar
                UINavigationBar.appearance().isTranslucent = true
            }
            else {
                //        //Apply navigation theme
                CommonModel.sharedInstance.applyNavigationTheme()
                //navController = (self.splitViewController?.navigationController)!

            }

            SDImageCache.shared().clearMemory()
            SDImageCache.shared().clearDisk()

            //Show user porfile picture
            self.userProfileIcon.sd_setImage(with: URL(string:AttendeeInfo.sharedInstance.iconUrl), placeholderImage: UIImage(named: "user-profile"))

            //Remove background cache image path
            // if SDImageCache.shared().cachePath(forKey: AppTheme.sharedInstance.backgroundImage, inPath: AppTheme.sharedInstance.backgroundImage) != AppTheme.sharedInstance.backgroundImage {
            SDImageCache.shared().removeImage(forKey: AppTheme.sharedInstance.backgroundImage, withCompletion: nil)
            // }

            //Apply menu bckground theme color
            self.bgImageView.backgroundColor = AppTheme.sharedInstance.menuBackgroundColor

            //Apply navigation theme
            CommonModel.sharedInstance.applyNavigationTheme()

            //Check Event name and icon combination OR only icon
            if AppTheme.sharedInstance.isEventLogoIcon {
                self.iconImage.isHidden = false
                self.eventNameLbl.isHidden = false
                self.eventLogoImage.isHidden = true

                //Show event Details
                self.eventNameLbl.text = AppTheme.sharedInstance.logoText
                self.eventNameLbl.textColor = AppTheme.sharedInstance.eventNameTextColor
                self.eventNameLbl.font = UIFont.getFont(fontName: AppTheme.sharedInstance.iconTextFontName, fontStyle: AppTheme.sharedInstance.iconTextFontStyle, fontSize: CGFloat(AppTheme.sharedInstance.iconTextFontSize))

                SDImageCache.shared().removeImage(forKey: AppTheme.sharedInstance.eventIconImage, withCompletion: nil)
                self.iconImage.sd_setImage(with: NSURL(string:AppTheme.sharedInstance.eventIconImage as String)! as URL, placeholderImage: #imageLiteral(resourceName: "noImg_2"))
            }
            else {
                self.eventNameLbl.isHidden = true
                self.iconImage.isHidden = true
                self.eventLogoImage.isHidden = false
                SDImageCache.shared().removeImage(forKey: AppTheme.sharedInstance.eventLogoImage, withCompletion: nil)
                self.eventLogoImage.sd_setImage(with: NSURL(string:AppTheme.sharedInstance.eventLogoImage as String)! as URL, placeholderImage: #imageLiteral(resourceName: "noImg_2"))
            }


            //Remove all section
            //   drawer.removeAllSections()

            isMySchedulesPresent = false
            isAgendaPresent = false
            isMyNotesPresent = false
            isRemainderPresent = false
            isChatPresent = false

            //Fetch all module list from server
            self.menuArray = self.fetchModuleListFromDB()

            self.tableView.reloadData()
       // }

    }
    
    func fetchModuleListFromDB() -> NSArray {
        
        let drawer = TKSideDrawer()
        
        //Add First section - User related module data
        let section1:TKSideDrawerSection = drawer.addSection(withTitle: "MY ITEMS")
        let section2:TKSideDrawerSection = drawer.addSection(withTitle: "EVENT GUIDE")

        //Fetch data from Sqlite database
        let listArray : [Modules] = DBManager.sharedInstance.fetchModulesDataFromDB() as! [Modules]
        
        for data in listArray {
            
            let sideDrawerItem: SideDrawerMenu = SideDrawerMenu().addItemWithTitle(titleStr: data.name)
            //sideDrawerItem.moduleIndex = data.index
            sideDrawerItem.smallIconImage = data.sIconUrl
            sideDrawerItem.largeIconImage = data.lIconUrl
            sideDrawerItem.isCustomMenu = data.isCustomModule
            sideDrawerItem.fontName = AppTheme.sharedInstance.menuFontName
            sideDrawerItem.fontStyle = AppTheme.sharedInstance.menuFontStyle
            sideDrawerItem.fontSize = AppTheme.sharedInstance.menuFontSize
            sideDrawerItem.textColor = AppTheme.sharedInstance.menuTextColor
            sideDrawerItem.moduleId = data.moduleId
            sideDrawerItem.customModuleContent = data.moduleContent
            sideDrawerItem.dataCount = 0

            //remove icon cache images
            SDImageCache.shared().removeImage(forKey: sideDrawerItem.smallIconImage, withCompletion: nil)

            if data.isUserRelated == true {
                section1.addItem(sideDrawerItem)
                //Check My schedule, reminder and my notes menu added or not
                let viewController = CommonModel.sharedInstance.fetchViewControllerObject(moduleId: sideDrawerItem.moduleId)
                if viewController is AgendaViewController {
                    isMySchedulesPresent = true
                }
                else if viewController is MyNotesListViewController {
                    isMyNotesPresent = true
                }
                else if viewController is ReminderTableViewController {
                    isRemainderPresent = true
                }
            }
            else {
                //Check Agenda menu added or not
                let viewController = CommonModel.sharedInstance.fetchViewControllerObject(moduleId: sideDrawerItem.moduleId)
                if viewController is AgendaViewController {
                    isAgendaPresent = true
                }
                else if viewController is ChatListViewController {
                   sideDrawerItem.dataCount = DBManager.sharedInstance.fetchChatUnreadListCount()
                    isChatPresent = true
                }
                else if viewController is MapViewController {
                   sideDrawerItem.dataCount = DBManager.sharedInstance.fetchMapUnreadListCount()
                }
                else if viewController is DocumentsListViewController {
                    sideDrawerItem.dataCount = DBManager.sharedInstance.fetchUnreadDocumentCount()
                }
                else if viewController is WiFiViewController {
                    sideDrawerItem.dataCount = DBManager.sharedInstance.fetchUnreadWiFiCount()
                }
                else if viewController is ActivityFeedListViewController {
                    sideDrawerItem.dataCount = DBManager.sharedInstance.fetchUnreadActivityFeedsCount()
                }
                else if viewController is NotificationViewController {
                    sideDrawerItem.dataCount = DBManager.sharedInstance.fetchUnreadNotificationsCount()
                }

                section2.addItem(sideDrawerItem)
            }
        }
        return  drawer.sections! as NSArray
    }
    
    func initialiseAlert() -> TKAlert {
        // >> alert-custom-content-swift
        let alert = TKAlert()
        alert.style.headerHeight = 0
        
        alert.contentView.backgroundColor = .cyan
        alert.tintColor = UIColor(red: 0.5, green: 0.7, blue: 0.2, alpha: 1)
        
        var width : CGFloat = 300
        var height : CGFloat = 495
        if IS_IPAD {
            width = 450
            height = 600
        }
        
        alert.customFrame = CGRect(x: ((self.view.frame.size.width - width)/2), y: (self.view.frame.size.height - height)/2, width: width , height: height)
        
        alert.style.centerFrame = true
        
        // >> alert-animation-swift
        alert.style.showAnimation = TKAlertAnimation.scale;
        alert.style.dismissAnimation = TKAlertAnimation.scale;
        // << alert-animation-swift
        
        // >> alert-tint-dim-swift
        alert.style.backgroundDimAlpha = 0.5;
        alert.style.backgroundTintColor = UIColor.lightGray
        // << alert-tint-dim-swift
        
        // >> alert-anim-duration-swift
        alert.animationDuration = 0.3;
        // << alert-anim-duration-swift
        
        alert.addAction(withTitle: "Close") { (TKAlert, TKAlertAction) -> Bool in
            
            return true
        }
        
        return alert
    }
    
    func runTimedCode()  {
        if self.selectedIndexPath.row != -1 {
            //Call delegate method when menu item selected
            self.menuItemSelected(index: self.selectedIndexPath.row, section: self.selectedIndexPath.section)
        }
    }
    
    // MARK: - Button Action Method
    
    @IBAction func onClickOfEventDetails(_ sender: Any) {
        
        self.selectedIndexPath = IndexPath.init(row: -1, section: 0)
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "EventDetailsVC") as! EventDetailsVC
        
        if IS_IPHONE {
            self.menuContainerViewController.setMenuState(MFSideMenuStateClosed, completion: nil)
            let navController = self.menuContainerViewController.centerViewController as? UINavigationController
            navController?.viewControllers = NSArray().adding(viewController) as! [UIViewController]
        }
        else {
            let navVC = UINavigationController.init(rootViewController: viewController)
            splitViewController?.showDetailViewController(navVC, sender: nil)
        }
    }
    
    @IBAction func onClickOfUserProfile(_ sender: Any) {
        
        if self.profileVC != nil {
            self.profileVC.view.removeFromSuperview()
        }
        
        //Profile View
        if IS_IPAD {
            self.profileVC = UserProfileViewController(nibName: "UserProfileView_iPad", bundle: nil)
        }
        else {
            self.profileVC = UserProfileViewController(nibName: "UserProfileView_iPhone", bundle: nil)
        }
        
        self.profileVC.view.frame = CGRect(x: 0, y: 0, width:profileAlert.customFrame.size.width, height: profileAlert.customFrame.size.height)
        self.profileVC.alertView = self.profileAlert
        profileAlert.contentView.addSubview(self.profileVC.view)
        profileAlert.delegate = self
        profileAlert.show(true)
    }
    
    @IBAction func onClickOfQRCode(_ sender: Any) {
        
        if self.qrView != nil {
            self.qrView.removeFromSuperview()
        }
        
        //QR Code
        if IS_IPAD {
            self.qrView = Bundle.main.loadNibNamed("QR_iPad", owner: self, options: nil)?.last as! QRView
        }
        else {
            self.qrView = Bundle.main.loadNibNamed("QR", owner: self, options: nil)?.last as! QRView
        }
        
        //Show attendee name
        self.qrView.attendeeNameLbl.text = AttendeeInfo.sharedInstance.attendeeName
        qrCodeAlert.contentView.addSubview(self.qrView)
        qrCodeAlert.show(true)
    }
    
    @IBAction func onClickOfRefreshBtn(_ sender: Any) {
        //Show Indicator
        CommonModel.sharedInstance.showActitvityIndicator()
        print("Click on refresh button : ",CommonModel.sharedInstance.getCurrentDateInMM())

        self.getEventModuleData()
    }
    
    @IBAction func onClickOfBackBtn(_ sender: Any) {
        
        //let lJasopeftMenuViewController = self.storyboard?.instantiateViewController(withIdentifier: "InitalViewController") as! UINavigationController

        
        let refreshAlert = UIAlertController(title: "Switch event", message: "Are you sure want to switch event? ", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (action: UIAlertAction!) in

            //dissmiss Indicator
            CommonModel.sharedInstance.showActitvityIndicator()

            let paramDict = ["AttendeeId": EventData.sharedInstance.attendeeId ,"DeviceToken":AppDelegate.getAppDelegateInstance().deviceToken] as [String : Any]
            print("Log out parameter : ",paramDict)

                NetworkingHelper.postData(urlString:Logout_Url, param:paramDict as AnyObject, withHeader: false, isAlertShow: true, controller:self, callback: { [weak self] response in
                    //dissmiss Indicator
                    CommonModel.sharedInstance.dissmissActitvityIndicator()
                    print("Log out responce : ",response)
                    if response is NSDictionary {
                        let responseCode = Int(response.value(forKey: "responseCode") as! String)
                        if responseCode == 0 {
                            isAppLogin = false
                            //Remove notification observer
                            self?.clearAllObserver()

                            //Remove all credential off login in attendee
                            CredentialHelper.shared.removeAllCredentials()

                            //Default navigation bar color
                            CommonModel.sharedInstance.applyDefaultNavigationTheme()

                            //App log out
                            isAppLogin = false

                            //Clear privious attendee and eventdetails
                            EventData.sharedInstance.resetEventDetails()
                            AttendeeInfo.sharedInstance.resetAttendeeDetails()

                            let navController = self?.storyboard?.instantiateViewController(withIdentifier: "InitalViewController") as! UINavigationController
                            AppDelegate.getAppDelegateInstance().window?.rootViewController = navController
                        }
                    }
                }, errorBack: { error in
                })

        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
            refreshAlert .dismiss(animated: true, completion: nil)
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
    
    // MARK: - Profile Alert Delegate Methods
    
    func alertDidDismiss(_ alert: TKAlert) {
        
        //Show user profile picture
        if (!AttendeeInfo.sharedInstance.iconUrl.isEmpty) {
            SDImageCache.shared().removeImage(forKey: AttendeeInfo.sharedInstance.iconUrl, withCompletion: nil)
            self.userProfileIcon.sd_setImage(with: URL(string:AttendeeInfo.sharedInstance.iconUrl), placeholderImage: UIImage(named: "user-profile"))
        }
        else {
            self.userProfileIcon.image = UIImage(named: "user-profile")
        }
    }

    // MARK: - UITableView DataSource Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if menuArray != nil {
            return menuArray.count
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = menuArray[section] as! TKSideDrawerSection
        return section.items.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell") as! CustomHeaderCell
        headerCell.backgroundColor = AppTheme.sharedInstance.menuBackgroundColor.darker(by: 15)
        
        let section = menuArray[section] as! TKSideDrawerSection
        headerCell.headerLabel.text = section.title
        // headerCell.headerLabel.font = UIFont(name: AppTheme.sharedInstance.menuFontName, size: CGFloat(AppTheme.sharedInstance.menuFontSize - 4))
        headerCell.headerLabel.textColor = AppTheme.sharedInstance.menuTextColor
        
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath) as! MenuCustomCell
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
        
        let section = menuArray[indexPath.section] as! TKSideDrawerSection
        let item = section.items[indexPath.row] as! SideDrawerMenu
        
        cell.nameLabel?.text = item.moduleTitle
        cell.nameLabel.textColor = item.textColor
        cell.nameLabel.font = UIFont.getFont(fontName: item.fontName, fontStyle: item.fontStyle, fontSize: CGFloat(item.fontSize))

        //Show unread message count of chat 
        if item.dataCount == 0 {
            cell.countLabel.isHidden = true
        }
        else {
            //item.dataCount = self.chatCount
            cell.countLabel.isHidden = false
            cell.countLabel.text = String(format:"%d",item.dataCount)
            cell.countLabel.textColor = item.textColor
            cell.countLabel.backgroundColor = AppTheme.sharedInstance.menuBackgroundColor.darker(by: 15)
            cell.countLabel?.layer.cornerRadius = cell.countLabel.frame.size.height/2
            cell.countLabel?.layer.masksToBounds = true
        }
       // cell.countLabel.isHidden = true

        if item.isIconStyleColor == true {
            cell.imageview?.backgroundColor = item.iconColor
            cell.imageview?.image = nil
        }
        else {
            //SDImageCache.shared().removeImage(forKey: item.smallIconImage, withCompletion: nil)
            cell.imageview.sd_setImage(with: NSURL(string:item.smallIconImage as String)! as URL, placeholderImage: nil)
            cell.imageview?.backgroundColor = nil
         }
        
        if selectedIndexPath.row == indexPath.row && selectedIndexPath.section == indexPath.section {
            let lightColor = AppTheme.sharedInstance.menuBackgroundColor.getLighterColor()
            let darkerColor = AppTheme.sharedInstance.menuBackgroundColor.getDarkerColor()
            cell.setGradientColor(firstColor: lightColor, secondColor: darkerColor)
            
            //cell.setGradientColor(firstColor: .white, secondColor: .gray)
        }
        else {
            cell.setGradientColor(firstColor: .clear, secondColor: .clear)
        }
        
        return cell
    }
    
    // MARK: - UiTableView Delegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedIndexPath = indexPath
        tableView.reloadData()
        
        //Call delegate method when menu item selected
        self.menuItemSelected(index: indexPath.row, section: indexPath.section)
    }
    
    func menuItemSelected(index: NSInteger, section:NSInteger) {
        
        //Show selected row
        selectedIndexPath = IndexPath.init(row: index, section: section)
        tableView.reloadData()
        
        let tkSection = menuArray[section] as! TKSideDrawerSection
        
        //If selected menu deselect by admin then navigation to event detail screen
        if index >= tkSection.items.count {
            self.onClickOfEventDetails(self.eventButton)
            return
        }
        
        let item = tkSection.items[index] as! SideDrawerMenu
        var viewController : UIViewController
        //Show title on screen
        
        //If Custom Module added
        if item.isCustomMenu {
            viewController = self.storyboard?.instantiateViewController(withIdentifier: "CustomModuleViewController") as! CustomModuleViewController
            viewController.view.tag = index
            let vc = viewController as! CustomModuleViewController
            vc.contentStr = item.customModuleContent
        }
        else {
            
            viewController = CommonModel.sharedInstance.fetchViewControllerObject(moduleId: item.moduleId)
            viewController.view.tag = index

            if viewController is HomeViewController {
                let vc = viewController as! HomeViewController
                vc.homeIndex = index
                vc.delegate = self
            }
            
            //Check Note,
            if viewController is MyNotesListViewController {
                isMyNotesPresent = true
            }
            else if viewController is ReminderTableViewController {
                isRemainderPresent = true
            }
                //Check if myschedule selected
            else if viewController is AgendaViewController {
                if section == 0 {
                    let vc = viewController as! AgendaViewController
                    vc.isMySchedules = true
                }
            }
                //Check if myschedule selected
//            else if viewController is NotificationViewController {
//                    let vc = viewController as! NotificationViewController
//                    vc.changeNotificationCount()
//            }
        }
        
        viewController.title = item.moduleTitle
        //viewController.accessibilityValue = String(format:"%d",index)
        //viewController.view.tag = index         //Store row index

        if IS_IPHONE {
           // viewController.view.tag = index         //Store row index

            self.menuContainerViewController.setMenuState(MFSideMenuStateClosed, completion: nil)
            let navController = self.menuContainerViewController.centerViewController as? UINavigationController
            navController?.viewControllers = NSArray().adding(viewController) as! [UIViewController]
        }
        else {
            if viewController is UINavigationController {
                let navController = self.storyboard?.instantiateViewController(withIdentifier: "NavigationController") as! UINavigationController
                splitViewController?.showDetailViewController(navController, sender: nil)
            }
            else {
                let navVC = UINavigationController.init(rootViewController: viewController)
              //  viewController.view.tag = index         //Store row index
                splitViewController?.showDetailViewController(navVC, sender: nil)
            }
        }
        //}
    }
    
    func getEventModuleData() {
        NetworkingHelper.getRequestFromUrl(name:Get_AllModuleDetails_url, urlString: Get_AllModuleDetails_url.appendingFormat("Flag=%@",Get_AllDetails_url), callback: { [weak self] response in
          //  print("All Module data : ",response)
            self?.triggerPopAfterActivityFinish()

            print("After getting event modules data : ",CommonModel.sharedInstance.getCurrentDateInMM())
            //Fetch other details
            self?.getEventDetailsData()
            
        }, errorBack: { error in
            //Fetch other details
            self.getEventDetailsData()
        })
    }
    
    func getEventDetailsData() {
        
        NetworkingHelper.getRequestFromUrl(name:Get_Login_Details_Url, urlString: Get_Login_Details_Url, callback: { [weak self] response in
            
           // print("App theme data : ",response)
            print("After getting event details : ",CommonModel.sharedInstance.getCurrentDateInMM())

            //Fetch profile data
            _ = DBManager.sharedInstance.fetchProfileDataFromDB()
            
            //Fetch Event Details
            _ = DBManager.sharedInstance.fetchEventDetailsDataFromDB()
            
            //Fetch application theme data from Sqlite database
            _ = DBManager.sharedInstance.fetchAppThemeDataFromDB()

           // DispatchQueue.main.async {
                CommonModel.sharedInstance.dissmissActitvityIndicator()
            
                //Apply theme and data on list
                self?.setMenuList()
                
                if self?.selectedIndexPath.row != -1 {
                    let indexPath = IndexPath(row: (self?.selectedIndexPath.row)!, section: (self?.selectedIndexPath.section)!)
                    self?.tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition.none)
                    self?.tableView.delegate?.tableView!((self?.tableView)!, didSelectRowAt: indexPath)
                }
                else {
                    self?.onClickOfEventDetails(self?.eventButton)
                }

            print("After load event details on screen: ",CommonModel.sharedInstance.getCurrentDateInMM())

          //  }
        }, errorBack: { error in
            CommonModel.sharedInstance.dissmissActitvityIndicator()
            CommonModel.sharedInstance.showAlertWithStatus(title: "Error", message: Internet_Error_Message, vc: self)
        })
    }

    // MARK: - Notification observer Methods

   /* @objc func changeSideMenuCountInSideMenu(notification: NSNotification) {

        let moduleName = notification.name == BroadcastNotification ? "NotificationViewController" : "ChatListViewController"
        let moduleId = CommonModel.sharedInstance.fetchModuleIdOfModuleName(moduleName:moduleName)
        let moduleOrder = DBManager.sharedInstance.fetchModuleOrderFromDB(moduleId: moduleId)
        let modulesArray = self.menuArray.mutableCopy() as! NSMutableArray

        if moduleOrder != 0 {
            let indexPath = IndexPath.init(row: moduleOrder - 1, section: 1)
            let section = modulesArray[indexPath.section] as! TKSideDrawerSection
            //print("Module array count : ",section.items.count)
            if indexPath.row < section.items.count {
                let item = section.items[indexPath.row] as! SideDrawerMenu
                //print("Notification moduleOrder : ",moduleOrder)

                if notification.name == BroadcastNotification {
                    item.dataCount = DBManager.sharedInstance.fetchUnreadNotificationsCount()
                   // print("Broadcast data count : ",item.dataCount)
                }
                else {
                    item.dataCount = DBManager.sharedInstance.fetchChatUnreadListCount()
                  //  print("Chat data count : ",item.dataCount)
                }
                section.removeItem(item)
                section.insertItem(item, at: indexPath.row)
                modulesArray.replaceObject(at: indexPath.section, with: section)
                self.menuArray = modulesArray
                // self.tableView.reloadRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.automatic)

                //Click on notification
                if (notification.userInfo!["isClickOnNotification"] as! Bool == true) {

                    if self.selectedIndexPath.row != -1 {
                        self.tableView.reloadRows(at: [selectedIndexPath], with: UITableViewRowAnimation.automatic)
                    }

                    selectedIndexPath = indexPath
                    self.tableView.reloadRows(at: [selectedIndexPath as IndexPath], with: UITableViewRowAnimation.automatic)

                    //Call delegate method when menu item selected
                    self.menuItemSelected(index: selectedIndexPath.row, section: selectedIndexPath.section)
                }
                else {
                    self.tableView.reloadRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.automatic)
                }
            }
        }
    }*/

    @objc func changeSideMenuUnreadMessageCount(notification: NSNotification) {

        let section = self.menuArray[1] as! TKSideDrawerSection
        let array = section.items

        let predicate:NSPredicate = NSPredicate(format: "moduleId CONTAINS[c] %@", notification.userInfo!["moduleId"] as! String)
        let filteredArray = array?.filter { predicate.evaluate(with: $0) };

        if filteredArray?.count != 0 {
            let sideDrawerItem = filteredArray![0] as! SideDrawerMenu

            let viewController = CommonModel.sharedInstance.fetchViewControllerObject(moduleId: notification.userInfo!["moduleId"] as! String)

            //Check Agenda menu added or not
            if viewController is ChatListViewController {
                sideDrawerItem.dataCount = DBManager.sharedInstance.fetchChatUnreadListCount()
                isChatPresent = true
            }
            else if viewController is MapViewController {
                sideDrawerItem.dataCount = DBManager.sharedInstance.fetchMapUnreadListCount()
            }
            else if viewController is DocumentsListViewController {
                sideDrawerItem.dataCount = DBManager.sharedInstance.fetchUnreadDocumentCount()
            }
            else if viewController is WiFiViewController {
                sideDrawerItem.dataCount = DBManager.sharedInstance.fetchUnreadWiFiCount()
            }
            else if viewController is ActivityFeedListViewController {
               sideDrawerItem.dataCount = DBManager.sharedInstance.fetchUnreadActivityFeedsCount()
            }
            else if viewController is NotificationViewController {
                sideDrawerItem.dataCount = DBManager.sharedInstance.fetchUnreadNotificationsCount()
            }

//            let indexPath = IndexPath.init(row: sideDrawerItem.moduleIndex, section: 1)
//            self.tableView.reloadRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.automatic)

            self.tableView.reloadData()
        }
    }

    @objc func changeSideMenuNotificationCount(notification: NSNotification) {

        let flag = notification.userInfo!["Flag"] as! String
        let moduleOrder = notification.userInfo!["Order"] as! Int

        let section = self.menuArray[1] as! TKSideDrawerSection
        let sideDrawerItem = section.items![moduleOrder] as! SideDrawerMenu

        //Check Agenda menu added or not
        if flag == Update_Chat_List {
            sideDrawerItem.dataCount = DBManager.sharedInstance.fetchChatUnreadListCount()
        }
        else if flag == Update_Map_List {
            sideDrawerItem.dataCount = DBManager.sharedInstance.fetchMapUnreadListCount()
        }
        else if flag == Update_Documents_List {
            sideDrawerItem.dataCount = DBManager.sharedInstance.fetchUnreadDocumentCount()
        }
        else if flag == Update_WiFi_List {
            sideDrawerItem.dataCount = DBManager.sharedInstance.fetchUnreadWiFiCount()
        }
        else if flag == Update_Activity_Feeds_List {
            sideDrawerItem.dataCount = DBManager.sharedInstance.fetchUnreadActivityFeedsCount()
        }
        else if flag == Update_Broadcast_List {
            sideDrawerItem.dataCount = DBManager.sharedInstance.fetchUnreadNotificationsCount()
        }
        else {

            //Fetch all module data and update side menu list when app open in foreground
            for item in section.items {
                let sideDrawerItem = item as! SideDrawerMenu
                print("Before update Side menu count : ",sideDrawerItem.dataCount)

                let viewController = CommonModel.sharedInstance.fetchViewControllerObject(moduleId: sideDrawerItem.moduleId)

                if viewController is ChatListViewController {
                    sideDrawerItem.dataCount = DBManager.sharedInstance.fetchChatUnreadListCount()
                    isChatPresent = true
                }
                else if viewController is MapViewController {
                    sideDrawerItem.dataCount = DBManager.sharedInstance.fetchMapUnreadListCount()
                }
                else if viewController is DocumentsListViewController {
                    sideDrawerItem.dataCount = DBManager.sharedInstance.fetchUnreadDocumentCount()
                }
                else if viewController is WiFiViewController {
                    sideDrawerItem.dataCount = DBManager.sharedInstance.fetchUnreadWiFiCount()
                }
                else if viewController is ActivityFeedListViewController {
                    sideDrawerItem.dataCount = DBManager.sharedInstance.fetchUnreadActivityFeedsCount()
                }
                else if viewController is NotificationViewController {
                    sideDrawerItem.dataCount = DBManager.sharedInstance.fetchUnreadNotificationsCount()
                }

//                let indexPath = IndexPath.init(row: sideDrawerItem.moduleIndex, section: 1)
//                self.tableView.reloadRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.automatic)
            }
        }

        self.tableView.reloadData()
    }

    @objc func openNotificationModuleScreenInSideMenu(notification: NSNotification) {
        let moduleOrder = DBManager.sharedInstance.fetchModuleOrderFromDB(moduleId: notification.userInfo!["moduleId"] as! String) as Int

        if moduleOrder != 0 {

            //Refresh previous selected row
            if self.selectedIndexPath.row != -1 {
                self.tableView.reloadRows(at: [selectedIndexPath], with: UITableViewRowAnimation.automatic)
            }

            //create new selected row
            selectedIndexPath = IndexPath.init(row: moduleOrder - 1, section: 1)
//            self.tableView.reloadRows(at: [selectedIndexPath as IndexPath], with: UITableViewRowAnimation.automatic)

            //Call delegate method when menu item selected
            self.menuItemSelected(index: selectedIndexPath.row, section: selectedIndexPath.section)
        }
    }

    // MARK: - Activity Timer Methods
    func clearAllObserver() {
        
        //Remove all observer and invalite timers
        NotificationCenter.default.removeObserver(self)
        if timerObjectsArray.count != 0 {
            for timerObject in timerObjectsArray {
                let timer = timerObject as! Timer
                if timer.isValid {
                    timer.invalidate()
                }
            }
            timerObjectsArray.removeAllObjects()
        }
    }

    func triggerPopAfterActivityFinish() {
        
        //Remove all observer and invalite timers
        self.clearAllObserver()

        //Add observer
        self.addNotificationObserver()

       // let array = DBManager.sharedInstance.fetchCurrentActivity()
        let array = DBManager.sharedInstance.fetchAllCurrentAndFutureActivity()
        for item in array  {
            let model = item as! SessionsModel
            if model.sortActivityDate != nil {
                
                let timeInSec = Double(CommonModel.sharedInstance.getActivityTimeInSecond(dateStr: model.endActivityDate))
                if timeInSec != 0 {
                    let observerName = model.activityId
                   // print("Activity name :     time : ",model.activityName,timeInSec)
                    //Check Still activity is live or not
                    let timer = Timer.scheduledTimer(timeInterval: timeInSec, target: self, selector:  #selector(activityFinished(timer:)), userInfo: observerName, repeats: false)
                    timerObjectsArray.add(timer)
                    // Register to receive notification
                    NotificationCenter.default.addObserver(self, selector: #selector(showPopup(notification:)), name:NSNotification.Name(rawValue: observerName), object: nil)
                }
            }
        }
    }
    
    @objc func activityFinished(timer: Timer) {
        let notiName = timer.userInfo as! String
       // print("Activity Timer : ",notiName)
        if isLiveQuestionScreenOpen == false {
            // posting the notification
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: notiName), object: nil)
        }
        timer.invalidate()
    }
    
    @objc func showPopup(notification: NSNotification) {
        
        //Show feedback option
        if #available(iOS 8.0, *) {
            let activityName = DBManager.sharedInstance.fetchActivityNameFromDB(activityId:notification.name.rawValue)
            
            let alert = UIAlertController(title: "\(activityName) Session over", message: "Would you like to give feedback for this activity?", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Later on", style: UIAlertActionStyle.default, handler:{ (UIAlertAction)in
            }))
            alert.addAction(UIAlertAction(title: "Right now", style: UIAlertActionStyle.default, handler:{ (UIAlertAction)in
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ActivityFeedbackViewController") as! ActivityFeedbackViewController
                viewController.activityId = notification.name.rawValue
                viewController.isAgendaDetail = false

                //Remove row highlighted
                self.selectedIndexPath = IndexPath.init(row: -1, section: 0)
                self.tableView.reloadData()
                
                if IS_IPHONE {
                    self.menuContainerViewController.setMenuState(MFSideMenuStateClosed, completion: nil)
                    let navController = self.menuContainerViewController.centerViewController as? UINavigationController
                    navController?.viewControllers = NSArray().adding(viewController) as! [UIViewController]
                }
                else {
                    let navVC = UINavigationController.init(rootViewController: viewController)
                    self.splitViewController?.showDetailViewController(navVC, sender: nil)
                }
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}


// MARK: - Custom Cell Classes

class MenuCustomCell: UITableViewCell {
    
    @IBOutlet var nameLabel:UILabel!
    @IBOutlet var countLabel:UILabel!
    @IBOutlet var imageview:UIImageView!
    
    @IBOutlet var gradientView : GradientView?
    
    func setGradientColor(firstColor: UIColor, secondColor : UIColor) {
        gradientView?.colors = [
            firstColor,
            secondColor
        ]
    }
}

class CustomHeaderCell: UITableViewCell {
    @IBOutlet var headerLabel:UILabel!
}

