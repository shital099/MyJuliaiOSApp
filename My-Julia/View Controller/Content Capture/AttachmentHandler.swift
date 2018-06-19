//
//  AttachmentHandler.swift
//  AttachmentHandler
//
//  Created by Deepak on 25/01/18.
//  Copyright © 2018 Deepak. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices
import AVFoundation
import Photos


class AttachmentHandler: NSObject{
    static let shared = AttachmentHandler()
    fileprivate var currentVC: UIViewController?
    
    //MARK: - Internal Properties
    var imagePickedBlock: ((UIImage) -> Void)?
    var videoPickedBlock: ((NSURL) -> Void)?
    var filePickedBlock: ((URL) -> Void)?
    var textPickedBlock: ((String) -> Void)?

    
    enum AttachmentType: String{
        case camera, video, photoLibrary
    }

    
    //MARK: - Constants
    struct Constants {
        static let actionFileTypeHeading = "Choose Option"
        static let actionFileTypeDescription = ""
        static let text = "Post only text"
        static let camera = "Camera"
        static let phoneLibrary = "Phone Library"
        static let video = "Video"
        static let file = "File"
        static let AlertTitle = "Access denied"

        
        static let alertForPhotoLibraryMessage = "App does not have access to your photos. To enable access, tap settings and turn on Photo Library Access."
        
        static let alertForCameraAccessMessage = "App does not have access to your camera. To enable access, tap settings and turn on Camera."
        
        static let alertForVideoLibraryMessage = "App does not have access to your video. To enable access, tap settings and turn on Video Library Access."
        
        static let settingsBtnTitle = "Settings"
        static let cancelBtnTitle = "OK"
        
    }
    
    
    
    //MARK: - showAttachmentActionSheet
    // This function is used to show the attachment sheet for image, video, photo and file.
    func showAttachmentActionSheet(vc: UIViewController, isShowTextOption : Bool, button : UIBarButtonItem) {
        currentVC = vc
        let actionSheet = UIAlertController(title: Constants.actionFileTypeHeading, message: Constants.actionFileTypeDescription, preferredStyle: .actionSheet)

        if isShowTextOption {
            actionSheet.addAction(UIAlertAction(title: Constants.text, style: .default, handler: { (action) -> Void in
                self.textPickedBlock?("")
            }))
        }

        actionSheet.addAction(UIAlertAction(title: Constants.camera, style: .default, handler: { (action) -> Void in
            self.authorisationStatus(attachmentTypeEnum: .camera, vc: self.currentVC!)
        }))
        
        actionSheet.addAction(UIAlertAction(title: Constants.phoneLibrary, style: .default, handler: { (action) -> Void in
            self.authorisationStatus(attachmentTypeEnum: .photoLibrary, vc: self.currentVC!)
        }))
        
//        actionSheet.addAction(UIAlertAction(title: Constants.video, style: .default, handler: { (action) -> Void in
//            self.authorisationStatus(attachmentTypeEnum: .video, vc: self.currentVC!)
//
//        }))
//
//        actionSheet.addAction(UIAlertAction(title: Constants.file, style: .default, handler: { (action) -> Void in
//            self.documentPicker()
//        }))

        actionSheet.addAction(UIAlertAction(title: Constants.cancelBtnTitle, style: .cancel, handler: nil))
        
       // vc.present(actionSheet, animated: true, completion: nil)
        actionSheet.popoverPresentationController?.sourceView = button.customView
        actionSheet.popoverPresentationController?.barButtonItem = button

        // this is the center of the screen currently but it can be any point in the view
        vc.present(actionSheet, animated: true, completion: nil)
    }
    
