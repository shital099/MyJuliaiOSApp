//
//  CustomAlertView.swift
//  CustomAlertView
//
//  Created by Daniel Luque Quintana on 16/3/17.
//  Copyright © 2017 dluque. All rights reserved.
//

import UIKit

let OTP_session_Time = 60

class CustomAlertView: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var titleLbl: UILabel!
   // @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var attendeeCodeTextField: UITextField!
    @IBOutlet weak var otpTextField: CustomUITextField!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var codeCheckbox: UIView!
    @IBOutlet weak var otpView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var resendOTPButton: UIButton!
    @IBOutlet weak var otpMessageLbl: UILabel!
    @IBOutlet weak var viewBottomContraint: NSLayoutConstraint!

    var eventId : String = ""

    var isValidateOTP : Bool = false
    var noOfOtpAttempt : Int = 0
    var yPos : CGFloat = 0


    var delegate: CustomAlertViewDelegate?
    let alertViewGrayColor = UIColor(red: 224.0/255.0, green: 224.0/255.0, blue: 224.0/255.0, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        attendeeCodeTextField.becomeFirstResponder()
        self.titleLbl.text = Confirm_Attendee_code
        self.otpMessageLbl.text = String(format:"If you still do not receive your OTP after %d seconds, please try again later.",OTP_session_Time)

        self.codeCheckbox.layer.borderWidth = 1.0
        self.codeCheckbox.layer.borderColor = UIColor(red: 192.0/255.0, green: 192.0/255.0, blue: 192.0/255.0, alpha: 1).cgColor

        //Changes alert frame according to view frame
        yPos = (self.view.frame.size.height - self.alertView.frame.size.height)/2
        self.viewBottomContraint.constant = yPos
        self.alertView.updateConstraintsIfNeeded()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
        animateView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layoutIfNeeded()
        self.cancelButton.addBorder(side: .Top, color: alertViewGrayColor, width: 1)
        //cancelButton.addBorder(side: .Right, color: alertViewGrayColor, width: 1)
        downloadButton.addBorder(side: .Top, color: alertViewGrayColor, width: 1)
    }

    // MARK: - Keyboard Methods

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            //  self.view.frame.origin.y -= keyboardSize.height
            //if self.attendeeCodeTextField.isFirstResponder || self.otpTextField.isFirstResponder {
            let yPos = (self.view.frame.size.height - self.alertView.frame.size.height)/2
            if yPos < keyboardSize.size.height {
                self.viewBottomContraint.constant = keyboardSize.size.height + 10
            }else {
                self.viewBottomContraint.constant = yPos
            }
            self.alertView.updateConstraintsIfNeeded()

            // }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
           // self.alertView.frame.origin.y = (self.view.frame.size.height - self.alertView.frame.size.height)/2
            self.viewBottomContraint.constant = (self.view.frame.size.height - self.alertView.frame.size.height)/2
            self.alertView.updateConstraintsIfNeeded()
        }
    }

    // MARK: - Animations Methods

    func setupView() {
        alertView.layer.cornerRadius = 15
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
    }
    
    func animateView() {
        alertView.alpha = 0;
        self.alertView.frame.origin.y = self.alertView.frame.origin.y + 50
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.alertView.alpha = 1.0;
            self.alertView.frame.origin.y = self.alertView.frame.origin.y - 50
        })
    }

    // MARK: - Button action Methods

    @IBAction func onTapCancelButton(_ sender: Any) {
        attendeeCodeTextField.resignFirstResponder()
        delegate?.cancelButtonTapped()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onTapDownloadButton(_ sender: Any) {
       // attendeeCodeTextField.resignFirstResponder()
      //  delegate?.loginButtonTapped(selectedOption: "", textFieldValue: attendeeCodeTextField.text!)
      //  self.dismiss(animated: true, completion: nil)

        if self.isValidateOTP == false {
            if (self.attendeeCodeTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! {
                CommonModel.sharedInstance.showAlertWithStatus(title: "", message: Enter_Event_Key, vc: self)
                return
            }

            //Call login api for authenticate attendee code is valid or not
            self.getAutheticationDetails()
        }
        else {
            self.validateOTP()
        }
    }

    @IBAction func onTapResendButton(_ sender: Any) {

        if self.noOfOtpAttempt == 3 {
            //CommonModel.sharedInstance.showAlertWithStatus(title: "", message:OTP_Session_Expired, vc: self)
            let refreshAlert = UIAlertController(title: Invalid_OTP_title, message: OTP_Session_Expired, preferredStyle: UIAlertControllerStyle.alert)

            refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                self.delegate?.cancelButtonTapped()
                self.dismiss(animated: true, completion: nil)
            }))
            present(refreshAlert, animated: true, completion: nil)
        }
        else {
            self.resendOTPButton.isEnabled = false
            //Call api to send OTP
            self.resendOTP()
        }
    }

    // MARK: - Webservice Methods

    func getAutheticationDetails() {

        //Show Indicator
        CommonModel.sharedInstance.showActitvityIndicator()

        let parameters : NSDictionary = [ "AttendeeCode": self.attendeeCodeTextField.text!, "EventId" : self.eventId, "DeviceToken":AppDelegate.getAppDelegateInstance().deviceToken, "OS" : "iOS"]

        NetworkingHelper.postData(urlString:Get_AuthToken_Url, param:parameters, withHeader: false, isAlertShow: true, controller:self, callback: {[weak self] response in

            //   print("\nAuth token response - ",CommonModel.sharedInstance.getCurrentDateInMM())

            print("\n Auth token Details response : ", response)
            let responseCode = Int(response.value(forKey: "responseCode") as! String)
            CommonModel.sharedInstance.dissmissActitvityIndicator()

            if responseCode == 0 {

                let dict = response.value(forKey: "responseMsg") as! NSDictionary
                let event = EventData.sharedInstance
                event.eventId = dict.value(forKey: "EventId") as! String
                event.auth_token = dict.value(forKey: "token") as! String
                event.attendeeId = dict.value(forKey: "AttendeeId") as! String
                event.attendeeStatus = dict.value(forKey: "IsAccept") as! Bool
                event.attendeeCode = (self?.attendeeCodeTextField.text!)!

                self?.attendeeCodeTextField.resignFirstResponder()
                self?.loginView.isHidden = true
                self?.otpView.isHidden = false
                self?.resendOTPButton.isEnabled = false
                self?.downloadButton.isEnabled = false
                self?.otpTextField.becomeFirstResponder()

                self?.isValidateOTP = true
                self?.noOfOtpAttempt += 1
                Timer.scheduledTimer(timeInterval: TimeInterval(OTP_session_Time), target: self, selector:  #selector(self?.otpSessionExpired(timer:)), userInfo: nil, repeats: false)
                // CommonModel.sharedInstance.showAlertWithStatus(title: "", message:Confirm_Attendee_code, vc: self)

                //self.getEventDetailsData()

//                                //Store Attendee credential for auto login
//                                UserDefaults.standard.set("StoreCrential", forKey: "isAppUninstall")
//                                UserDefaults.standard.synchronize()
//                                CredentialHelper.shared.storeDefaultCredential(key: event.attendeeCode, value: event.eventId)

            }
            else {
                CommonModel.sharedInstance.showAlertWithStatus(title: "", message:response.value(forKey: "responseMsg") as! String, vc: self!)
            }
        }, errorBack: { error in
            NSLog("error in Auth token: %@", error)
        });
    }

    func validateOTP() {

        let parameters : NSDictionary = [ "EventId": EventData.sharedInstance.eventId, "OTPCode":self.otpTextField.text!, "AttendeeId": EventData.sharedInstance.attendeeId,]

        NetworkingHelper.postData(urlString:Get_ValidateOTP_Url, param:parameters, withHeader: false, isAlertShow: true, controller:self, callback: { [weak self] response in

            print("Validate OTP response : ", response)
            let responseCode = Int(response.value(forKey: "responseCode") as! String)

//            self?.attendeeCodeTextField.resignFirstResponder()
//            self?.delegate?.loginButtonTapped(selectedOption: "", textFieldValue: (self?.attendeeCodeTextField.text)!)
//            self?.dismiss(animated: true, completion: nil)

            if responseCode == 0 {
                self?.attendeeCodeTextField.resignFirstResponder()
                self?.delegate?.loginButtonTapped(selectedOption: "", textFieldValue: (self?.attendeeCodeTextField.text)!)
                self?.dismiss(animated: true, completion: nil)
            }
            else {
                CommonModel.sharedInstance.dissmissActitvityIndicator()
                CommonModel.sharedInstance.showAlertWithStatus(title: "", message:response.value(forKey: "responseMsg") as! String, vc: self!)
            }
        }, errorBack: { error in
            NSLog("error in Validate OTP : ", error)
        })
    }

    func resendOTP() {

        NetworkingHelper.getRequestFromUrl(name:Post_ResendOTP_Url, urlString: Post_ResendOTP_Url, callback: { [weak self] response in

            print("\n Resend OTP response : ", response)
            let responseCode = Int(response.value(forKey: "responseCode") as! String)

            if responseCode == 0 {
                self?.noOfOtpAttempt += 1
                Timer.scheduledTimer(timeInterval: TimeInterval(OTP_session_Time), target: self, selector:  #selector(self?.otpSessionExpired(timer:)), userInfo: nil, repeats: false)
            }
        }, errorBack: { error in
            NSLog("error in resend OTP : %@", error)
            self.resendOTPButton.isEnabled = true
        })
    }

    @objc func otpSessionExpired(timer: Timer) {

        self.resendOTPButton.isEnabled = true
        self.otpMessageLbl.isHidden = false
        timer.invalidate()
    }

    // MARK: - UITextFeild Delegate Methods

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if textField == self.otpTextField {
            let fieldTextLength = textField.text!.count

            if(fieldTextLength >= 5 && range.length == 0) {
                self.downloadButton.isEnabled = true
                if fieldTextLength == 5 {
                    self.otpTextField.text = self.otpTextField.text?.appending(string)
                }
                return false
            }
            else {
                self.downloadButton.isEnabled = false
            }
        }
        return true
    }

}


