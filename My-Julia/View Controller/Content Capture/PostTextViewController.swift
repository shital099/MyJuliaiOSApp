//
//  PostTextViewController.swift
//  EventApp
//
//  Created by GCO on 06/06/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

class PostTextViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var postBtn: UIBarButtonItem!
    @IBOutlet weak var textField: UITextView!
    var placeholderLabel : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "New Feed"
        
//        textField.layer.borderColor = UIColor.darkGray.cgColor
//        textField.layer.borderWidth = 0.5
//        textField.layer.cornerRadius = 5
        
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

       // postBtn.showButtonTheme()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Textview Delegate methods
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
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
        
        let paramDict : NSMutableDictionary? = ["Comment":textField.text ,"AttendeeId":AttendeeInfo.sharedInstance.attendeeId, "EventId":event.eventId]
        
        NetworkingHelper.postData(urlString:Post_Activity_Feed_url, param:paramDict as AnyObject, withHeader: false, isAlertShow: true, controller:self, callback: { response in
            //dissmiss Indicator
            CommonModel.sharedInstance.dissmissActitvityIndicator()
            
            print("Post Content Details response : ", response)
            if response is NSDictionary {
                if (response.value(forKey: "responseCode") != nil) {
                    // CommonModel.sharedInstance.showAlertWithStatus(message: Feedback_Sucess_Message, vc: self)
                    self.navigationController?.popViewController(animated: true)
                }
                else {
                    // CommonModel.sharedInstance.showAlertWithStatus(message: Feedback_Error_Message, vc: self)
                }
            }
        }, errorBack: { error in
        })
    }
    
}
