//
//  CommonModelModel.swift
//  EventApp
//
//  Created by GCO on 5/15/17.
//  Copyright © 2017 GCO. All rights reserved.


import UIKit


//let APP_NAME = "My Julia"
//let APP_VERSION = "1.0"

let DATABASE_NAME = "database.sqlite"
let Enter_Event_Key = "Please enter valid attendee code"
let Event_Error_Message = "Please enter valid attendee code"

//General
let Internet_Error_Message = "There was a problem connecting to the server. Please check your internet connection and try again."
let Internal_Server_Error_Message = "Internet server error"
let ServerConnection_Error_Message = "There was a problem connecting to the server. Please check your internet connection and try again."
let Server_Error_Message = "Failed!"
let Alert_Error = "Failed"
let Alert_Warning = "Warning"
let Alert_Sucess = "Success"

//Login
let Confirm_Attendee_code = "One time passsword has been sent on your registered email. Please enter OTP to download event."
let Invalid_OTP_title = "Login failed"
let OTP_Session_Expired = "Sorry, login invalid due to multiple invalid OTP attempts. Please go back to event list screen and relogin to get new OTP then try again later."


//Agenda
let Deleted_Agenda_Text = "Removed from My Schedule"
let Added_Agenda_Text = "Added into My Schedule"
let Agenda_Sucess = "\n Sucess"
let Activity_Feedback_submitted = "You have already submitted the feedback"
let Activity_No_Feedback_Added = "No feedback questions added"

//Note
let Note_Sucess = "\n Note added successfully."
let Note_Update = "\n Note updated successfully."

//Activity Feed
let Enter_Comment_Text = "Comment should not be blank"
let Enter_ActivityFeed_Post_Message = "Please enter some message"

//Profile
let Failed_Update_Profile = "Profile update failed. Try sometime later"
let Sucess_Update_Profile = "Profile setting updated successfully."

//Feedback
let Feedback_Empty_Message = "Please answer atleast one question to submit the feedback form"
let Feedback_Error_Message = "Opps! Something went wrong"
let Feedback_Sucess_Message = "Thank you for giving feedback."

//Poll
let Poll_Error_Message = "Opps! Something went wrong"
let Poll_Sucess_Message = "Thank you for giving feedback."
let Poll_Empty_Message = "Please answer the question to submit the poll"
let No_Poll_Question_Text = "No Live Polling questions Added"
let No_Poll_History_Text = "No Poll History Available"
let Poll_Question_Add = "Poll added successfully"
let Update_Poll_success = "Poll updated successfully"
let Update_Error_Message = "Question already exists"


//Add Speaker Poll
let No_Question_Message = "Question is required"
let No_Option1_Message = "Option 1 is required"
let No_Option2_Message = "Option 2 is required"
let No_Option3_Message = "Option 3 is required"
let No_Option4_Message = "Option 4 is required"

//Queationlet
let Ask_Valid_Question = "Question can't be post empty"

//Chat
let Empty_Group_Member_Message = "Please select atleast one group member"
let Empty_Group_Name_Message = "Please enter group name"
let Disable_chat_message = "You can't send messages because this user 'Do not disturb' setting is activated"

//Reminder
let No_Reminder_Text = "No Reminder Added"

//No Data
let No_Data_Text = "No Data Added"

//Question and Chat
let Question_History_Time = 5
let Chat_History_Time = 5
let Question_Sent_Message = "Message sent sucessfully"

//Activity Feeds
let Activity_Page_Limit = 15            //Set default limit 20 in server and application

//Feedback
let Event_Feedback_submitted = "You have already submitted the feedback"

enum TKAlertType : NSInteger {
    case TKAlertTypeSucess = 0
    case TKAlertTypeError
    case TKAlertTypeWarning
};

class CommonModel: NSObject {
    
    // Can't init is singleton
    private override init() { }
    
    //MARK: Shared Instance
    
    static let sharedInstance: CommonModel = CommonModel()
    
    static let RowHighlightColour = AppTheme.sharedInstance.backgroundColor.darker(by:20)

    //MARK: Local Variable
    
    var emptyStringArray : [String] = []
    
    //Activity indicator
    var activityHUD = CCActivityHUD()

    let colors = [
        UIColor(red:0.478, green:0.988, blue:0.157, alpha:1),
        UIColor(red: 1, green: 0, blue: 0.282, alpha: 1),
        UIColor(red:1, green:0.733, blue:0, alpha:1),
        UIColor(red:0.231, green:0.678, blue:1, alpha:1)]
    
    //Use this methos in SplitViewController for iPad
    // MARK: - SplitViewController UIBarButtonItems
    //    func menuBarButtonItem(splitController: UISplitViewController) -> UIBarButtonItem {
    //
    //        return  UIBarButtonItem(image: UIImage(named: "menu"), style: (splitController.displayModeButtonItem.style), target: (splitController.displayModeButtonItem.target), action: (splitController.displayModeButtonItem.action)!)
    //    }
    
    
    //Use this methos in Side Menu for iPhone
    // MARK: - Side Menu Navigation UIBarButtonItems
    