    //MARK: - Authorisation Status
    // This is used to check the authorisation status whether user gives access to import the image, photo library, video.
    // if the user gives access, then we can import the data safely
    // if not show them alert to access from settings.
    func authorisationStatus(attachmentTypeEnum: AttachmentType, vc: UIViewController){
        currentVC = vc

        if attachmentTypeEnum == .camera {
            let authorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            
            switch authorizationStatus {
            case .notDetermined:
                // permission dialog not yet presented, request authorization
                AVCaptureDevice.requestAccess(for: AVMediaType.video,
                                              completionHandler: { (granted:Bool) -> Void in
                                                if granted {
                                                    print("access granted", terminator: "")
                                                    self.openCamera()
                                                }
                                                else {
                                                    print("access denied", terminator: "")
                                                    self.addAlertForSettings(AttachmentType.camera)
                                                }
                })
            case .authorized:
                print("Access authorized", terminator: "")
                openCamera()
            case .denied, .restricted:
                self.addAlertForSettings(AttachmentType.camera)
            default:
                print("DO NOTHING", terminator: "")
            }
        }
        else {
            let status = PHPhotoLibrary.authorizationStatus()

            switch status {
            case .authorized:
                if attachmentTypeEnum == AttachmentType.camera{
                    openCamera()
                }
                if attachmentTypeEnum == AttachmentType.photoLibrary{
                    photoLibrary()
                }
                if attachmentTypeEnum == AttachmentType.video{
                    videoLibrary()
                }
            case .denied:
                print("permission denied")
                self.addAlertForSettings(attachmentTypeEnum)
            case .notDetermined:
                print("Permission Not Determined")
                PHPhotoLibrary.requestAuthorization({ (status) in
                    if status == PHAuthorizationStatus.authorized{
                        // photo library access given
                        print("access given")
                        if attachmentTypeEnum == AttachmentType.camera{
                            self.openCamera()
                        }
                        if attachmentTypeEnum == AttachmentType.photoLibrary{
                            self.photoLibrary()
                        }
                        if attachmentTypeEnum == AttachmentType.video{
                            self.videoLibrary()
                        }
                    }else{
                        print("restriced manually")
                        self.addAlertForSettings(attachmentTypeEnum)
                    }
                })
            case .restricted:
                print("permission restricted")
                self.addAlertForSettings(attachmentTypeEnum)
            default:
                break
            }
        }
    }
    
    func authorisationStatusCheck(attachmentTypeEnum: AttachmentType, vc: UIViewController)-> Bool {

        currentVC = vc
        var statusValue : Bool = false

        if attachmentTypeEnum == .camera {

            let authorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            switch authorizationStatus {
            case .notDetermined:
                // permission dialog not yet presented, request authorization
                AVCaptureDevice.requestAccess(for: AVMediaType.video,
                                              completionHandler: { (granted:Bool) -> Void in
                                                if granted {
                                                    print("access granted", terminator: "")
                                                    statusValue = true
                                                }
                                                else {
                                                    print("access denied", terminator: "")
                                                    self.addAlertForSettings(AttachmentType.camera)
                                                }
                })
            case .authorized:
                print("Access authorized", terminator: "")
                statusValue = true
                break
            case .denied, .restricted:
                self.addAlertForSettings(AttachmentType.camera)
                break
            }
        }
        else {
            let status = PHPhotoLibrary.authorizationStatus()
            switch status {
            case .authorized:
                statusValue = true
                break
            case .denied: do {
                print("permission denied")
                self.addAlertForSettings(attachmentTypeEnum)
            }
                break
            case .notDetermined:
                print("Permission Not Determined")
                PHPhotoLibrary.requestAuthorization({ (status) in
                    if status == PHAuthorizationStatus.authorized{
                        // photo library access given
                        statusValue = true
                    }else{
                        print("restriced manually")
                        self.addAlertForSettings(attachmentTypeEnum)
                    }
                })
            case .restricted:
                print("permission restricted")
                self.addAlertForSettings(attachmentTypeEnum)
                break
            }
        }
        return statusValue
    }

