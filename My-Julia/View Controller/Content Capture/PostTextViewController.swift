//
//  PostTextViewController.swift
//  My-Julia
//
//  Created by GCO on 06/06/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

class PostTextViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var postBtn: UIBarButtonItem!
    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var viewBottomContraint: NSLayoutConstraint!
    var placeholderLabel : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "New Feed"
        textField.delegate = self
        
        //Add Placeholder in textview
        placeholderLabel = UILabel()
        placeholderLabel.text = "Enter some text..."
        placeholderLabel.font = UIFont.systemFont(ofSize: (textField.font?.pointSize)!)
        placeholderLabel.sizeToFit()
        textField.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (textField.font?.pointSize)! / 2)
        placeholderLabel.textColor = AppTheme.sharedInstance.backgroundColor.darker(by: 40)!
        placeholderLabel.isHidden = !textField.text.isEmpty
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PostTextViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        //apply application theme on screen
        CommonModel.sharedInstance.applyThemeOnScreen(viewController: self, bgImage: bgImageView)
        
        self.postBtn.tintColor = AppTheme.sharedInstance.headerTextColor

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)

       // postBtn.showButtonTheme()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Keyboard Methods

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.viewBottomContraint.constant = keyboardSize.size.height + 10
            self.textField.updateConstraintsIfNeeded()
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.viewBottomContraint.constant = 0
            self.textField.updateConstraintsIfNeeded()
        }
    }

    // MARK: - Textview Delegate methods
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

        let result = (textView.text as NSString?)?.replacingCharacters(in: range, with: text)

        print("activity feed text character length : ",result?.count)

//        //Retrict feedback text length
//        if(textView.text.count > 498 && range.length == 0) {
//            return false
//        }

        return true
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        print("textViewDidEndEditing activity feed text character length : ",textView.text.count)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Button Action Methods
    
    @IBAction func postBtn(sender:UIButton)
    {
        if (textField.text?.trimmingCharacters(in: .whitespaces).isEmpty)! {
            CommonModel.sharedInstance.showAlertWithStatus(title: "", message: Enter_ActivityFeed_Post_Message, vc: self)
            return
        }
        self.postNewFeed()
    }

    // MARK: - Webservice Methods
    
    func postNewFeed() {

        //Show Indicator
        CommonModel.sharedInstance.showActitvityIndicator()
        
        let event = EventData.sharedInstance

//        // Create an instance of HTMLConverter.
//        let converter : HTMLConverter = HTMLConverter()
//
//        // Prepare an input text.
//        let input : String = textField.text
//
//        // Convert the plain text into an HTML text using the converter.
//        let output : String = converter.toHTML(input)
//
//        print("html Output : ",output)

        let paramDict : NSMutableDictionary? = ["Comment":textField.text ,"AttendeeId":AttendeeInfo.sharedInstance.attendeeId, "EventId":event.eventId]

        NetworkingHelper.postData(urlString:Post_Activity_Feed_url, param:paramDict as AnyObject, withHeader: false, isAlertShow: true, controller:self, callback: { [weak self] response in
            //dissmiss Indicator
            CommonModel.sharedInstance.dissmissActitvityIndicator()

            if response is NSDictionary {
                if (response.value(forKey: "responseCode") != nil) {
                    // CommonModel.sharedInstance.showAlertWithStatus(message: Feedback_Sucess_Message, vc: self)
                    self?.navigationController?.popViewController(animated: true)
                }
                else {
                    // CommonModel.sharedInstance.showAlertWithStatus(message: Feedback_Error_Message, vc: self)
                }
            }
        }, errorBack: { error in
        })
    }
    
}
