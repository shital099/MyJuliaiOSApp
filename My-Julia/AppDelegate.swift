//  AppDelegate.swift
//  My-Julia
//
//  Created by GCO on 5/15/17.
//  Copyright © 2017 GCO. All rights reserved.
//Commit branch
//Commit local branch to tfs

import UIKit
import UserNotifications

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
;
extension UIApplication {
    
    var statusBarView: UIView? {
        return value(forKey: "statusBar") as? UIView
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var deviceToken : String = ""
    var window: UIWindow?
     
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.


//        // do something with the notification
//        if launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] != nil {
//            // Do what you want to happen when a remote notification is tapped.
//            print("Notification in App launch : ", launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] ?? "")
//                // Fallback on earlier versions
//                let alert = UIAlertView()
//                alert.title = "Notification"
//            alert.message = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? String
//                alert.addButton(withTitle: "OK")
//                alert.delegate = self
//                alert.show()
//            //Save notification data into db and navigate to screen
//            //self.receivedNotification(application: application, data: launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as AnyObject)
//        }

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

        //Copy database table and data76
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
        
        //Remove all badges number
        UIApplication.shared.applicationIconBadgeNumber = 0

        //Status bar color
      //  self.setStatusBarBackgroundColor(color: .white)

       // salt=81D9B8148F5EA6C7
        let cryptoLib = CryptLib.sharedManager() as!  CryptLib
        cryptoLib.key = "23501748FEB710349F13763248DFC6C2"
        cryptoLib.iv = "abcdefghijklmnop"


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
            // iOS 8 support
        else if #available(iOS 8, *) {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
            // iOS 7 support
        else {  
            application.registerForRemoteNotifications(matching: [.badge, .sound, .alert])
        }

        return true;
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

    //MARK: - Prepare to Receive Notifications
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        completionHandler(.alert)
    }
    
    // Push notification received
    func application(_ application: UIApplication, didReceiveRemoteNotification data: [AnyHashable : Any]) {
        //Remove all badges number
        UIApplication.shared.applicationIconBadgeNumber = 0

        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)

        //If application not login in, don't show alert message
        if isAppLogin == false {
            return
        }

        //Save notification dat into db and navigate to screen
        //self.receivedNotification(application: application, data: data as AnyObject)
        print("Notification Received : ",data )

