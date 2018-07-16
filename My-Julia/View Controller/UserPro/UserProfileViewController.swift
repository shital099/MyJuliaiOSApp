//
//  UserProfileViewController.swift
//  My-Julia
//
//  Created by GCO on 10/3/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit
import AssetsLibrary
import MobileCoreServices

class UserProfileViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var userIcon: UIImageView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var designationLabel: UILabel!
    @IBOutlet weak var groupLabel: UILabel!
    @IBOutlet weak var contactLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var editbtn : UIButton!
    @IBOutlet weak var editproBtn : UIButton!
    @IBOutlet weak var switchSet: UISwitch!
    @IBOutlet weak var editImageIcon : UIImageView!
    @IBOutlet weak var dndSwitchSet: UISwitch!

    
    let picker = UIImagePickerController()
    var actionSheetContoller : UIAlertController!
    var profileImage : UIImage!
    var profileImgName : String = ""
    var alertView : TKAlert!
    var isFromPendingAction : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = "Profile"

        self.userIcon.layoutIfNeeded()
        userIcon.layer.cornerRadius = userIcon.frame.size.width / 2
        userIcon.clipsToBounds = true
        userIcon.layer.borderColor = UIColor.gray.cgColor
        userIcon.layer.borderWidth = 3.0
        
        
        topView.layer.cornerRadius = 3.0
        if AppTheme.sharedInstance.isHeaderColor {
            topView.backgroundColor = AppTheme.sharedInstance.headerColor
        }
        else {
            topView.backgroundColor = UIColor.darkGray
        }
        
        //Fetch profile data
        _ = DBManager.sharedInstance.fetchProfileDataFromDB()

        nameLabel.text = AttendeeInfo.sharedInstance.attendeeName
        designationLabel.text = AttendeeInfo.sharedInstance.designation
        groupLabel.text = AttendeeInfo.sharedInstance.group
        emailLabel.text = AttendeeInfo.sharedInstance.email
        contactLabel.text = AttendeeInfo.sharedInstance.number
        switchSet.isOn = AttendeeInfo.sharedInstance.isvisible
        dndSwitchSet.isOn = AttendeeInfo.sharedInstance.isDND

        if (AttendeeInfo.sharedInstance.iconUrl != BASE_URL) {
            //Check internet connection
            if AFNetworkReachabilityManager.shared().isReachable == true {
                SDImageCache.shared().removeImage(forKey: AttendeeInfo.sharedInstance.iconUrl, withCompletion: nil)
            }

            userIcon.sd_setImage(with: URL(string:AttendeeInfo.sharedInstance.iconUrl), placeholderImage: #imageLiteral(resourceName: "user"))
            userIcon.contentMode = UIViewContentMode.scaleAspectFill
            userIcon.clipsToBounds = true
         }
        else {
            userIcon.image = #imageLiteral(resourceName: "user")
        }
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
    
    // MARK: - Button Action Methods

    @IBAction func profileSettingValueChange(sender: UISwitch) {
        
        if sender == self.dndSwitchSet {
            //Update Do not disturb setting
            self.postVisiblity(isProfileImg: false)
        }
        else {
            //Update Profile visibility setting
            self.postVisiblity(isProfileImg: false)
        }
   }
    
    @IBAction func editProIcon(sender: UIButton) {

        //Check internet connection
        if AFNetworkReachabilityManager.shared().isReachable == true {
            let result = AttachmentHandler.shared.authorisationStatusCheck(attachmentTypeEnum: AttachmentHandler.AttachmentType.photoLibrary, vc: self)
            if result == true {

                //self.showActionSheet()
                if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {

                    self.picker.allowsEditing = true
                    self.picker.sourceType = .photoLibrary
                    self.picker.modalPresentationStyle = .overFullScreen
                    self.picker.delegate = self
                    self.picker.mediaTypes = [kUTTypeImage as String] //UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
                    self.present(self.picker, animated: true, completion: nil)
                }
            }
        }
        else {
            CommonModel.sharedInstance.showAlertWithStatus(title: "Error", message: Internet_Error_Message, vc: self)
        }
    }
    
    @IBAction func closeButtonClick(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - UIImagePickerController Delegates Methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
       let chosenImage = CommonModel.sharedInstance.resizeImage(image: info[UIImagePickerControllerOriginalImage] as! UIImage, newWidth: 200)
        self.userIcon.image = chosenImage
        
        var fileName = ""
        
        if let mediaType = info[UIImagePickerControllerMediaType] as? String {
            
            if mediaType == "public.movie" {
                return
            }
        }
        
        if let referenceUrl = info[UIImagePickerControllerReferenceURL] as? NSURL {
            
            ALAssetsLibrary().asset(for: referenceUrl as URL?, resultBlock: { asset in
                fileName = (asset?.defaultRepresentation().filename())!
                //do whatever with your file name
                print("File name", fileName )
                if fileName != "" {
                    fileName = fileName.components(separatedBy: ".").first!
                }
                
            }, failureBlock: {_ in
                print("Failed access")
            })
        }
        else {
            let imageNo = Int(arc4random_uniform(1000) + 1)
            fileName = "CapturedPhoto".appendingFormat("%d", imageNo)
        }
        
        self.profileImgName = fileName
        self.profileImage = chosenImage
        dismiss(animated:true, completion: nil) //5
        
        //Update Profile picture
        self.postVisiblity(isProfileImg: true)
    }
    
    
    //MARK: - Web Service Methods
    
    func postVisiblity(isProfileImg : Bool) {
        
        //Show Indicator
        CommonModel.sharedInstance.showActitvityIndicator()

        var paramDict : Dictionary<String, Any>!

        if isProfileImg {
            var imageString = ""
            if profileImage != nil {
                let imageData = UIImageJPEGRepresentation(profileImage, 0)
                imageString = (imageData?.base64EncodedString())!
            }
            
            paramDict = ["EventId" : EventData.sharedInstance.eventId, "AttendeeId" : EventData.sharedInstance.attendeeId, "Image" : imageString, "ImgName" : self.profileImgName, "IsVisible" : switchSet.isOn, "IsDND" : dndSwitchSet.isOn] as [String : Any]
        }
        else {
            paramDict = ["EventId" : EventData.sharedInstance.eventId, "AttendeeId" : EventData.sharedInstance.attendeeId, "IsVisible" : switchSet.isOn, "IsDND" : dndSwitchSet.isOn] as [String : Any]
        }
        
        NetworkingHelper.postData(urlString: Post_Visiblity_url, param: paramDict as AnyObject, withHeader: false, isAlertShow: true, controller:self, callback: { [weak self] response in
            
            //Dismiss Indicator
            CommonModel.sharedInstance.dissmissActitvityIndicator()

            let responseCode = Int(response.value(forKey: "responseCode") as! String)
            if responseCode == 0 {
                let iconurl = DBManager.sharedInstance.appendImagePath(path: response.value(forKey: "Imgpath") as! String)
                _ = NSURL(string:iconurl)! as URL
                DBManager.sharedInstance.updateUserProfileDataIntoDB(setting: (self?.switchSet.isOn)!, dnd: (self?.dndSwitchSet.isOn)!, profileImgPath:iconurl)
                AttendeeInfo.sharedInstance.isvisible = (self?.switchSet.isOn)!
                AttendeeInfo.sharedInstance.isDND = (self?.dndSwitchSet.isOn)!
                CommonModel.sharedInstance.showAlertWithStatus(title: Alert_Sucess, message: Sucess_Update_Profile, vc: self!)


                if self?.isFromPendingAction == true {
                    let masterVC : UIViewController!
                    if IS_IPHONE {
                        masterVC =  self?.menuContainerViewController.leftMenuViewController as! MenuViewController?
                    }
                    else {
                        masterVC = self?.splitViewController?.viewControllers.first
                    }

                    if ((masterVC as? MenuViewController) != nil) {

                        //Show user profile picture
                        if (!AttendeeInfo.sharedInstance.iconUrl.isEmpty) {
                            //Check internet connection
                            if AFNetworkReachabilityManager.shared().isReachable == true {
                                SDImageCache.shared().removeImage(forKey: AttendeeInfo.sharedInstance.iconUrl, withCompletion: nil)
                            }
                            (masterVC as? MenuViewController)?.userProfileIcon.sd_setImage(with: URL(string:AttendeeInfo.sharedInstance.iconUrl), placeholderImage: UIImage(named: "user-profile"))
                        }
                    }
                }
            }
        }, errorBack: { error in
        })
    }
    
}
