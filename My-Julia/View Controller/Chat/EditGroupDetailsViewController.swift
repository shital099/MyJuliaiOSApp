//
//  EditGroupDetailsViewController.swift
//  My-Julia
//
//  Created by GCO on 08/02/2018.
//  Copyright © 2018 GCO. All rights reserved.
//

import UIKit

class EditGroupDetailsViewController: UIViewController, UIImagePickerControllerDelegate,UIActionSheetDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var groupIconView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var editIconButton: UIBarButtonItem!
    @IBOutlet weak var nameEditView: UIView!
    @IBOutlet weak var cancelBtn: UIButton!

    var actionSheetContoller : UIAlertController!
    var isIconEdit : Bool = true
    var capturedPhoto : UIImage!
    var chatGroupModel: ChatGroupModel!
    var delegate : UIViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.cornerRadius = 3.0
        textField.layer.borderWidth = 1.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {

        self.textField.text = self.chatGroupModel.name

        //Check is icon editing or name
        if isIconEdit {
            self.nameEditView.isHidden = true
            self.groupIconView.sd_setImage(with: URL(string:self.chatGroupModel.iconUrl), placeholderImage: #imageLiteral(resourceName: "no_group_icon"), options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
                // Perform operation.
                if image == nil {
                    self.onClickOfEditPhotoBtn(sender: self.editIconButton)
                }
            })
        }
        else {
            self.navigationItem.rightBarButtonItem = nil
            self.groupIconView.isHidden = true
            self.textField.becomeFirstResponder()
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

    @IBAction func onClickOfSaveBtn(sender : AnyObject) {
        //Update Group information group
        self.updateGroupInfo()
    }

    @IBAction func onClickOfCancelBtn(sender : AnyObject) {
       // self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: false)
    }

    @IBAction func onClickOfBackBtn(sender : AnyObject) {
       // self.dismiss(animated: true, completion: nil)
    }

    @IBAction func onClickOfEditPhotoBtn(sender : AnyObject) {

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
            picker.allowsEditing = true
            //picker.cameraCaptureMode = .photo
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.present(picker, animated: true, completion: nil)
        })
        let noIconAction = UIAlertAction(title: "Remove icon", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.capturedPhoto = nil
            SDImageCache.shared().removeImage(forKey: self.chatGroupModel.iconUrl, withCompletion: nil)
            self.groupIconView.image = #imageLiteral(resourceName: "no_group_icon")
            self.updateGroupInfo()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })

        // 4
        actionSheetContoller.addAction(selfieAction)
        actionSheetContoller.addAction(photoAction)
        actionSheetContoller.addAction(noIconAction)
        actionSheetContoller.addAction(cancelAction)
        // 5
        actionSheetContoller.popoverPresentationController?.sourceView = self.editIconButton.customView
        actionSheetContoller.popoverPresentationController?.barButtonItem = self.editIconButton

        // this is the center of the screen currently but it can be any point in the view
        // }
        self.present(actionSheetContoller, animated: true, completion: nil)
    }

    //MARK: - UIImagePickerController Delegates Methods

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        capturedPhoto = info[UIImagePickerControllerEditedImage] as! UIImage
        self.groupIconView.image = capturedPhoto
        dismiss(animated:true, completion: nil) //5

        //Update group profile icon
        self.updateGroupInfo()
    }


    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated:true, completion: nil) //5
    }

    // MARK: - Web Service methods

    func updateGroupInfo() {

        if (self.textField.text?.trimmingCharacters(in: .whitespaces).isEmpty)! {
            CommonModel.sharedInstance.showAlertWithStatus(title: "", message: GroupName_Validation_Message, vc: self)
            return
        }

        //Show Indicator
        CommonModel.sharedInstance.showActitvityIndicator()
        //Rotate image
        var paramDict : [String : Any]
        if isIconEdit == true {
            var base64String = ""
            if capturedPhoto != nil {
                capturedPhoto = self.groupIconView.image
                capturedPhoto = capturedPhoto.fixedOrientation().imageRotatedByDegrees(degrees: 360)
                let imageData = UIImageJPEGRepresentation(capturedPhoto, 0)
                base64String = (imageData?.base64EncodedString())!
            }

            paramDict = [
                "CreatedBy":self.chatGroupModel.groupCreatedUserId,
                "Id":self.chatGroupModel.groupId,
                "GroupName":self.chatGroupModel.name,
                "Image" : base64String,
                "EventId":EventData.sharedInstance.eventId] as [String : Any]
        }
        else {
            paramDict = [
                "CreatedBy":self.chatGroupModel.groupCreatedUserId,
                "Id":self.chatGroupModel.groupId,
                "GroupName":textField.text ?? "",
                "EventId":EventData.sharedInstance.eventId] as [String : Any]
        }

        NetworkingHelper.postData(urlString:Chat_Update_Group, param:paramDict as AnyObject, withHeader: false, isAlertShow: true, controller:self, callback: { [weak self] response in
            //dissmiss Indicator
            CommonModel.sharedInstance.dissmissActitvityIndicator()
            print("Update Chat Group response : ", response)

            let responseCode = Int(response.value(forKey: "responseCode") as! String)
            if responseCode == 0 {

                //Show updated group name in group detail screen
                if self?.isIconEdit == false {
                    //Update group name and image into db
                    let iconImage = DBManager.sharedInstance.appendImagePath(path: response.value(forKey: "ImagePath") as Any)

                    DBManager.sharedInstance.updateGroupNameIntoDB(groupName: (self?.textField.text)!, groupIcon:iconImage, groupId: (self?.chatGroupModel.groupId)!)
                    (self?.delegate as! GroupDetailViewController).updateGroupName(groupName: (self?.textField.text)!, groupIcon : iconImage)
                }
                //self.dismiss(animated: true, completion: nil)
                self?.navigationController?.popViewController(animated: false)
            }
        }, errorBack: { error in
            print("Error while updating group info",error)
        })
    }
}
