//
//  ContentCaptureViewController.swift
//  My-Julia
//
//  Created by GCO on 6/5/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit
import AssetsLibrary

class ContentCaptureViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate {

    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var cameraBtn: DesignableButton!
    @IBOutlet weak var textBtn: DesignableButton!
    @IBOutlet weak var libraryBtn: DesignableButton!
    
    
    var likeButtonTapped: ((QuestionsCustomCell, AnyObject) -> Void)?

    let picker = UIImagePickerController()
    var actionSheetContoller : UIAlertController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    
        picker.delegate = self
        
        //Show menu icon in ipad and iphone
        self.setupMenuBarButtonItems()
        
        //        if IS_IPHONE {
        //            self.setupMenuBarButtonItems()
        //        }

        
        //apply application theme on screen
        CommonModel.sharedInstance.applyThemeOnScreen(viewController: self, bgImage: bgImageView)
        
        textBtn.showButtonTheme()
        cameraBtn.showButtonTheme()
        libraryBtn.showButtonTheme()

//        textBtn.topColor = AppTheme.sharedInstance.backgroundColor.getDarkerColor()
//        textBtn.middleColor = AppTheme.sharedInstance.backgroundColor.darker(by: 10)!
//        textBtn.bottomColor = AppTheme.sharedInstance.backgroundColor.getDarkerColor()
//        textBtn.borderColor = AppTheme.sharedInstance.backgroundColor.darker(by: 25)!
//
//        cameraBtn.topColor = AppTheme.sharedInstance.headerColor.getDarkerColor()
//        cameraBtn.middleColor = AppTheme.sharedInstance.headerColor.darker(by: 10)!
//        cameraBtn.bottomColor = AppTheme.sharedInstance.headerColor.getDarkerColor()
//        cameraBtn.borderColor = AppTheme.sharedInstance.headerColor.darker(by: 25)!
//
//        libraryBtn.topColor = UIColor.white.getDarkerColor()
//        libraryBtn.middleColor = UIColor.white.darker(by: 10)!
//        libraryBtn.bottomColor = UIColor.white.getDarkerColor()
//        libraryBtn.borderColor = UIColor.white.darker(by: 25)!

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
    
    @IBAction func onClickOfPostText(sender: AnyObject) {
        
        let viewController = storyboard?.instantiateViewController(withIdentifier: "PostTextViewController") as! PostTextViewController
        self.navigationController?.pushViewController(viewController, animated: true)

    }

    @IBAction func onClickOfCamera(sender: AnyObject) {

        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            
            picker.allowsEditing = false
            picker.sourceType = .camera
            picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera)!
            self.showActionSheet()
       }
    }
    
    @IBAction func onClickOfPhotoGallery(sender: AnyObject) {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            
            picker.allowsEditing = true
            picker.sourceType = .photoLibrary
            picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
           // picker.modalPresentationStyle = .popover
            present(picker, animated: true, completion: nil)
            //picker.popoverPresentationController?.barButtonItem = sender
        }
    }
    
    func showActionSheet() {
        
       // if actionSheetContoller == nil {
            
            // 1
            actionSheetContoller = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
            
            // 2
            let selfieAction = UIAlertAction(title: "Take Selfie", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.picker.cameraCaptureMode = .photo
                self.picker.cameraDevice = .front
                self.present(self.picker, animated: true, completion: nil)

            })
            let photoAction = UIAlertAction(title: "Take Photo", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.picker.cameraCaptureMode = .photo
                self.picker.cameraDevice = .rear
                self.present(self.picker, animated: true, completion: nil)

            })
//            let videoAction = UIAlertAction(title: "Record Video", style: .default, handler: {
//                (alert: UIAlertAction!) -> Void in
//                
//                print("Record Video")
//                self.picker.cameraCaptureMode = .video
//                self.picker.cameraDevice = .rear
//                self.present(self.picker, animated: true, completion: nil)
//            })
            //
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
                (alert: UIAlertAction!) -> Void in
            })
            
            // 4
            actionSheetContoller.addAction(selfieAction)
            actionSheetContoller.addAction(photoAction)
          //  actionSheetContoller.addAction(videoAction)
            actionSheetContoller.addAction(cancelAction)
            // 5
            actionSheetContoller.popoverPresentationController?.sourceView = self.cameraBtn
            actionSheetContoller.popoverPresentationController?.sourceRect = self.cameraBtn.bounds
        

            // this is the center of the screen currently but it can be any point in the view
       // }
        self.present(actionSheetContoller, animated: true, completion: nil)

    }
    
    //MARK: - UIImagePickerController Delegates Methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        UIImageWriteToSavedPhotosAlbum(chosenImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
       
        var fileName = ""
        
        // let fixedImage:UIImage? = chosenImage.fixImageOrientation()
        
        if let mediaType = info[UIImagePickerControllerMediaType] as? String {
            
            if mediaType  == "public.image" {
            }
            
            if mediaType == "public.movie" {
                return
            }
        }
        
        if let referenceUrl = info[UIImagePickerControllerReferenceURL] as? NSURL {
            
            ALAssetsLibrary().asset(for: referenceUrl as URL!, resultBlock: { asset in
                fileName = (asset?.defaultRepresentation().filename())!
                //do whatever with your file name
                if fileName != "" {
                    fileName = fileName.components(separatedBy: ".").first!
                }
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "PostPhotoViewController") as! PostPhotoViewController
                viewController.originalImage = chosenImage
                viewController.imageName = fileName
                self.navigationController?.pushViewController(viewController, animated: true)
                
            }, failureBlock: nil)
        }
        else {
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "PostPhotoViewController") as! PostPhotoViewController
            viewController.originalImage = chosenImage
            let imageNo = Int(arc4random_uniform(1000) + 1)
            viewController.imageName = "CapturedPhoto".appendingFormat("%d", imageNo)
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        dismiss(animated:true, completion: nil) //5
        
    }
    
    //MARK: - Add image to Library
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if error != nil {
            // we got back an error!
        } else {
        }
    }


    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated:true, completion: nil) //5
    }
    
    // MARK: - Navigation UIBarButtonItems
    
    func setupMenuBarButtonItems() {
        // self.navigationItem.rightBarButtonItem = self.rightMenuBarButtonItem()
        let barItem = CommonModel.sharedInstance.leftMenuBarButtonItem()
        barItem.target = self;
        barItem.action = #selector(self.leftSideMenuButtonPressed(sender:))
        self.navigationItem.leftBarButtonItem = barItem
    }
    
    @objc func leftSideMenuButtonPressed(sender: UIBarButtonItem) {
        let masterVC : UIViewController!
        if IS_IPHONE {
            masterVC =  self.menuContainerViewController.leftMenuViewController as! MenuViewController!
        }
        else {
            masterVC = self.splitViewController?.viewControllers.first
        }
        
        if ((masterVC as? MenuViewController) != nil) {
            (masterVC as! MenuViewController).toggleLeftSplitMenuController()
        }
    }

    @objc func backAction(){
        //print("Back Button Clicked")
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "< Back", style: .plain, target: self, action: #selector(backAction))

        dismiss(animated: true, completion: nil)
    }
}

//extension UIImage {
//    func fixOrientation() -> UIImage {
//        if self.imageOrientation == UIImageOrientation.up {
//            return self
//    }
//        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
//        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
//        if let normalizedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() {
//            UIGraphicsEndImageContext()
//            return normalizedImage
//        } else {
//            return self
//        }
//    }
//}
//
