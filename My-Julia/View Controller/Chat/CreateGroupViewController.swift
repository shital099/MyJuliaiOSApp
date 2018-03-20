//
//  CreateGroupViewController.swift
//  My-Julia
//
//  Created by GCO on 8/17/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit
import AssetsLibrary

class CreateGroupViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate,UIActionSheetDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var addPhotoBtn: UIButton!

    var groupId : String? = nil
    var listArray:NSMutableArray = []
    var actionSheetContoller : UIAlertController!
    var capturedPhoto : UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "New group"

        self.addPhotoBtn.layer.cornerRadius = self.addPhotoBtn.frame.size.height/2
        self.addPhotoBtn.clipsToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)
        
        if (self.isMovingFromParentViewController){
            // Your code...
            self.navigationController?.popToRootViewController(animated: false)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - Button Action methods

    @IBAction func onClickOfCreateBtn(sender : AnyObject) {

        if textField.text == "" {
            CommonModel.sharedInstance.showAlertWithStatus(title: "", message: Empty_Group_Name_Message, vc: self)
            return
        }
        
        //Create group
        self.createGroup()
    }

    @IBAction func onClickOfAddPhotoBtn(sender : AnyObject) {
        //Choose Button Image
        self.showActionSheet()
    }

    func showActionSheet() {

        // if actionSheetContoller == nil {

        // 1
        actionSheetContoller = UIAlertController(title: nil, message: "Choose profile picture", preferredStyle: .actionSheet)

        // 2
        let selfieAction = UIAlertAction(title: "Take from Camera", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = UIImagePickerControllerSourceType.camera
            picker.cameraCaptureMode = .photo
            picker.allowsEditing = true
            self.present(picker, animated: true, completion: nil)
        })
        let photoAction = UIAlertAction(title: "Take from Library", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            let picker = UIImagePickerController()
            picker.delegate = self
            //picker.cameraCaptureMode = .photo
            picker.allowsEditing = true
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.present(picker, animated: true, completion: nil)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })

        // 4
        actionSheetContoller.addAction(selfieAction)
        actionSheetContoller.addAction(photoAction)
        actionSheetContoller.addAction(cancelAction)
        // 5
        actionSheetContoller.popoverPresentationController?.sourceView = self.addPhotoBtn
        actionSheetContoller.popoverPresentationController?.sourceRect = self.addPhotoBtn.bounds

        // this is the center of the screen currently but it can be any point in the view
        // }
        self.present(actionSheetContoller, animated: true, completion: nil)
    }

    //MARK: - UIImagePickerController Delegates Methods

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        self.capturedPhoto = info[UIImagePickerControllerEditedImage] as! UIImage
        addPhotoBtn.setBackgroundImage(self.capturedPhoto, for: .normal)
        dismiss(animated:true, completion: nil) //5
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated:true, completion: nil) //5
    }

    // MARK: - Web Service methods
    
    func createGroup() {
        
        //Add member in already created group
        if self.groupId != nil {
            self.addMembersInGroup(groupId: self.groupId!)
            return
        }
        
        //Show Indicator
        CommonModel.sharedInstance.showActitvityIndicator()
        //Rotate image
//        capturedPhoto = capturedPhoto.fixedOrientation().imageRotatedByDegrees(degrees: 360)
//        let imageData = UIImageJPEGRepresentation(capturedPhoto, 0)
//        let base64String = imageData?.base64EncodedString()

        var paramDict : [String : Any]
        var base64String = ""
        if capturedPhoto != nil {
            capturedPhoto = capturedPhoto.fixedOrientation().imageRotatedByDegrees(degrees: 360)
            let imageData = UIImageJPEGRepresentation(capturedPhoto, 0)
            base64String = (imageData?.base64EncodedString())!

            paramDict = [
            "CreatedBy":AttendeeInfo.sharedInstance.attendeeId,
            "GroupName":textField.text ?? "",
            "Image" : base64String ,
            "EventId":EventData.sharedInstance.eventId] as [String : Any]
        }
        else {
            paramDict = [
                "CreatedBy":AttendeeInfo.sharedInstance.attendeeId,
                "GroupName":textField.text ?? "",
                "Image" : "",
                "EventId":EventData.sharedInstance.eventId] as [String : Any]
        }

        NetworkingHelper.postData(urlString:Chat_Create_Group, param:paramDict as AnyObject, withHeader: false, isAlertShow: true, controller:self, callback: { response in
            //dissmiss Indicator
            CommonModel.sharedInstance.dissmissActitvityIndicator()
            print("Create Chat Group response : ", response)
            
            let responseCode = Int(response.value(forKey: "responseCode") as! String)
            if responseCode == 0 {
                //Add group members in groups
                 self.groupId = response.value(forKey: "GroupId") as? String
                self.addMembersInGroup(groupId: response.value(forKey: "GroupId") as! String)
            }
        }, errorBack: { error in
            print("Create group error : ",error)
        })
    }
    
    func addMembersInGroup(groupId : String) {
        
        //Show Indicator
        CommonModel.sharedInstance.showActitvityIndicator()
        
        var paramArr : [Any] = []
        for item in self.listArray {
            let model = item as! ChatGroupModel
            paramArr.append(model.groupId)
        }
        
        let paramDict = ["GroupChatId":self.groupId ?? "", "AttendeeId":paramArr] as [String : Any]
        print("Add group member : ",paramDict)

        NetworkingHelper.postData(urlString:Chat_Add_Group_Members, param:paramDict as AnyObject, withHeader: false, isAlertShow: true, controller:self, callback: { response in
            //dissmiss Indicator
            CommonModel.sharedInstance.dissmissActitvityIndicator()
            print("Group Members response : ", response)
            
            let responseCode = Int(response.value(forKey: "responseCode") as! String)
            if responseCode == 0 {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }, errorBack: { error in
        })
    }

    // MARK: - UICollectionViewDataSource
    //1
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //2
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return self.listArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        var headerView : HomeCollectionHeaderView? = nil
        //1
        switch kind {
        //2
        case UICollectionElementKindSectionHeader:
            //3
            headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                             withReuseIdentifier: "HomeCollectionHeaderView",
                                                                             for: indexPath) as? HomeCollectionHeaderView
            headerView?.headerTitleLbl?.text = String(format: "Group members - %d", self.listArray.count)
            break
        default:
            //4
            assert(false, "Unexpected element kind")
            break
        }
        return headerView!
    }
    
    //3
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemberCustomCell", for: indexPath) as! MemberCustomCell
        // cell.backgroundColor = UIColor.black
        
        let model = self.listArray[indexPath.row] as! ChatGroupModel
        
        cell.titleLbl?.text = model.name
        cell.iconImage?.sd_setImage(with: NSURL(string:model.iconUrl as String)! as URL, placeholderImage: #imageLiteral(resourceName: "user"))
        
        cell.iconImage?.layer.cornerRadius = (cell.iconImage?.frame.height)!/2
       // cell.iconImage?.layer.borderWidth = 1.0
      // cell.titleLbl?.textColor = UIColor.darkGray
        return cell
    }
}


//#prama - Custom cell class

class MemberCustomCell: UICollectionViewCell {
    
    @IBOutlet var titleLbl:UILabel?
    @IBOutlet var iconImage:UIImageView?
}
