  //  AppDelegate.swift
//  My-Julia
//
//  Created by GCO on 5/15/17.
//  Copyright © 2017 GCO. All rights reserved.
//Commit branch
//Commit local branch to tfs

import UIKit
import UserNotifications
import Fabric
import Crashlytics

let IS_IPHONE = (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiom.phone);
let IS_IPAD = (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiom.pad);

//Split controller width for iPad
let SPLIT_WIDTH = CGFloat(250.0)

let CventRGB = UIColor.init(red: 164.0/255.0, green: 0/255.0, blue: 70.0/255.0, alpha: 1.0);

var APP_NAME : String = "" //Get Application name from info file
var APP_VERSION : String = "" //Get Application version from info file

var isDeviceOrientationPotrait: Bool = false
var isAppLogin: Bool = false
var currentChatAttendeeId: String = ""
var isMyNotesPresent : Bool = false
var isRemainderPresent : Bool = false
var isMySchedulesPresent : Bool = false
var isActivityFeedPresent : Bool = false
var isAgendaPresent : Bool = false
var profileSettingVisible : Bool = true
var isLiveQuestionScreenOpen : Bool = false
var isChatPresent : Bool = false


extension UIApplication {
    
    var statusBarView: UIView? {
        return value(forKey: "statusBar") as? UIView
    }
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var deviceToken : String = ""
    var window: UIWindow?
    var appIsStarting : Bool = true
    var isAppOpenFirstTime : Bool = true

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.


//        if #available(iOS 10.0, *) {
//            let center = UNUserNotificationCenter.current()
//            center.getDeliveredNotifications(completionHandler: { (notifications: [UNNotification]) in
//                print("Notifications : ",notifications)
//            })
//
//        } else {
//            // Fallback on earlier versions
//        }

        // do something with the notification
        if launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] != nil {
            // Do what you want to happen when a remote notification is tapped.
            print("Notification in App launch : ", launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] ?? "")
                // Fallback on earlier versions
            //Save notification data into db and navigate to screen
            //self.receivedNotification(application: application, userInfo: (launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as AnyObject) as! [AnyHashable : Any], pushNotiAllow: false)
        }

