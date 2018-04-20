//
//  PostPhotoViewController.swift
//  My-Julia
//
//  Created by GCO on 6/5/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

class PostPhotoViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var capturedImageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    var placeholderLabel : UILabel!


    var capturedPhoto : UIImage!
    var imageName : String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "New Feed"
        
        // Do any additional setup after loading the view.
        capturedImageView.image = capturedPhoto

        textView.delegate = self
        
        //Add Placeholder in textview
        placeholderLabel = UILabel()
        placeholderLabel.text = "Enter some text..."
        placeholderLabel.font = UIFont.systemFont(ofSize: (textView.font?.pointSize)!)
        placeholderLabel.sizeToFit()
        textView.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (textView.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.isHidden = !textView.text.isEmpty
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PostPhotoViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        self.navigationItem.leftBarButtonItem?.tintColor = AppTheme.sharedInstance.headerTextColor
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    } 

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Button Action Methods
    
    @IBAction func onClickOfPostButton(sender: AnyObject) {
        
        //Rotate image
        capturedPhoto = capturedPhoto.fixedOrientation().imageRotatedByDegrees(degrees: 360)

        let imageData = UIImageJPEGRepresentation(capturedPhoto, 0)
        let base64String = imageData?.base64EncodedString()
        // print("base64String : ", base64String ?? "")

        // Create an instance of HTMLConverter.
        let converter : HTMLConverter = HTMLConverter()

        // Prepare an input text.
        let input : String = textView.text

        // Convert the plain text into an HTML text using the converter.
        let output : String = converter.toHTML(input)
        print("html Output : ",output)

        //Show Indicator
        CommonModel.sharedInstance.showActitvityIndicator()
        
        let paramDict : NSMutableDictionary? = ["ImgData":base64String ?? "",
                                                "ContentType": "image/jpeg",
                                                "ImgName": "",
                                                "Comment":output ,
                                                "AttendeeId":AttendeeInfo.sharedInstance.attendeeId,
                                                "EventId":EventData.sharedInstance.eventId]
       // print("paramDict",              paramDict )

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
