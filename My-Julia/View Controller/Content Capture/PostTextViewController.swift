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
    
//    func convertHtml(str : String) -> NSAttributedString{
//
//        let attrStr = NSAttributedString(string: str)
//       // let documentAttributes = [NSAttributedString.DocumentAttributeKey:NSAttributedString.DocumentType.html]
//
//        let documentAttributes = [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType]
//
//        do {
//            let htmlData = try attrStr.dataFromRange(NSMakeRange(0, attrStr.length), documentAttributes:documentAttributes)
//            if let htmlString = String(data:htmlData, encoding:NSUTF8StringEncoding) {
//                print("htmlString : ",htmlString)
//            }
//        }
//        catch {
//            print("error creating HTML from Attributed String")
//        }
//
//    }

    // MARK: - Webservice Methods
    
    func postNewFeed() {

        //let str = self.convertHtml(str: textField.text )
       // print("String : ",str)

        //Show Indicator
        CommonModel.sharedInstance.showActitvityIndicator()
        
        let event = EventData.sharedInstance

        // Create an instance of HTMLConverter.
        let converter : HTMLConverter = HTMLConverter()

        // Prepare an input text.
        let input : String = textField.text

        // Convert the plain text into an HTML text using the converter.
        let output : String = converter.toHTML(input)
        print("html Output : ",output)

        let paramDict : NSMutableDictionary? = ["Comment":output ,"AttendeeId":AttendeeInfo.sharedInstance.attendeeId, "EventId":event.eventId]
        print("Post Data : ",paramDict ?? "")

//        var testString =  String(format: "<h> %@ </h>",textField.text )
//
//        print("Post text : ",testString )
//        do {
//            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
//            let range = NSRange(location: 0, length: (testString.count))
//            let block = { (result: NSTextCheckingResult?, flags: NSRegularExpression.MatchingFlags, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
//                if let newResult = result, newResult.resultType == NSTextCheckingResult.CheckingType.link {
//                    print("Found link: ",(newResult.url?.isFileURL)! ? newResult.url?.path : newResult.url?.absoluteString ?? "")
//                    let htmlLessString: String = detector.stringByReplacingMatches(in: testString, options: NSRegularExpression.MatchingOptions(), range:range, withTemplate: String(format: "<a href='%@'>%@</a>",newResult.url! as CVarArg,newResult.url! as CVarArg ))
//                    print("htmlLessString  : ",htmlLessString)
//                 // testString = testString.replacingOccurrences(of: String(format: "%@",result! ), with: String(format: "<a href='%@'>%@</a>",newResult.url! as CVarArg,newResult.url! as CVarArg ), options: NSString.CompareOptions.literal, range: nil)
//                }
//            }
//            detector.enumerateMatches(in: testString, options: [], range: range, using: block)
//        } catch {
//            print(error)
//        }
//
//        print("After editing text : ",testString )

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