    //MARK: - CAMERA PICKER
    //This function is used to open camera from the iphone and
    func openCamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self
            myPickerController.sourceType = .camera
            myPickerController.allowsEditing = false
            currentVC?.present(myPickerController, animated: true, completion: nil)
        }
    }
    

    //MARK: - PHOTO PICKER
    func photoLibrary(){
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self
            myPickerController.sourceType = .photoLibrary
            myPickerController.mediaTypes = [kUTTypeImage as String]
            myPickerController.modalPresentationStyle = .fullScreen
            currentVC?.present(myPickerController, animated: true, completion: nil)
        }
    }
    
    //MARK: - VIDEO PICKER
    func videoLibrary(){
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self
            myPickerController.sourceType = .photoLibrary
            myPickerController.mediaTypes = [kUTTypeMovie as String, kUTTypeVideo as String]
            currentVC?.present(myPickerController, animated: true, completion: nil)
        }
    }
    
    //MARK: - FILE PICKER
    func documentPicker(){
        let importMenu = UIDocumentMenuViewController(documentTypes: [String(kUTTypePDF)], in: .import)
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet
        currentVC?.present(importMenu, animated: true, completion: nil)
    }
    
    //MARK: - SETTINGS ALERT
    func addAlertForSettings(_ attachmentTypeEnum: AttachmentType){
        var alertmessage: String = ""
        if attachmentTypeEnum == AttachmentType.camera{
            alertmessage = Constants.alertForCameraAccessMessage
        }
        if attachmentTypeEnum == AttachmentType.photoLibrary{
            alertmessage = Constants.alertForPhotoLibraryMessage
        }
        if attachmentTypeEnum == AttachmentType.video{
            alertmessage = Constants.alertForVideoLibraryMessage
        }

        let cameraUnavailableAlertController = UIAlertController (title: Constants.AlertTitle , message: alertmessage, preferredStyle: .alert)
        
//        let settingsAction = UIAlertAction(title: Constants.settingsBtnTitle, style: .destructive) { (_) -> Void in
//            let settingsUrl = NSURL(string:UIApplicationOpenSettingsURLString)
//            if let url = settingsUrl {
//                if #available(iOS 10.0, *) {
//                    UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
//                } else {
//                    // Fallback on earlier versions
//                }
//            }
//        }
        let cancelAction = UIAlertAction(title: Constants.cancelBtnTitle, style: .default, handler: nil)
        cameraUnavailableAlertController .addAction(cancelAction)
       // cameraUnavailableAlertController .addAction(settingsAction)
        currentVC?.present(cameraUnavailableAlertController , animated: true, completion: nil)
    }
}

//MARK: - IMAGE PICKER DELEGATE
// This is responsible for image picker interface to access image, video and then responsibel for canceling the picker
extension AttachmentHandler: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        currentVC?.dismiss(animated: true, completion: nil)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {

            if let referenceUrl = info[UIImagePickerControllerReferenceURL] as? NSURL {
            }
            else {
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
            }

            self.imagePickedBlock?(image)
        }
        else{
            print("Something went wrong in  image")
        }
        
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? NSURL{
            print("videourl: ", videoUrl)
            //trying compression of video
            let data = NSData(contentsOf: videoUrl as URL)!
            print("File size before compression: \(Double(data.length / 1048576)) mb")
            compressWithSessionStatusFunc(videoUrl)
        }
        else{
            print("Something went wrong in  video")
        }
        currentVC?.dismiss(animated: true, completion: nil)
    }

    //MARK: - Add image to Library
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
    }

    //MARK: - Video Compressing technique
    fileprivate func compressWithSessionStatusFunc(_ videoUrl: NSURL) {
        let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + ".MOV")
        compressVideo(inputURL: videoUrl as URL, outputURL: compressedURL) { (exportSession) in
            guard let session = exportSession else {
                return
            }
            
            switch session.status {
            case .unknown:
                break
            case .waiting:
                break
            case .exporting:
                break
            case .completed:
                guard let compressedData = NSData(contentsOf: compressedURL) else {
                    return
                }
                print("File size after compression: \(Double(compressedData.length / 1048576)) mb")
                
                DispatchQueue.main.async {
                    self.videoPickedBlock?(compressedURL as NSURL)
                }
                
            case .failed:
                break
            case .cancelled:
                break
            }
        }
    }
    
    // Now compression is happening with medium quality, we can change when ever it is needed
    func compressVideo(inputURL: URL, outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?)-> Void) {
        let urlAsset = AVURLAsset(url: inputURL, options: nil)
        guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPreset1280x720) else {
            handler(nil)
            
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.mov
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronously { () -> Void in
            handler(exportSession)
        }
    }
}

//MARK: - FILE IMPORT DELEGATE
extension AttachmentHandler: UIDocumentMenuDelegate, UIDocumentPickerDelegate{
    func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        currentVC?.present(documentPicker, animated: true, completion: nil)
    }
    
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        print("url", url)
        self.filePickedBlock?(url)
    }
    
    //    Method to handle cancel action.
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        currentVC?.dismiss(animated: true, completion: nil)
    }
    
}