    func leftMenuBarButtonItem()-> UIBarButtonItem {
        return UIBarButtonItem(image: UIImage(named: "menu"), style: .plain, target: nil, action:nil) // action:#selector(Class.MethodName) for swift 3
    }
    
    // MARK: - AlertView Method
    
    func showAlertWithStatus(title: String,  message: String, vc:UIViewController ) {
        NSLog("Alert Message :%@", message)
        
        if #available(iOS 8.0, *) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{ (UIAlertAction)in
            }))
            
            vc.present(alert, animated: true, completion: nil)
        } else {
            // Fallback on earlier versions
            let alert = UIAlertView()
            alert.title = ""
            alert.message = message
            alert.addButton(withTitle: "OK")
            alert.delegate = self
            alert.show()
        }
    }
    
    
    // MARK: - Table Animation Method
    
    func animateTable(tableView : UITableView) {
        tableView.reloadData()
        
        let cells = tableView.visibleCells
        let tableHeight: CGFloat = tableView.bounds.size.height
        
        for i in cells {
            let cell: UITableViewCell = i as UITableViewCell
            cell.transform = CGAffineTransform(translationX: 0, y: tableHeight)
        }
        
        var index = 0
        
        for a in cells {
            let cell: UITableViewCell = a as UITableViewCell
            UIView.animate(withDuration: 1.8, delay: 0.05 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
                cell.transform = CGAffineTransform(translationX: 0, y: 0);
            }, completion: nil)
            
            index += 1
        }
    }
    
    // MARK: - Activity indicator Method
    
    func showActitvityIndicator() {
        
        activityHUD.isTheOnlyActiveView = true
        self.activityHUD.appearAnimationType = CCActivityHUDAppearAnimationType.zoomIn
        activityHUD.show()
        
        // activityHUD.showWithType = CCActivityHUDIndicatorTypeMinorArcWithCircle
    }
    
    func dissmissActitvityIndicator(status: Bool) {
        
        if status {
            activityHUD.dismiss(withText: "dismiss", delay: 0.2, success: true)
        }
        else {
            activityHUD.dismiss()
        }
    }

    func dissmissActitvityIndicator() {
        
        activityHUD.dismiss()
    }
    
    func showAlertNotification(view : UIView, title : String, message: String, alertType: NSInteger) {
        
        let alert = TKAlert()
        
        //        if IS_IPAD {
        //            alert.customFrame = CGRect(x: view.frame.origin.x + SPLIT_WIDTH, y: 0, width: view.frame.size.width, height: 140)
        //        }
        //        else {
        //            alert.customFrame = CGRect(x: view.frame.origin.x, y: 0, width: view.frame.size.width, height: 140)
        //        }

        if AppDelegate.getAppDelegateInstance().window?.frame.size.width == view.frame.size.width {
            alert.customFrame = CGRect(x: view.frame.origin.x, y: 0, width: view.frame.size.width, height: 140)
        }
        else {
            alert.customFrame = CGRect(x: view.frame.origin.x + SPLIT_WIDTH, y: 0, width: view.frame.size.width, height: 140)
        }

        alert.style.contentSeparatorWidth = 0
        // alert.style.titleColor = UIColor.white
        //alert.style.messageColor = UIColor.white
        alert.style.titleColor = AppTheme.sharedInstance.menuTextColor
        alert.style.messageColor = AppTheme.sharedInstance.menuTextColor

        alert.style.cornerRadius = 0
        alert.style.showAnimation = TKAlertAnimation.slideFromTop
        alert.style.dismissAnimation = TKAlertAnimation.slideFromTop
        
        // >> alert-bg-swift
        alert.style.backgroundStyle = TKAlertBackgroundStyle.none
        // << alert-bg-swift
        
        // >> alert-layout-swift
        alert.actionsLayout = TKAlertActionsLayout.vertical
        // << alert-layout-swift
        
        alert.alertView.autoresizingMask = UIViewAutoresizing.flexibleWidth
        
        // >> alert-dismiss-swift
        alert.dismissMode = TKAlertDismissMode.tap
        // << alert-dismiss-swift
        
        alert.title = title
        alert.message = message
        //alert.contentView.fill = TKSolidFill(color: colors[alertType])
        //alert.headerView.fill = TKSolidFill(color: colors[alertType])
        alert.contentView.fill = TKSolidFill(color: AppTheme.sharedInstance.menuBackgroundColor)
        alert.headerView.fill = TKSolidFill(color: AppTheme.sharedInstance.menuBackgroundColor)
        
        alert.dismissTimeout = 2.0
        alert.show(true)
    }
    
    // MARK: - Navigation Method

    func applyTableSeperatorColor(object : AnyObject)  {
        
        if object is UITableView {
            let table = object as! UITableView
            table.separatorColor = AppTheme.sharedInstance.backgroundColor.darker(by:10)
        }
        else if object is UIImageView {
            let view = object as! UIImageView
            view.backgroundColor = AppTheme.sharedInstance.backgroundColor.darker(by:10)
        }
    }
    
    
    // MARK: - Navigation Method
    
    func fetchViewControllerObject(moduleId: String ) -> UIViewController {
        
        let predicate:NSPredicate = NSPredicate(format: "ModuleID CONTAINS[c] %@", moduleId)
        // var result:NSArray = ModulesIdClass.sharedInstance.moduleIdsListArray.filteredArrayUsingPredicate(predicate)
        let filteredArray = ModulesID.sharedInstance.ModuleIDsListArray.filter { predicate.evaluate(with: $0) };
        
        var vc : UIViewController? = nil
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if filteredArray.count != 0 {
            let dict = filteredArray.first
            if !((dict?["ClassName"]?.isEmpty)!) {
                vc = storyboard.instantiateViewController(withIdentifier: String(format: "%@", dict!["ClassName"]!))
            }
        }
        else {
            vc = storyboard.instantiateViewController(withIdentifier: "CustomModuleViewController")
        }
        
        return vc!
    }

    func fetchModuleIdOfModuleName(moduleName: String ) -> String {

        let predicate:NSPredicate = NSPredicate(format: "ClassName CONTAINS[c] %@", moduleName)
        let filteredArray = ModulesID.sharedInstance.ModuleIDsListArray.filter { predicate.evaluate(with: $0) };

        if filteredArray.count != 0 {
            let dict = filteredArray.first
            if !((dict?["ModuleID"]?.isEmpty)!) {
                return dict!["ModuleID"]!
            }
        }
        return ""
    }
    
    func applyNavigationTheme()  {
        
        //Apply back button color
        UINavigationBar.appearance().tintColor = AppTheme.sharedInstance.headerTextColor
        
        //Back Button
        UINavigationBar.appearance().backIndicatorImage = UIImage(named: "nav_back_button")
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        UINavigationBar.appearance().backItem?.title = " "
        //Remove default title of back button
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffsetMake(0, -60), for:UIBarMetrics.default)
       
        //Apply header text color and Font
        let font : UIFont = UIFont.getFont(fontName: AppTheme.sharedInstance.headerFontName, fontStyle: AppTheme.sharedInstance.headerFontStyle, fontSize: CGFloat(AppTheme.sharedInstance.headerFontSize))
        
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor:AppTheme.sharedInstance.headerTextColor, NSAttributedStringKey.font: font ]

        if AppTheme.sharedInstance.isHeaderColor == false {
            
            if AppTheme.sharedInstance.headerImage != "" {
                
                self.imageFromUrl(urlString: AppTheme.sharedInstance.headerImage)

              /*  let imageView : UIImageView = UIImageView()
                let url = NSURL(string: AppTheme.sharedInstance.headerImage)! as URL
                imageView.sd_setImage(with: url, placeholderImage: nil, options: SDWebImageOptions(rawValue: 1), completed: { (image, error, cacheType, imageURL) in
                    if image != nil {
                        print("Navigation bar image donwloaded sucess......")
                        //Remove navigation bar image
//                        if !(SDImageCache.shared().cachePath(forKey: AppTheme.sharedInstance.headerImage, inPath: imageData)?.contains(imageData))! {
                            SDImageCache.shared().removeImage(forKey: AppTheme.sharedInstance.headerImage, withCompletion: nil )
//                        }
                        DispatchQueue.main.async {
                            //AppTheme.sharedInstance.navigationImageData = image
                            UINavigationBar.appearance().setBackgroundImage(nil, for: .default)
                            UINavigationBar.appearance().setBackgroundImage(image, for: .default)
                        }
                    }
                    else {
                        UINavigationBar.appearance().setBackgroundImage(nil, for: .default)
                        UINavigationBar.appearance().barTintColor = AppTheme.sharedInstance.headerColor
                    }
                })
 */
            }
            else {
                UINavigationBar.appearance().setBackgroundImage(nil, for: .default)
                UINavigationBar.appearance().barTintColor = AppTheme.sharedInstance.headerColor
            }
        }
        else {
            UINavigationBar.appearance().setBackgroundImage(nil, for: .default)
            //Change header color
            UINavigationBar.appearance().barTintColor = AppTheme.sharedInstance.headerColor
        }
    }
    
    public func imageFromUrl(urlString: String) {
        if let url = NSURL(string: urlString) {
            var request = URLRequest(url: url as URL)
            request.addValue("Basic ".appending(EventData.sharedInstance.auth_token), forHTTPHeaderField: "Authorization")
            let queue = OperationQueue()

            NSURLConnection.sendAsynchronousRequest(request, queue: queue) {
                response, data, error -> Void in
                if (data as NSData?) != nil {
                    UINavigationBar.appearance().setBackgroundImage(UIImage(data: (data)!), for: .default)
                }
                else {
                    UINavigationBar.appearance().setBackgroundImage(nil, for: .default)
                    UINavigationBar.appearance().barTintColor = AppTheme.sharedInstance.headerColor
                }
            }
        }
    }

    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }

    func applyThemeOnScreen(viewController: UIViewController, bgImage:UIImageView )  {
        
        if AppTheme.sharedInstance.isbackgroundColor == false {
            
            if AppTheme.sharedInstance.backgroundImage != "" {
//                SDImageCache.shared().removeImage(forKey: AppTheme.sharedInstance.backgroundImage, withCompletion: nil)
//                if SDImageCache.cachePath(AppTheme.sharedInstance.backgroundImage) {
                    bgImage.sd_setImage(with: NSURL(string:AppTheme.sharedInstance.backgroundImage as String)! as URL, placeholderImage: UIImage(named: "bgimage"))
               // }
            }
            else {
                bgImage.backgroundColor = AppTheme.sharedInstance.backgroundColor
            }
        }
        else {
            bgImage.backgroundColor = AppTheme.sharedInstance.backgroundColor
        }
    }
    
    func fetchPlistData(fileName:String) ->AnyObject  {
        
        var returnObject: AnyObject? = nil
        
        if let path = Bundle.main.path(forResource: fileName, ofType: "plist") {
            
            //If your plist contain root as Array
            if let array = NSArray(contentsOfFile: path) as? [[String: Any]] {
                returnObject = array as AnyObject
            }
            
            ////If your plist contain root as Dictionary
            if let dict = NSDictionary(contentsOfFile: path) as? [String: Any] {
                returnObject = dict as AnyObject
            }
        }
        return returnObject!
    }


    // MARK: - Date Method
    /* func localToUTCTime(date:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        dateFormatter.calendar = NSCalendar.current
        dateFormatter.timeZone = TimeZone.current
        
        let dt = dateFormatter.date(from: date)
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return dateFormatter.string(from: dt!)
    }
    
    func UTCToLocalTime(date:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let dt = dateFormatter.date(from: date)
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: dt!)
    }

    func localToUTCDate(date:String) -> String {
        let dateFormatter = DateFormatter()
       // dateFormatter.dateFormat = "yyyy-dd-MM'T'HH:mm:ss"
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.calendar = NSCalendar.current
        dateFormatter.timeZone = TimeZone.current
        
        var dt = dateFormatter.date(from: date)
        //Check date format
        if dt == nil {
            //Check this format
            dateFormatter.dateFormat = "dd-MM-yyyy"
            dt = dateFormatter.date(from: date)
            
            if dt == nil {
                dateFormatter.dateFormat = "yyyy-MM-dd"
                dt = dateFormatter.date(from: date)
                
                if dt == nil {
                    return self.localToUTCTime(date:date)
                }
            }
        }

        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return dateFormatter.string(from: dt!)
    }
    
    func UTCToLocalDate(date:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
     //   dateFormatter.dateFormat = "yyyy-dd-MM'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        var dt = dateFormatter.date(from: date)
        
        //Check date format
        if dt == nil {
            //Check this format
            dateFormatter.dateFormat = "dd-MM-yyyy"
            dt = dateFormatter.date(from: date)
            
            if dt == nil {
                dateFormatter.dateFormat = "yyyy-MM-dd"
                dt = dateFormatter.date(from: date)

                if dt == nil {
                    return self.UTCToLocalTime(date: date)
                }
            }
        }

        dateFormatter.timeZone = TimeZone.current

        return dateFormatter.string(from: dt!)
    }

    func UTCToLocalDateAndTime(date:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let dt = dateFormatter.date(from: date)
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: dt!)
    }*/

    func getEventDate(dateStr: String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    //    dateFormatter.dateFormat = "dd-MM-yyyy"
        let date = dateFormatter.date(from: dateStr)
        dateFormatter.dateFormat = "MMM dd, yyyy"
        let result:String = dateFormatter.string(from: date!)
        
        return result
    }
    
    func getListHeaderDate(dateStr: String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        dateFormatter.locale = Locale.init(identifier: "en_GB")
        let date = dateFormatter.date(from: dateStr)

        if date == nil {
            return ""
        }
        else {
            dateFormatter.dateFormat = "EEEE, MMM dd, yyyy"
            let result:String = dateFormatter.string(from: date!)
            return result
        }
       
    }