        if data is Dictionary<String, Any> {
            if (data["Chat"] != nil) {
                let body = data["Chat"]
                let alertBody = data["aps"] as? NSDictionary
                print("Chat notification : ",body )

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
                if application.applicationState == UIApplicationState.active {
                    let userDict:[String: Bool] = ["isClickOnNotification": false]
                    NotificationCenter.default.post(name: ChatNotification, object: "", userInfo: userDict)
                }
                else {
                    let userDict:[String: Bool] = ["isClickOnNotification": true]
                    NotificationCenter.default.post(name: ChatNotification, object: "", userInfo: userDict)
                }
                self.showNotificationAlertMessage(title: APP_NAME, message: decryptedMsg!, application: application)
            }
            else if (data["Notification"] != nil)
            {
                let alertBody = DBManager.sharedInstance.convertToJsonData(text: data["Notification"] as! String) as! NSDictionary
                //print("Notification body : ",alertBody )
                DBManager.sharedInstance.saveBroadCastNotification(data : alertBody)

                if application.applicationState == UIApplicationState.active {
                    let userDict:[String: Bool] = ["isClickOnNotification": false]
                    NotificationCenter.default.post(name: BroadcastNotification, object: "", userInfo: userDict)
                }
                else {
                    let userDict:[String: Bool] = ["isClickOnNotification": true]
                    NotificationCenter.default.post(name: BroadcastNotification, object: "", userInfo: userDict)
                }
                self.showNotificationAlertMessage(title: APP_NAME, message:  alertBody["Message"] as! String, application: application)
            }
            else {
               // print("Other notification : ",data)

                if (data["Wifi"] != nil) {
                    let alertBody = DBManager.sharedInstance.convertToJsonData(text: data["Wifi"] as! String) as! NSDictionary
                    DBManager.sharedInstance.saveWifiDataIntoDB(response: alertBody)
                }
                else if (data["Activity Feeds"] != nil) {
                    let alertBody = DBManager.sharedInstance.convertToJsonData(text: data["Activity Feeds"] as! String) as! NSDictionary
                    DBManager.sharedInstance.saveActivityFeedDataIntoDB(response: alertBody)
                }
                else if (data["Map"] != nil) {
                    let alertBody = DBManager.sharedInstance.convertToJsonData(text: data["Map"] as! String) as! NSDictionary
                    DBManager.sharedInstance.saveMapDataIntoDB(response: alertBody)
                }
                else if (data["Documents"] != nil) {
                    let alertBody = DBManager.sharedInstance.convertToJsonData(text: data["Documents"] as! String) as! NSDictionary
                    DBManager.sharedInstance.saveDocumentsDataIntoDB(response: alertBody)
                }

                let moduleId = data["ModuleId"] as? String
                if application.applicationState == UIApplicationState.active {
                    let alertBody = data["aps"] as? NSDictionary
                    self.showNotificationAlertMessage(title: APP_NAME, message:  alertBody!["alert"] as! String, application: application)

                    let imageDataDict:[String: String] = ["moduleId": moduleId!]
                    NotificationCenter.default.post(name: ShowNotificationCount, object: nil, userInfo: imageDataDict)
                }
                else {
                    let imageDataDict:[String: String] = ["moduleId": moduleId!]
                    NotificationCenter.default.post(name: OtherModuleNotification, object: nil, userInfo: imageDataDict)
                }
            }
        }
    }

    func receivedNotification(application: UIApplication, data : AnyObject) {
        if data is Dictionary<String, Any> {
            if (data["Chat"] != nil) {
                let body = data["Chat"]
                let alertBody = data["aps"] as? NSDictionary
              //  print("Chat notification : ",body )

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
                if application.applicationState == UIApplicationState.active {
                    let userDict:[String: Bool] = ["isClickOnNotification": false]
                    NotificationCenter.default.post(name: ChatNotification, object: "", userInfo: userDict)
                }
                else {
                    let userDict:[String: Bool] = ["isClickOnNotification": true]
                    NotificationCenter.default.post(name: ChatNotification, object: "", userInfo: userDict)
                }
                self.showNotificationAlertMessage(title: APP_NAME, message: decryptedMsg!, application: application)
            }
            else if (data["Notification"] != nil)
            {
                let alertBody = DBManager.sharedInstance.convertToJsonData(text: data["Notification"] as! String) as! NSDictionary
               // print("Notification body : ",alertBody )
                DBManager.sharedInstance.saveBroadCastNotification(data : alertBody)

                if application.applicationState == UIApplicationState.active {
                    let userDict:[String: Bool] = ["isClickOnNotification": false]
                    NotificationCenter.default.post(name: BroadcastNotification, object: "", userInfo: userDict)
                }
                else {
                    let userDict:[String: Bool] = ["isClickOnNotification": true]
                    NotificationCenter.default.post(name: BroadcastNotification, object: "", userInfo: userDict)
                }
                self.showNotificationAlertMessage(title: APP_NAME, message:  alertBody["Message"] as! String, application: application)
            }
            else {
               // print("Other notification : ",data)

                let moduleId = data["ModuleId"] as? String
                if application.applicationState == UIApplicationState.active {
                    let alertBody = data["aps"] as? NSDictionary
                    self.showNotificationAlertMessage(title: APP_NAME, message:  alertBody!["alert"] as! String, application: application)
                }
                else {
                    let imageDataDict:[String: String] = ["moduleId": moduleId!]
                    NotificationCenter.default.post(name: OtherModuleNotification, object: nil, userInfo: imageDataDict)
                }
            }
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

            alert.title = title
            alert.message = message
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
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.

        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getDeliveredNotifications(completionHandler: {(notifications: [UNNotification]) in
                print("All received Notifications : ",notifications)
            })
        } else {
            // Fallback on earlier versions
        }

    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        //Remove all badges number
        UIApplication.shared.applicationIconBadgeNumber = 0

       // DBManager.sharedInstance.copyDatabaseIntoDocumentsDirectory()
        
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
    
//    func keyboardWillShow(notification: NSNotification) {
//        
//        let vc = notification.object as! UIViewController
//        
//        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//            if vc.view.frame.origin.y == 0{
//                vc.view.frame.origin.y -= keyboardSize.height
//            }
//        }
//    }
//    
//    func keyboardWillHide(notification: NSNotification) {
//        
//        let vc = notification.object as! UIViewController
//
//        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//            if vc.view.frame.origin.y != 0{
//                vc.view.frame.origin.y += keyboardSize.height
//            }
//        }
//    }

}