//        //Launched from push notification
//        let remoteNotif = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? NSDictionary
//        if remoteNotif != nil {
//            let aps = remoteNotif!["aps" as NSString] as? [String:AnyObject]
//            NSLog("\n Custom: \(String(describing: aps))")
//        }
//        else {
//            print("//////////////////////////Normal launch")
//        }

        //Get crash reports
        Fabric.with([Crashlytics.self])

        // TODO: Move this to where you establish a user session
        self.logUser()

        //Get application name and version
        let name: AnyObject? = Bundle.main.infoDictionary!["CFBundleDisplayName"] as AnyObject
        if (name as? NSNull) == nil {
            APP_NAME = name as! String
        }

        let version: AnyObject? = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as AnyObject
        if  (version as? NSNull) == nil {
            APP_VERSION = version as! String
        }

        //Clear keychain on first run in case of reinstallation

        if UserDefaults.standard.object(forKey: "isAppUninstall") == nil {
            // Delete values from keychain here
            CredentialHelper.shared.removeAllCredentials()
            UserDefaults.standard.synchronize()
        }

        //Copy database table and data
        DBManager.sharedInstance.copyFile(fileName: DATABASE_NAME)
        
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        if launchOptions != nil{
            let userInfo = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification]
            if userInfo != nil {
               // Perform action here
            }
        }
         
        //Requesting Authorization for User Interactions
        if #available(iOS 10.0, *) {
            _ = UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (granted, error) in // Enable or disable features based on authorization.
            }
        } else {
            // Fallback on earlier versions
        }
        

        //Status bar color
      //  self.setStatusBarBackgroundColor(color: .white)

       // salt=81D9B8148F5EA6C7
        let cryptoLib = CryptLib.sharedManager() as!  CryptLib
        cryptoLib.key = CRYPTO_KEY
        cryptoLib.iv = CRYPTO_IV


        // iOS 10 support
        if #available(iOS 10, *) {
            UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
            application.registerForRemoteNotifications()
        }
            // iOS 9 support
        else if #available(iOS 9, *) {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
        else {
            application.registerForRemoteNotifications(matching: [.badge, .sound, .alert])
        }


        //Check internet connection
        AFNetworkReachabilityManager.shared().setReachabilityStatusChange { (status: AFNetworkReachabilityStatus) -> Void in
            print("Network status.....",AFNetworkReachabilityManager.shared().isReachable)
        }
        AFNetworkReachabilityManager.shared().startMonitoring()

        //Remove all badges number
        UIApplication.shared.applicationIconBadgeNumber = 1
        UIApplication.shared.applicationIconBadgeNumber = 0

        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.removeAllPendingNotificationRequests() // To remove all pending notifications which are not delivered yet but scheduled.
            center.removeAllDeliveredNotifications() // To remove all delivered notifications
        } else {
            UIApplication.shared.cancelAllLocalNotifications()
        }

        let state : UIApplicationState = application.applicationState
        print("\nIn app delegate method app state : ",state.rawValue)

        return true;
    }

    func logUser() {
        // TODO: Use the current user's information
        // You can call any combination of these three methods
        Crashlytics.sharedInstance().setUserEmail("shital@gcotechcenter.com")
        Crashlytics.sharedInstance().setUserIdentifier("12345")
        Crashlytics.sharedInstance().setUserName("Shital")
    }


    func setStatusBarBackgroundColor(color: UIColor) {
        
        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
        
        statusBar.backgroundColor = color
    }
    
    
    @objc func rotated() {
        
        if IS_IPAD {
            
            if UIDeviceOrientationIsLandscape(UIDevice.current.orientation) {
                isDeviceOrientationPotrait = false
            }
            else if UIDeviceOrientationIsPortrait(UIDevice.current.orientation) {
                isDeviceOrientationPotrait = true
            }
        }
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if IS_IPAD {
            return UIInterfaceOrientationMask.all;
        }
        else {
            return UIInterfaceOrientationMask.portrait;
        }
    }


   // MARK: - Push Notification Delegate Methods
    
    // Called when APNs has assigned the device a unique token
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Convert token to string
        self.deviceToken = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
    }
    
    // Called when APNs failed to register the device for push notifications
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // Print the error to console (you should alert the user that registration failed)
    }

    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        print("Received memory warning.......")

        print("Before clear memory : ",SDImageCache.shared().getDiskCount())

       // SDImageCache.shared().clearDisk(onCompletion: {})

       // print("After clear memory : ",SDImageCache.shared().getDiskCount())

    }

    // Push notification received
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        //If application not login in, don't show alert message
        if isAppLogin == false {
            return
        }

        //Remove all badges number
        UIApplication.shared.applicationIconBadgeNumber = 0
        let state : UIApplicationState = application.applicationState

        print("Notification Received : ",userInfo )

        if (state == UIApplicationState.background ) {
            print("App is background")
            appIsStarting = false

            // app is background
            self.checkNotificationAllowStatus(application: application, userInfo: userInfo)
            completionHandler(UIBackgroundFetchResult.noData);
        }
        else if (state == UIApplicationState.inactive) {
            print("App is inactive")
               appIsStarting = true
            // user tapped notification
            self.checkNotificationAllowStatus(application: application, userInfo: userInfo)
            completionHandler(UIBackgroundFetchResult.newData);
        } else {
            // app is active
            print("App is active")
             appIsStarting = false
            self.checkNotificationAllowStatus(application: application, userInfo: userInfo)
            completionHandler(UIBackgroundFetchResult.noData);
        }