//    func getEmailDate(dateStr: String) -> String
//    {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
//        var date = dateFormatter.date(from: dateStr)
//        if date == nil {
//            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
//            date = dateFormatter.date(from: dateStr)
//        }
//        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm a"
//        let result:String = dateFormatter.string(from: date!)
//        return result
//    }
    
    func getNotificationDate(dateStr: String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        dateFormatter.locale = Locale.init(identifier: "en_GB")
        let date = dateFormatter.date(from: dateStr)
        dateFormatter.dateFormat = "EEEE, MMM dd, yyyy"
        let result:String = dateFormatter.string(from: date!)
        return result
    }
    
    func getDateAndTime(dateStr: String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        var date = dateFormatter.date(from: dateStr)
        if date == nil {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
            date = dateFormatter.date(from: dateStr)
        }
        dateFormatter.dateFormat = "dd-MM-yyyy hh:mm a"
        let result:String = dateFormatter.string(from: date!)
        return result
    }
    
    func getEmailDateAndTime(dateStr: String) -> String
    {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        var date = dateFormatter.date(from: dateStr)
        if date == nil {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
            date = dateFormatter.date(from: dateStr)
        }
//        dateFormatter.dateFormat = "dd-MM-yyyy hh:mm a"
//        let result:String = dateFormatter.string(from: date!)
        
        //Calculate days between events start and end date
        let currentDate = Date()

        let diffInDays = Calendar.current.dateComponents([.day], from: currentDate, to: date!).day
        var eDateStr = ""
        if diffInDays == 0 {
            dateFormatter.dateFormat = "hh:mm a"
            eDateStr = dateFormatter.string(from: date!)
        }
        else if diffInDays == 1 {
            dateFormatter.dateFormat = "Yesterday"
            eDateStr = dateFormatter.string(from: date!)
        }
        else  if diffInDays! > 1 && diffInDays! < 6 {
            dateFormatter.dateFormat = "EEEE"
            eDateStr = dateFormatter.string(from: date!)
        }
        else {
            dateFormatter.dateFormat = "dd-MM-yyyy"
            eDateStr = dateFormatter.string(from: date!)
        }
        return eDateStr
    }

    func getTimeInDisplayFormat(dateStr: String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        dateFormatter.locale = Locale.init(identifier: "en_GB")
        let date = dateFormatter.date(from: dateStr)
        if date == nil {
            return "00:00 am"
        }
        else {
            dateFormatter.dateFormat = "hh:mm aa"
            let result:String = dateFormatter.string(from: date!)
            return result
        }
    }
    
    func getAgendaDayOnly(dateStr: String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy" //Shital 7 dec
        let date = dateFormatter.date(from: dateStr)
        dateFormatter.dateFormat = "dd"
        let result:String = dateFormatter.string(from: date!)
        return result
    }

    func getChatListDate(dateStr: String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        var chatDate = dateFormatter.date(from: dateStr)
        if chatDate == nil {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            chatDate = dateFormatter.date(from: dateStr)
        }
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let dStr = dateFormatter.string(from: chatDate!)
        let newDate = dateFormatter.date(from: dStr)

        let currentDate = Date()
        
        let components = Set<Calendar.Component>([.day, .month, .year])
        let differenceOfDate = Calendar.current.dateComponents(components, from: newDate!, to: currentDate)
        

        var result = ""
        if differenceOfDate.day == 0 {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
            var date = dateFormatter.date(from: dateStr)
            if date == nil {
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                date = dateFormatter.date(from: dateStr)
            }
            dateFormatter.dateFormat = "hh:mm a"
            result = dateFormatter.string(from: date!)
        }
        else if differenceOfDate.day == 1 {
            result = "Yesterday"
        }
        else {
            dateFormatter.dateFormat = "dd-MM-yyyy"
            result = dateFormatter.string(from: newDate!)
        }
        
        return result
    }

    func getChatGroupCreatedDate(dateStr: String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        var chatDate = dateFormatter.date(from: dateStr)
        if chatDate == nil {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            chatDate = dateFormatter.date(from: dateStr)
        }
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let dStr = dateFormatter.string(from: chatDate!)
        let newDate = dateFormatter.date(from: dStr)

        let currentDate = Date()

        let components = Set<Calendar.Component>([.day, .month, .year])
        let differenceOfDate = Calendar.current.dateComponents(components, from: newDate!, to: currentDate)

        dateFormatter.dateFormat = "hh:mm a"
        let time = dateFormatter.string(from: chatDate!)

        var result = ""
        if differenceOfDate.day == 0 {
            result = String(format:"Today, %@",time)
        }
        else if differenceOfDate.day == 1 {
            result = String(format:"Yesterday, %@",time)
        }
        else {
            dateFormatter.dateFormat = "dd-MM-yyyy"
            result = dateFormatter.string(from: newDate!)
        }

        return result
    }

