 //
//  ViewController.swift
//  My-Julia
//
//  Created by GCO on 4/4/17.
//  Copyright © 2017 GCO. All rights reserved
//Commited by shital _
 
import UIKit

class ViewController: UIViewController, UITextFieldDelegate, TKAlertDelegate {
    
    @IBOutlet weak var inputText: UITextField!
    @IBOutlet weak var bgInputView: UIView!
    @IBOutlet weak var alphaView: UIView!
    @IBOutlet weak var checkButton: UIButton!
    //@IBOutlet weak var blurBgView: UIView!

  //  var queue : OperationQueue! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        struct Obj {
            let name: String
        }
       // self.blurBgView.isHidden = true

        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.navigationBar.tintColor = UIColor.white;
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
        
       // inputText.text = "OLS2014-CDDA42E"
       // inputText.text = "OLS2014-A29YJ74"
        //   inputText.text = "OLS2014-3C09352"
      // inputText.text = "OLS2014-88B692B"
       // inputText.text = "XLB2014-2CC61AA"
        
        //inputText.text = "OLS2014-51087a6"
      //  inputText.text = "q42nt-2abf266" // "Q42NT-2ABF266"
        
        //Login automatically if attendee credential is stored
         // let userCredential = CredentialHelper.init(host: APP_NAME).defaultCredential
        let userCredential = CredentialHelper.shared.defaultCredential
       // print("Default credential : ",userCredential?.user ?? "")
        if userCredential?.user != nil {
            inputText.text = userCredential?.user
            self.onClickOfLoginButton()
        }

       // inputText.text = "OLS2014-51087a6"
    }
    
    override func viewWillAppear(_ animated: Bool) {
    //App log out
        isAppLogin = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Keyboard NSNotification Methods
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
          //  self.view.frame.origin.y -= keyboardSize.height
            if inputText.isFirstResponder {
                self.view.frame.origin.y = -150
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.frame.origin.y = 0 //keyboardSize.height
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.view.frame.origin.y = 0
    }
    
    // MARK: - UIButton Action Methods
    
    @IBAction func onClickOfLoginButton() {
        
      //  inputText.resignFirstResponder()
        
        if (inputText.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! {
            CommonModel.sharedInstance.showAlertWithStatus(title: "", message: Enter_Event_Key, vc: self)
            return
        }
        
        //Show Indicator
        CommonModel.sharedInstance.showActitvityIndicator()
        //Fetch auth token using attendee code
        self.getAutheticationDetails()
    }

    @IBAction func onClickOfTermsAndConditionCheckBtn() {

        self.checkButton.isSelected = !self.checkButton.isSelected
    }

    // MARK: - Webservice Methods
    
    func getAutheticationDetails() {
        
        //Clear privious attendee and eventdetails
        EventData.sharedInstance.resetEventDetails()
        AttendeeInfo.sharedInstance.resetAttendeeDetails()

        let timezone = TimeZone.current.abbreviation()

        let parameters : NSMutableDictionary? = [ "AttendeeCode": inputText.text!, "DeviceToken":AppDelegate.getAppDelegateInstance().deviceToken, "TimeZone" : timezone ?? ""]

        NetworkingHelper.postData(urlString:Get_AuthToken_Url, param:parameters!, withHeader: false, isAlertShow: true, controller:self, callback: { response in

           // print("\nAuth token Details response : ", response)
            let responseCode = Int(response.value(forKey: "responseCode") as! String)

            if responseCode == 0 {
                
                let dict = response.value(forKey: "responseMsg") as! NSDictionary
                let event = EventData.sharedInstance
                event.eventId = dict.value(forKey: "EventId") as! String
                event.auth_token = dict.value(forKey: "token") as! String
                event.attendeeId = dict.value(forKey: "AttendeeId") as! String
                event.attendeeStatus = dict.value(forKey: "IsAccept") as! Bool
                event.attendeeCode = self.inputText.text!
                
                self.getEventDetailsData()

                //Store Attendee credential for auto login
                UserDefaults.standard.set("StoreCrential", forKey: "isAppUninstall")
                UserDefaults.standard.synchronize()
                CredentialHelper.shared.storeDefaultCredential(key: event.attendeeCode, value: event.eventId)
            }
            else {
                CommonModel.sharedInstance.dissmissActitvityIndicator()
                CommonModel.sharedInstance.showAlertWithStatus(title: "", message:response.value(forKey: "responseMsg") as! String, vc: self)
            }
        }, errorBack: { error in
            NSLog("error in Auth token: %@", error)
        })
    }
    
    func getEventDetailsData() {
        
        NetworkingHelper.getRequestFromUrl(name:Get_Login_Details_Url, urlString: Get_Login_Details_Url, callback: { response in
           // print("\nEvent Theme Details : ",response)

            self.getEventModuleData()

        }, errorBack: { error in
            CommonModel.sharedInstance.dissmissActitvityIndicator()
            CommonModel.sharedInstance.showAlertWithStatus(title: "Error", message: Internet_Error_Message, vc: self)
        })
    }
    
    func getEventModuleData() {
        let urlStr = Get_AllModuleDetails_url.appendingFormat("Flag=%@",Get_AllDetails_url)

        NetworkingHelper.getRequestFromUrl(name:Get_AllModuleDetails_url, urlString: urlStr, callback: { response in
           // print("\n All Data response Data - ",response)
            //Check login user status accepted terms and conditions
            self.checkLoginAttendeeStatus()
        }, errorBack: { error in
            NSLog("error in All Data : %@", error)
            CommonModel.sharedInstance.dissmissActitvityIndicator()
            CommonModel.sharedInstance.showAlertWithStatus(title: "Error", message: Internet_Error_Message, vc: self)
        })
    }
    
    func updateUserStaursDetails() {
        //Show Indicator
        CommonModel.sharedInstance.showActitvityIndicator()

        let parameters : NSMutableDictionary? = [ "AttendeeId": EventData.sharedInstance.attendeeId, "EventId":EventData.sharedInstance.eventId, "IsAccept" : true]

        NetworkingHelper.postData(urlString:Post_TermsAndCondition_Url, param:parameters!, withHeader: false, isAlertShow: true, controller:self, callback: { response in
            //dismiss Indicator
            CommonModel.sharedInstance.dissmissActitvityIndicator()
            let responseCode = Int(response.value(forKey: "responseCode") as! String)

            if responseCode == 0 {
                EventData.sharedInstance.attendeeStatus = true
                self.navigateToNextScreen()
            }
        }, errorBack: { error in
            //dismiss Indicator
            CommonModel.sharedInstance.dissmissActitvityIndicator()
        })
    }

    // MARK: - Logical Methods

    func checkLoginAttendeeStatus() {

        //Fetch event details data from Sqlite database and if it empty show error message
        _ = DBManager.sharedInstance.fetchEventDetailsDataFromDB()
        _ = DBManager.sharedInstance.fetchProfileDataFromDB()

        //Fetch application theme data from Sqlite database
        _ = DBManager.sharedInstance.fetchAppThemeDataFromDB()

        // inject an authorisation header for images
        SDWebImageDownloader.shared().setValue("Basic ".appending(EventData.sharedInstance.auth_token), forHTTPHeaderField: "Authorization")

        //Apply navigation theme
        CommonModel.sharedInstance.applyNavigationTheme()

        CommonModel.sharedInstance.dissmissActitvityIndicator()

        //App login
        isAppLogin = true
        // self.fetchContentFromServer()

        //Call terms and condition accept view
        if EventData.sharedInstance.attendeeStatus == false {
            self.inputText.resignFirstResponder()
            
            let alertView : TKAlert! = self.initialiseAlert()
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

    func initialiseAlert() -> TKAlert {
        // >> alert-custom-content-swift
        let alert = TKAlert()
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
        alert.style.backgroundDimAlpha = 0.5;
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

    // MARK: - UITextFeild Delegate Methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

 
