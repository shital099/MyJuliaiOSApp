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


    var originalImage : UIImage!
    //var iconImage : UIImage!
    var imageName : String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "New Feed"
        
        // Do any additional setup after loading the view.
        capturedImageView.image = originalImage

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
        originalImage = originalImage.fixedOrientation().imageRotatedByDegrees(degrees: 360)
        let image = originalImage.resized(withPercentage: 0.7)
        let imgData: NSData = NSData(data: UIImageJPEGRepresentation((image)!, 1)!)
        let imageSize: Int = imgData.length
        print("uploading size of image in KB: %f ", Double(imageSize) / 1024.0)

        let resizedImage = originalImage.resized(withPercentage: 0.1)
        let rImgData: NSData = NSData(data: UIImageJPEGRepresentation((resizedImage)!, 0)!)
        let rImageSize: Int = rImgData.length
        print("resize uploading size of image in KB: %f ", Double(rImageSize) / 1024.0)

        let imageData = UIImageJPEGRepresentation(originalImage, 0)
        let originalIamgeStr = imageData?.base64EncodedString()
        let resizedImageStr = rImgData.base64EncodedString()

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
        
        let paramDict : NSMutableDictionary? = ["ImgData":originalIamgeStr ?? "",
                                                "ThubmnailImgData":resizedImageStr ,
                                                "ContentType": "image/jpeg",
                                                "ImgName": "",
                                                "Comment":output ,
                                                "AttendeeId":AttendeeInfo.sharedInstance.attendeeId,
                                                "EventId":EventData.sharedInstance.eventId]
       // print("paramDict",              paramDict )

        NetworkingHelper.postData(urlString:Post_Activity_Feed_url, param:paramDict as AnyObject, withHeader: false, isAlertShow: true, controller:self, callback: { [weak self] response in
            //dissmiss Indicator
            CommonModel.sharedInstance.dissmissActitvityIndicator()
            
            print("Post Content Details response : ", response)
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

extension UIImage {

    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func resizedTo1MB() -> UIImage? {
        guard let imageData = UIImagePNGRepresentation(self) else { return nil }

        var resizingImage = self
        var imageSizeKB = Double(imageData.count) / 1000.0 // ! Or devide for 1024 if you need KB but not kB

        while imageSizeKB > 1000 { // ! Or use 1024 if you need KB but not kB
            guard let resizedImage = resizingImage.resized(withPercentage: 0.9),
                let imageData = UIImagePNGRepresentation(resizedImage)
                else { return nil }

            resizingImage = resizedImage
            imageSizeKB = Double(imageData.count) / 1000.0 // ! Or devide for 1024 if you need KB but not kB
        }

        return resizingImage
    }
}