//    func getSessionDate(dateStr: String) -> String
//    {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "dd-MM-yyyy"
//        let date = dateFormatter.date(from: dateStr)
//        dateFormatter.dateFormat = "EEEE, MMM dd, yyyy"
//        let result:String = dateFormatter.string(from: date!)
//        
//        return result
//    }
    
    func getCurrentDateAndTime() -> String
    {
        let formatter = DateFormatter()
        //formatter.dateFormat = "yyyy/MM/dd hh:mm a"
       // formatter.dateFormat = "dd-MM-yyyy hh:mm a"
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        let currentDateTime = Date()
        let result:String = formatter.string(from: currentDateTime)
        
        return result
    }
    
    func getAgendaSelectedDate(dateStr: String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy" //Shital 7 dec
        //dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.locale = Locale.init(identifier: "en_GB")
        let date = dateFormatter.date(from: dateStr)
        dateFormatter.dateFormat = "dd MMM yyyy"
        return dateFormatter.string(from: date!)
    }
    
    func getAgendaDate(dateStr: String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.locale = Locale.init(identifier: "en_GB")
        let date = dateFormatter.date(from: dateStr)
        dateFormatter.dateFormat = "dd MMM yyyy hh:mm a"
        return dateFormatter.string(from: date!)
    }

    func getSessionsTime(dateStr: String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        let date = dateFormatter.date(from: dateStr)
        dateFormatter.dateFormat = "hh:mm a"
        return dateFormatter.string(from: date!)
    }
    
    func getStringIntoDate(dateStr : String) -> Date
    {
        
       /* let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let date = formatter.date(from: dateStr)
        let result = formatter.string(from: date!)
        formatter.dateFormat = "dd-MM-yyyy"
        formatter.locale = Locale.init(identifier: "en_GB")
        return formatter.date(from: result)!
        */
        
        let dateString = dateStr // "2017-07-18T13:30:00"
        let dateFormatter = DateFormatter()
       // dateFormatter.dateFormat = "dd-MM-yyyy'T'HH:mm:ss"
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.locale = Locale.init(identifier: "en_GB")
        
        let dateObj = dateFormatter.date(from: dateString)
        
        dateFormatter.dateFormat = "dd-MM-yyyy"
 
        return dateObj!
    }
    
    func getQuestionDate() -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        return dateFormatter.string(from: NSDate() as Date)
    }
   
    func getCurrentDateInMM() -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        
        return dateFormatter.string(from: NSDate() as Date)
    }

    func getQuestionTime(dateStr: String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        var qDate = dateFormatter.date(from: dateStr)
        if qDate == nil {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
             qDate = dateFormatter.date(from: dateStr)
        }
        let toDate = NSDate() as Date
        let offset = toDate.offsetFrom(date: qDate! as NSDate)
        return offset
    }
   
    func getActivityTimeInSecond(dateStr: String) -> Int
    {
     //  let dateStr1 = "2018-01-03T15:20:00"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        var activityDate = dateFormatter.date(from: dateStr)
        if activityDate == nil {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            activityDate = dateFormatter.date(from: dateStr)
        }
        let toDate = NSDate() as Date
      // let offset = toDate.secondsFrom(date: qDate! as NSDate)
        let calendar: NSCalendar = Calendar.current as NSCalendar
        let flags = NSCalendar.Unit.second
        let components = calendar.components(flags, from: toDate, to: activityDate!, options: [])

        return components.second!
    }

    // MARK: - HTML String Content Method

    func stringFromHtml(string: String) -> NSAttributedString? {
        do {
            let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
            if let d = data {
                let str = try NSAttributedString(data: d,
                                                 options: [NSAttributedString.DocumentReadingOptionKey.documentType : NSAttributedString.DocumentType.html],
                                                 documentAttributes: nil)
                return str
            }
        } catch {
        }
        return nil
    }

    
    // MARK: - PDF generator Method

    func createPDF(content: String, pdfName : String) {
        
        
        //   html = "<b>Hello <i> World!</i></b> <p>Generate PDF file from HTML in Swift</p>"
        let fmt = UIMarkupTextPrintFormatter(markupText: content)
        
        // 2. Assign print formatter to UIPrintPageRenderer
        
        let render = UIPrintPageRenderer()
        render.addPrintFormatter(fmt, startingAtPageAt: 0)
        
        // 3. Assign paperRect and printableRect
        
        let page = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4, 72 dpi
        let printable = page.insetBy(dx: 0, dy: 0)
        
        render.setValue(NSValue(cgRect: page), forKey: "paperRect")
        render.setValue(NSValue(cgRect: printable), forKey: "printableRect")
        
        // 4. Create PDF context and draw
        
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, .zero, nil)
        render.prepare(forDrawingPages: NSMakeRange(0, render.numberOfPages))
        
        for i in 1...render.numberOfPages {
            
            UIGraphicsBeginPDFPage();
            let bounds = UIGraphicsGetPDFContextBounds()
            render.drawPage(at: i - 1, in: bounds)
        }
        
        UIGraphicsEndPDFContext();
        
        // 5. Save PDF file
        let filename = String(format: "%@_%@_%@",pdfName, EventData.sharedInstance.eventId,AttendeeInfo.sharedInstance.attendeeId)
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let documentoPath = "\(documentsPath)/\(filename).pdf"
        do {
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: documentoPath){
                try fileManager.removeItem(atPath: documentoPath)
            }
            pdfData.write(toFile: documentoPath, atomically: true)
        }
        catch let error as NSError {
            print("Could not clear temp folder: \(error.debugDescription)")
        }
    }

    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {

        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }

    // MARK: - Data Model Method
    
    func parseQuestionsData() -> NSArray {
        
        var array = [Questions]()
        
        let dictionary  = self.loadJSONFromBundle(filename: "Q&A")
        let data = dictionary?["questionArray"]
        
        for item in data as! NSArray{
            let  dict = item as! NSDictionary
            
            let model = Questions()
            model.queId = dict.value(forKey: "QuestionId") as! String!
            model.queStr = dict.value(forKey: "Question") as! String!
            model.queCount = dict.value(forKey: "Count") as! Int
            model.isUserLike = (dict.value(forKey: "isUserLike") != nil)
            model.timeStr = dict.value(forKey: "time") as! String
            
            let  user = dict.value(forKey: "FeedUser") as! NSDictionary
            model.userId = user.value(forKey: "userid") as! String!
            model.userNameStr = user.value(forKey: "Name") as! String!
            model.userIconUrl = user.value(forKey: "iconurl") as! String!

            array.append(model)
        }
        
        return array as NSArray
    }

    /*
    func parseDocumentsData() -> NSArray {
        
        var array = [DocumentModel]()
        
        let dictionary  = self.loadJSONFromBundle(filename: "Documents")
        let data = dictionary?["Documents"]
        
        for item in data as! NSArray {
            let  dict = item as! NSDictionary
            let model = DocumentModel()
            model.title = dict.value(forKey: "Title") as! String!
            model.pdfUrlStr = dict.value(forKey: "UrlPath") as! String!
            array.append(model)
        }
        
        return array as NSArray
    }
    
    func parseReminderData() -> NSArray {
        
        var array = [ReminderModel]()
        
        let dictionary  = self.loadJSONFromBundle(filename: "Reminder")
        let data = dictionary?["reminderarray"]
        
        for item in data as! NSArray{
            let  dict = item as! NSDictionary
            
            let model = ReminderModel()
            model.startTime = dict.value(forKey: "date") as! String!
            model.title = dict.value(forKey: "title") as! String!
            model.message = dict.value(forKey: "Description") as! String!
            array.append(model)
        }
        
        return array as NSArray
    }
    
    func parseAttedeesData() -> NSArray {
        
        var array = [PersonModel]()
        
        let dictionary  = self.loadJSONFromBundle(filename: "Attendees")
        let data = dictionary?["person"]
        
        for item in data as! NSArray {
            let  dict = item as! NSDictionary
            
            let model = PersonModel()
            model.name = dict.value(forKey: "name") as! String!
            model.personId = dict.value(forKey: "id") as! String!
            model.designation = dict.value(forKey: "designation") as! String!
            model.bioInfo = dict.value(forKey: "description") as! String!
            model.iconUrl = dict.value(forKey: "iconurl") as! String!
            model.address = dict.value(forKey: "address") as! String!
            model.email = dict.value(forKey: "email") as! String!
            
            array.append(model)
        }
        
        return array as NSArray
    }

    func parseEmailData() -> NSArray {
        
        var array = [EmailModel]()
        
        let dictionary  = self.loadJSONFromBundle(filename: "Email")
        let data = dictionary?["listArray"]
        
        for item in data as! NSArray {
            let  dict = item as! NSDictionary
            
            let model = EmailModel()
            model.from = dict.value(forKey: "From") as! String!
            model.to = dict.value(forKey: "To") as! String!
            model.content = dict.value(forKey: "Content") as! String!
            model.date = dict.value(forKey: "SentTime") as! String!
            
            array.append(model)
        }
        
        return array as NSArray
    }
    
    
    func parseAgendaData() -> NSArray {
        
        var dataArray = [AgendaModel]()
        
        let dictionary  = self.loadJSONFromBundle(filename: "Agenda")
        let data = dictionary?["agenda"]
        
        for item in data as! NSArray {
            let  dict = item as! NSDictionary
            
            let model = AgendaModel()
            model.activityId = dict.value(forKey: "id") as! String!
            model.activityName = dict.value(forKey: "name") as! String!
            model.startTime = dict.value(forKey: "startTime") as! String!
            model.endTime = dict.value(forKey: "endTime") as! String!
            model.descText = dict.value(forKey: "description") as! String!
            model.location = dict.value(forKey: "address") as! String!
            model.startActivityDate = dict.value(forKey: "date") as! String!
            
            let speakersList = dict.value(forKey: "speakers") as! Array<Any>
            var array = [PersonModel]()
            
            if speakersList.count != 0 {
                for data in speakersList {
                    let  dict = data as! NSDictionary
                    
                    if dict.count != 0 {
                        let speakerModel = PersonModel()
                        speakerModel.name = dict.value(forKey: "name") as! String!
                        speakerModel.personId = dict.value(forKey: "id") as! String!
                        speakerModel.designation = dict.value(forKey: "designation") as! String!
                        speakerModel.bioInfo = dict.value(forKey: "description") as! String!
                        speakerModel.iconUrl = dict.value(forKey: "iconurl") as! String!
                        speakerModel.address = dict.value(forKey: "address") as! String!
                        speakerModel.email = dict.value(forKey: "email") as! String!
                        array.append(speakerModel)
                    }
                }
            }
            model.speakers = array
            dataArray.append(model)
        }
        
        return dataArray as NSArray
    }

    func parseActivityData(data : AnyObject) -> NSArray {
     
        var array = [ActivityFeedsModel]()
     
        if data is NSArray {
     
            for item in data as! NSArray {
                let  dict = item as! NSDictionary
     
                let model = ActivityFeedsModel()
                model.userNameString = dict.value(forKey: "name") as! String!
                model.postDateStr = dict.value(forKey: "date") as! String!
                model.messageText = dict.value(forKey: "text") as! String!
                model.likesCount = dict.value(forKey: "likes") as! String!
                model.commentsCount = dict.value(forKey: "comments") as! String!
                model.postImageUrl = dict.value(forKey: "image") as! String!
                model.userIconUrl = ""
                array.append(model)
            }
        }
        
        return array as NSArray
    }
    
    
    
    func parseWiFiData() -> NSArray {
        
        var array = [WiFiModel]()
        
        let dictionary  = self.loadJSONFromBundle(filename: "WiFi")
        let data = dictionary?["wifiArray"]
        
        for item in data as! NSArray {
            let  dict = item as! NSDictionary
            let model = WiFiModel()
            model.name = dict.value(forKey: "Name") as! String!
            model.network = dict.value(forKey: "Network") as! String!
            model.password = dict.value(forKey: "Password") as! String!
            array.append(model)
        }
        
        return array as NSArray
    }
    
    func parseSpeakerData() -> NSArray {
        
        var array = [PersonModel]()
        
        let dictionary  = self.loadJSONFromBundle(filename: "Speaker")
        let data = dictionary?["person"]
        
        for item in data as! NSArray {
            let  dict = item as! NSDictionary
            
            let model = PersonModel()
            model.name = dict.value(forKey: "name") as! String!
            model.personId = dict.value(forKey: "id") as! String!
            model.designation = dict.value(forKey: "designation") as! String!
            model.bioInfo = dict.value(forKey: "description") as! String!
            model.iconUrl = dict.value(forKey: "iconurl") as! String!
            model.address = dict.value(forKey: "address") as! String!
            model.email = dict.value(forKey: "email") as! String!
            
            array.append(model)
        }
        
        return array as NSArray
    }
    
    func parseSponsorData() -> NSArray {
        
        var array = [Sponsors]()
        
        let dictionary  = self.loadJSONFromBundle(filename: "Sponsor")
        let data = dictionary?["sponsorarray"]
        
        for item in data as! NSArray {
            let  dict = item as! NSDictionary
            let model = Sponsors()
            model.name = dict.value(forKey: "name") as! String!
            model.sponsorId = dict.value(forKey: "id") as! String!
            model.website = dict.value(forKey: "website") as! String!
            model.descInfo = dict.value(forKey: "description") as! String!
            model.iconUrl = dict.value(forKey: "iconurl") as! String!
            model.address = dict.value(forKey: "address") as! String!
            model.email = dict.value(forKey: "email") as! String!
            model.contactNo = dict.value(forKey: "contact no") as! String!
            model.tagline = dict.value(forKey: "tagline") as! String!
            array.append(model)
        }
        
        return array as NSArray
    }
    
    func parseWiFiData() -> NSArray {
        
        var array = [WiFiModel]()
        
        let dictionary  = self.loadJSONFromBundle(filename: "WiFi")
        let data = dictionary?["wifiArray"]
        
        for item in data as! NSArray {
            let  dict = item as! NSDictionary
            let model = WiFiModel()
            model.name = dict.value(forKey: "name") as! String!
            model.network = dict.value(forKey: "network") as! String!
            model.password = dict.value(forKey: "password") as! String!
            model.iconUrl = dict.value(forKey: "iconurl") as! String!
            array.append(model)
        }
        
        return array as NSArray
    }
     
    func parseEmergencyData() -> NSArray {
        
        var array = [EmergencyModel]()
        
        let dictionary  = self.loadJSONFromBundle(filename: "Emergency")
        let data = dictionary?["emerArray"]
        
        for item in data as! NSArray {
            let  dict = item as! NSDictionary
            
            let model = EmergencyModel()
            model.title = dict.value(forKey: "title") as! String!
            model.address = dict.value(forKey: "address") as! String!
            model.iconUrl = dict.value(forKey: "iconurl") as! String!
            model.email = dict.value(forKey: "email") as! String!
            model.contactNo = dict.value(forKey: "contactNo") as! String!
            
            array.append(model)
        }
        
        return array as NSArray
    }
     
     
     
   
    
    func parseNotificationData() -> NSArray {
     
        var array = [NotificationsModel]()
        
        let dictionary  = self.loadJSONFromBundle(filename: "Notification")
        let data = dictionary?["notiarray"]
        
        for item in data as! NSArray{
            let  dict = item as! NSDictionary
            
            let model = NotificationsModel()
            model.titleText = dict.value(forKey: "title") as! String!
            model.messageText = dict.value(forKey: "message") as! String!
            model.postTimeStr = dict.value(forKey: "time") as! String!
            
            
            array.append(model)
        }
        
        return array as NSArray
    }
    */
        
    
    // MARK: - Fetch json files data
    
    func loadJSONFromBundle(filename: String) -> Dictionary<String, AnyObject>? {
        if let path = Bundle.main.path(forResource:filename, ofType: "json")
        {
            
            do{
                let data = try NSData(contentsOfFile: path, options: NSData.ReadingOptions.dataReadingMapped)
                do{
                    // let dictionary: Any = try JSONSerialization.jsonObject(with: data as Data,options: JSONSerialization.ReadingOptions())
                    let dictionary: Any = try JSONSerialization.jsonObject(with: data as Data,options: JSONSerialization.ReadingOptions())
                    
                    if let dictionary = dictionary as? Dictionary<String, AnyObject> {
                        return dictionary
                    } else {
                        print("Level file '\(filename)' is not valid JSON")
                        return nil
                    }
                }catch {
                    print("Level file '\(filename)' is not valid JSON: \(error)")
                    return nil
                }
                
                
            }catch {
                print("Could not load level file: \(filename), error: \(error)")
                return nil
            }
            
        } else {
            print("Could not find level file: \(filename)")
            return nil
        }
    }
    
    func saveToJsonFile(dataArray:Any ) {
        // Get the url of Persons.json in document directory
        guard let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        let fileUrl = documentDirectoryUrl.appendingPathComponent( "Reminder.json")
        //  let personArray =  [["person": ["name": "Dani", "age": "24"]], ["person": ["name": "ray", "age": "70"]]]
        
        // Transform array into data and save it into file
        do {
            let data = try JSONSerialization.data(withJSONObject: dataArray, options: [])
            try data.write(to:fileUrl  as URL, options: [])
        } catch {
            print(error)
        }
    }
}