//        self.checkNotificationAllowStatus(application: application, userInfo: userInfo)

    }

    func checkNotificationAllowStatus(application: UIApplication, userInfo : [AnyHashable : Any]) {

        var pushNotiAllow = true

        //Check if remote push notifications are enabled in setting
        if #available(iOS 10.0, *) {
            let current = UNUserNotificationCenter.current()
            current.getNotificationSettings(completionHandler: { settings in

                if settings.authorizationStatus == .denied || settings.authorizationStatus == .notDetermined {
                    pushNotiAllow = false
                    print("in denied pushNotiAllow : ",pushNotiAllow)
                }
                else{
                    pushNotiAllow = true
                }

                DispatchQueue.main.async  {
                    if pushNotiAllow == true {
                        self.receivedNotification(application: application, userInfo: userInfo, pushNotiAllow: pushNotiAllow)
                    }
                }
            })
        }
        else {
            // Fallback on earlier versions
            if UIApplication.shared.isRegisteredForRemoteNotifications {
                print("APNS-YES")
                pushNotiAllow = true
            }
            else {
                print("APNS-NO")
                pushNotiAllow = false
            }

            DispatchQueue.main.async  {
                if pushNotiAllow == true {
                    self.receivedNotification(application: application, userInfo: userInfo, pushNotiAllow: pushNotiAllow)
                }
            }
        }
    }

    func receivedNotification(application: UIApplication, userInfo : [AnyHashable : Any], pushNotiAllow : Bool ) {

        print("pushNotiAllow : ",pushNotiAllow)

        //Save notification dat into db and navigate to screen
        if (userInfo["Chat"] != nil) {
            let body = userInfo["Chat"]
            let alertBody = userInfo["aps"] as? NSDictionary

            let chatM = DBManager.sharedInstance.convertToJsonData(text: body as! String) as? NSDictionary
            let message = DBManager.sharedInstance.isNullString(str: chatM?["Message"] as Any)
            var decryptedMsg = (CryptLib.sharedManager() as AnyObject).decryptCipherText(with: message)

            //Chat Image notification
            if alertBody!["alert"] as! String == "Photo" || decryptedMsg == ""{
                decryptedMsg = "Photo"
            }

            //Skip notification bar while receiving message from same chat with attendee
            if currentChatAttendeeId != "" {
                if  ((chatM?["GroupChatId"] as? NSNull) == nil) {
                    if currentChatAttendeeId == chatM?.value(forKey: "GroupChatId") as! String {
                        // NotificationCenter.default.post(name: Notification.Name("ChatMessageNotificationId"), object: body)
                        return
                    }
                }
                else if currentChatAttendeeId == chatM?.value(forKey: "FromId") as! String  {
                    //  NotificationCenter.default.post(name: Notification.Name("ChatMessageNotificationId"), object: body)
                    return
                }
            }

            //Save chat details into db
            DBManager.sharedInstance.saveChatNotificationMessageIntoDB(response: chatM!)
        }
        else if (userInfo["Notification"] != nil) {
            let alertBody = DBManager.sharedInstance.convertToJsonData(text: userInfo["Notification"] as! String) as! NSDictionary
            DBManager.sharedInstance.saveBroadCastNotification(data: alertBody)
        }
        else if (userInfo["Wifi"] != nil) {
            let alertBody = DBManager.sharedInstance.convertToJsonData(text: userInfo["Wifi"] as! String) as! NSDictionary
            DBManager.sharedInstance.saveWifiDataIntoDB(response: alertBody, isNoticationData: false)
        }
        else if (userInfo["Activity Feeds"] != nil) {
            let alertBody = DBManager.sharedInstance.convertToJsonData(text: userInfo["Activity Feeds"] as! String) as! NSDictionary
            DBManager.sharedInstance.saveActivityFeedDataIntoDB(response: alertBody)
        }
        else if (userInfo["Map"] != nil) {
            let alertBody = DBManager.sharedInstance.convertToJsonData(text: userInfo["Map"] as! String) as! NSDictionary
            DBManager.sharedInstance.saveMapDataIntoDB(response: alertBody, isNoticationData: false)
        }
        else if (userInfo["Documents"] != nil) {
            let alertBody = DBManager.sharedInstance.convertToJsonData(text: userInfo["Documents"] as! String) as! NSDictionary
            DBManager.sharedInstance.saveDocumentsDataIntoDB(response: alertBody, isNoticationData: false)
        }

//        let state : UIApplicationState = application.applicationState
//        if (state == UIApplicationState.background ) {
//                        print("App is background")
//                        // app is background
//                        self.checkNotificationAllowStatus(application: application, userInfo: userInfo)
//                        completionHandler(UIBackgroundFetchResult.noData);
//                    }
//                    else if (state == UIApplicationState.inactive && !self.appIsStarting) {
//                        print("App is inactive")
//                        // user tapped notification
//                        self.checkNotificationAllowStatus(application: application, userInfo: userInfo)
//                        completionHandler(UIBackgroundFetchResult.noData);
//                    } else {
//                        // app is active
//                        print("App is active")
//                        self.checkNotificationAllowStatus(application: application, userInfo: userInfo)
//                        completionHandler(UIBackgroundFetchResult.newData);
//                    }

        let moduleId = userInfo["ModuleId"] as? String
        if self.appIsStarting == false {
            let alertBody = userInfo["aps"] as? NSDictionary

            //If notication is allow for application then show pop
            if pushNotiAllow == true {
                if !isAppOpenFirstTime {
                    self.showNotificationAlertMessage(title: APP_NAME, message:  alertBody!["alert"] as! String, application: application)
                }
            }

            let imageDataDict:[String: String] = ["moduleId": moduleId!]
            NotificationCenter.default.post(name: ShowNotificationCount, object: nil, userInfo: imageDataDict)
        }
        else {
            let imageDataDict:[String: String] = ["moduleId": moduleId!]
            NotificationCenter.default.post(name: ShowNotificationCount, object: nil, userInfo: imageDataDict)
           // if !isAppOpenFirstTime {
                NotificationCenter.default.post(name: OtherModuleNotification, object: nil, userInfo: imageDataDict)
           // }
        }
    }

    func showNotificationAlertMessage(title : String, message : String, application: UIApplication)  {

        //Show custom notification popup when application is running state and receive notification
        if application.applicationState == UIApplicationState.active {

            let alert = TKAlert()

            alert.style.headerHeight = 0

            alert.customFrame = CGRect(x: 20, y: 20, width: (self.window?.frame.size.width)! - 40, height: 100)
            let topView = Bundle.main.loadNibNamed("NotificationView", owner: self, options: nil)?.last as! NotificationView
            topView.appNameLbl.text = title
            topView.message.text = message
            alert.contentView.addSubview(topView)

            alert.style.contentSeparatorWidth = 8
            alert.style.titleColor = UIColor.white
            alert.style.messageColor = UIColor.white
            alert.style.cornerRadius = 5.0
            alert.style.showAnimation = TKAlertAnimation.slideFromTop
            alert.style.dismissAnimation = TKAlertAnimation.slideFromTop

            // >> alert-bg-swift
            alert.style.backgroundStyle = TKAlertBackgroundStyle.none
            // << alert-bg-swift

            // >> alert-layout-swift
            alert.actionsLayout = TKAlertActionsLayout.vertical
            // << alert-layout-swift

            //  alert.alertView.autoresizingMask = UIViewAutoresizing.flexibleWidth

            // >> alert-dismiss-swift
            alert.dismissMode = TKAlertDismissMode.tap
            // << alert-dismiss-swift

            alert.title = title as NSString
            alert.message = message as NSString
            //        alert.headerView.textLabel.textColor = AppTheme.sharedInstance.menuTextColor
            //        alert.contentView.fill = TKSolidFill(color: AppTheme.sharedInstance.menuBackgroundColor)
            //        alert.headerView.fill = TKSolidFill(color: AppTheme.sharedInstance.menuBackgroundColor)

            alert.contentView.fill = TKSolidFill(color: .clear)
            alert.headerView.fill = TKSolidFill(color: .clear)

            alert.dismissTimeout = 4

            alert.contentView.layer.borderColor = UIColor.gray.cgColor
            alert.contentView.layer.cornerRadius = 5.0
            alert.contentView.layer.borderWidth = 1.0

            alert.show(true)
        }
    }

    //MARK: - UIApplication Methods

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
         //self.appIsStarting = false
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
       // self.appIsStarting = false

    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        //self.appIsStarting = true

        //Refresh side menu count when application enter foreground
        if isAppLogin == true {
            let dataDict:[String: Any] = ["Order": 0, "Flag":Update_SideMenu_List]
            NotificationCenter.default.post(name: UpdateNotificationCount, object: nil, userInfo: dataDict)
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
       // self.appIsStarting = false

        self.isAppOpenFirstTime = false

        //Remove all badges number
        UIApplication.shared.applicationIconBadgeNumber = 1
        UIApplication.shared.applicationIconBadgeNumber = 0

        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.removeAllPendingNotificationRequests() // To remove all pending notifications which are not delivered yet but scheduled.
            center.removeAllDeliveredNotifications() // To remove all delivered notifications
        } else {
            UIApplication.shared.cancelAllLocalNotifications()
        }

        //Create database
        if DBManager.sharedInstance.createDatabase() {
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    static func getAppDelegateInstance() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate;
    }
    
    func setupMenuBarButtonItems(vc: UIViewController) {
        
        // self.navigationItem.rightBarButtonItem = self.rightMenuBarButtonItem()
        
        if vc.menuContainerViewController.menuState == MFSideMenuStateClosed && !((vc.navigationController?.viewControllers.first?.isEqual(self))!) {
            vc.navigationItem.leftBarButtonItem = self.leftMenuBarButtonItem()
        }
        else {
            vc.navigationItem.leftBarButtonItem = self.leftMenuBarButtonItem()
        }
    }
    
    func rightMenuBarButtonItem()-> UIBarButtonItem {
        return UIBarButtonItem(image: UIImage(named: "menu"), style: .plain, target: self, action: #selector(self.leftSideMenuButtonPressed(sender:))) // action:#selector(Class.MethodName) for swift 3
    }
    
    func leftMenuBarButtonItem()-> UIBarButtonItem {
        return UIBarButtonItem(image: UIImage(named: "menu"), style: .plain, target: self, action: #selector(self.leftSideMenuButtonPressed(sender:))) // action:#selector(Class.MethodName) for swift 3
    }
    
    // MARK: - Navigation UIBarButtonItems
    @objc func leftSideMenuButtonPressed(sender: UIBarButtonItem) {
        //        self.menuContainerViewController.toggleLeftSideMenuCompletion {
        //            self.setupMenuBarButtonItems()
        //        }
    }
    
    func dateComponentFromNSDate(_ date: Date)-> DateComponents{
        
        let calendarUnit: NSCalendar.Unit = [.hour, .day, .month, .year]
        let dateComponents = (Calendar.current as NSCalendar).components(calendarUnit, from: date)
        return dateComponents
    }

}

