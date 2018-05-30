//
//  LoginViewController.swift
//  My-Julia
//
//  Created by GCO on 09/03/2018.
//  Copyright © 2018 GCO. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var otpView: UIView!
    @IBOutlet weak var inputText: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)

        self.otpView.isHidden = true
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
    

    // MARK: - UITextFeild Delegate Methods

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // MARK: - Button Action Methods

    @IBAction func onClickOfCancelBtn() {
    }

    @IBAction func onClickOfDownloadBtn() {
    }

    // MARK: - Webservice Methods

    func getAutheticationDetails() {

        let timezone = TimeZone.current.abbreviation()

        let parameters : NSDictionary = [ "AttendeeCode": self.inputText.text!, "DeviceToken":AppDelegate.getAppDelegateInstance().deviceToken, "OS" : "iOS", "TimeZone" : timezone ?? ""]

        NetworkingHelper.postData(urlString:Get_AuthToken_Url, param:parameters, withHeader: false, isAlertShow: true, controller:self, callback: { [weak self] response in

            //   print("\nAuth token response - ",CommonModel.sharedInstance.getCurrentDateInMM())

            print("\nAuth token Details response : ", response)
            let responseCode = Int(response.value(forKey: "responseCode") as! String)

            if responseCode == 0 {

                let dict = response.value(forKey: "responseMsg") as! NSDictionary
                let event = EventData.sharedInstance
                event.eventId = dict.value(forKey: "EventId") as! String
                event.auth_token = dict.value(forKey: "token") as! String
                event.attendeeId = dict.value(forKey: "AttendeeId") as! String
                event.attendeeStatus = dict.value(forKey: "IsAccept") as! Bool
                event.attendeeCode = (self?.inputText.text)!

                self?.loginView.isHidden = true
                self?.otpView.isHidden = false

                //self.getEventDetailsData()

                //                //Store Attendee credential for auto login
                //                UserDefaults.standard.set("StoreCrential", forKey: "isAppUninstall")
                //                UserDefaults.standard.synchronize()
                //                CredentialHelper.shared.storeDefaultCredential(key: event.attendeeCode, value: event.eventId)
            }
            else {
                CommonModel.sharedInstance.dissmissActitvityIndicator()
                CommonModel.sharedInstance.showAlertWithStatus(title: "", message:response.value(forKey: "responseMsg") as! String, vc: self!)
            }
        }, errorBack: { error in
            NSLog("error in Auth token: %@", error)
        })
    }

    func validateOTP() {

        let timezone = TimeZone.current.abbreviation()

        let parameters : NSDictionary = [ "AttendeeCode": self.inputText.text!, "DeviceToken":AppDelegate.getAppDelegateInstance().deviceToken, "TimeZone" : timezone ?? ""]

        NetworkingHelper.postData(urlString:Get_AuthToken_Url, param:parameters, withHeader: false, isAlertShow: true, controller:self, callback: { [weak self] response in

            //   print("\nAuth token response - ",CommonModel.sharedInstance.getCurrentDateInMM())

            print("\nAuth token Details response : ", response)
            let responseCode = Int(response.value(forKey: "responseCode") as! String)

            if responseCode == 0 {

                let dict = response.value(forKey: "responseMsg") as! NSDictionary
                let event = EventData.sharedInstance
                event.eventId = dict.value(forKey: "EventId") as! String
                event.auth_token = dict.value(forKey: "token") as! String
                event.attendeeId = dict.value(forKey: "AttendeeId") as! String
                event.attendeeStatus = dict.value(forKey: "IsAccept") as! Bool
                event.attendeeCode = (self?.inputText.text)!

                self?.loginView.isHidden = true
                self?.otpView.isHidden = false

                //self.getEventDetailsData()

                //                //Store Attendee credential for auto login
                //                UserDefaults.standard.set("StoreCrential", forKey: "isAppUninstall")
                //                UserDefaults.standard.synchronize()
                //                CredentialHelper.shared.storeDefaultCredential(key: event.attendeeCode, value: event.eventId)
            }
            else {
                CommonModel.sharedInstance.dissmissActitvityIndicator()
                CommonModel.sharedInstance.showAlertWithStatus(title: "", message:response.value(forKey: "responseMsg") as! String, vc: self!)
            }
        }, errorBack: { error in
            NSLog("error in Auth token: %@", error)
        })
    }

}
