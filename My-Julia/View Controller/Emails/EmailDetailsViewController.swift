//
//  EmailDetailsViewController.swift
//  My-Julia
//
//  Created by GCO on 13/07/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

class EmailDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate , UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var tableViewObj: UITableView!
    @IBOutlet weak var bgImageView: UIImageView!
    
    
    var model : EmailModel!
    var emailAttachmentButtonTapped: ((AttachmentDetailCell, AnyObject) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Details"
        
        //        apply application theme on screen
        CommonModel.sharedInstance.applyThemeOnScreen(viewController: self, bgImage: bgImageView)
        
        //Remove extra lines from tableview
        tableViewObj.tableFooterView = UIView()
        
        //Update dyanamic height of tableview cell
        tableViewObj.estimatedRowHeight = 1500
        tableViewObj.rowHeight = UITableViewAutomaticDimension
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //    func getEmailAttachment() {
    //
    //        NetworkingHelper.getRequestFromUrl(name:Email_List_url, urlString: Email_List_url.appendingFormat(EventData.sharedInstance.attendeeId), callback: { response in
    //
    //    if response is NSDictionary {
    //    if (response.value(forKey: "Path") != nil) {
    //    CommonModel.sharedInstance.showAlertWithStatus(message: Attachment_Sucess_Message, vc: self)
    //        print("msg", Attachment_Sucess_Message)
    //    }
    //    else {
    //    CommonModel.sharedInstance.showAlertWithStatus(message: Attachment_Sucess_Message, vc: self)
    //    }
    //    }
    //    }, errorBack: { error in
    //    CommonModel.sharedInstance.showAlertWithStatus(message: Internet_Error_Message, vc: self)
    //        print("msg", Internet_Error_Message)
    //
    //    })
    //}
    
    
    
    // MARK: - UITableView Delegate Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        
        //Get Identifier
        if indexPath.section == 0 {
            return UITableViewAutomaticDimension
        }
        else {
            if model.attachments.count == 0 {
                return 0
            }
            else {
                return 155
            }
//            let count : CGFloat = self.collectionObj.frame.size.width / 105
//            let width = CGFloat(model.attachments.count) / count
//            return width * 105
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0
        {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath) as! EmailDetailCell
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.backgroundColor = cell.contentView.backgroundColor;
            
            cell.titleLabel?.text = model.subject
            cell.dateLabel?.text = CommonModel.sharedInstance.getDateAndTime(dateStr: model.date)
            // cell.descriptionLabel?.text = model.content
            
            cell.contentImgView.layer.borderColor = UIColor().HexToColor(hexString: "#DDDDDD", alpha: 1.0).cgColor
            cell.contentImgView.layer.borderWidth = 1.0
            cell.contentImgView.backgroundColor = .clear
            cell.contentImgView.layer.cornerRadius = 3.0
            
            cell.contentImgView.layer.shadowRadius = 2.0
            cell.contentImgView.layer.shadowColor = UIColor().HexToColor(hexString: "#DDDDDD", alpha: 1.0).cgColor
            cell.contentImgView.layer.shadowOffset = CGSize.zero
            cell.contentImgView.layer.shadowOpacity = 0.5
            //cell.descriptionLabel.text = model.content
            
            if let htmlData = model.content.data(using: String.Encoding.unicode) {
                do {
                    let attributedText = try NSAttributedString(data: htmlData, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
                    cell.descriptionLabel.attributedText = attributedText
                } catch let _ as NSError {
                   // print("Couldn't translate \(model.content): \(e.localizedDescription) ")
                }
            }
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AttachmentCell", for: indexPath)
            let collection = cell.viewWithTag(1000) as! UICollectionView
            collection.reloadData()
            
            //collectionObj.reloadData()
            
            //            cell.imgButton1.isHidden = true
            //            cell.buttonLabel1.isHidden = true
            //            cell.imgButton2.isHidden = true
            //            cell.buttonLabel2.isHidden = true
            //            cell.imgButton3.isHidden = true
            //            cell.buttonLabel3.isHidden = true
            //
            //            if model.attachments.count > 0  {
            //                let dict = model.attachments.object(at: 0) as! NSDictionary
            //                cell.buttonLabel1?.text = dict["AttachmentName"] as? String
            //
            //                cell.imgButton1.isHidden = false
            //                cell.buttonLabel1.isHidden = false
            //            }
            //
            //            if model.attachments.count > 1 {
            //                let dict = model.attachments.object(at: 1) as! NSDictionary
            //                cell.buttonLabel2?.text = dict["AttachmentName"] as? String
            //
            //                cell.imgButton2.isHidden = false
            //                cell.buttonLabel2.isHidden = false
            //            }
            //
            //            if model.attachments.count > 2 {
            //                let dict = model.attachments.object(at: 2) as! NSDictionary
            //                cell.buttonLabel3?.text = dict["AttachmentName"] as? String
            //
            //                cell.imgButton3.isHidden = false
            //                cell.buttonLabel3.isHidden = false
            //            }
            //
            //            cell.imgButton1?.tag = 0
            //            cell.imgButton2?.tag = 1
            //            cell.imgButton3?.tag = 2
            
            //            cell.attachContentImgView.layer.borderColor = UIColor().HexToColor(hexString: "#DDDDDD", alpha: 1.0).cgColor
            //            cell.attachContentImgView.layer.borderWidth = 1.0
            //            cell.attachContentImgView.backgroundColor = .clear
            //            cell.attachContentImgView.layer.cornerRadius = 3.0
            //            cell.attachContentImgView.layer.shadowRadius = 2.0
            //            cell.attachContentImgView.layer.shadowColor = UIColor().HexToColor(hexString: "#DDDDDD", alpha: 1.0).cgColor
            //            cell.attachContentImgView.layer.shadowOffset = CGSize.zero
            //            cell.attachContentImgView.layer.shadowOpacity = 0.5
            //            self.getEmailAttachment()
            
            
            return cell
        }
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return model.attachments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.size.width / 3 , height:130.0)
        
//        var cellSize:CGSize
//
//        if IS_IPHONE         {
//            cellSize = CGSize(width: 100 , height:130.0)
//        }
//        else {
//            cellSize = CGSize(width: 130 , height:130.0)
//        }
//
//        return cellSize;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AttachmentDetailCell", for: indexPath) as! AttachmentDetailCell
        
        if model.attachments.count > 0  {
            let dict = model.attachments.object(at: 0) as! NSDictionary
            cell.buttonLabel?.text = dict["AttachmentName"] as? String
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "AttachmentDetailsViewController") as! AttachmentDetailsViewController
        
        let dict = self.model.attachments.object(at: indexPath.row) as! NSDictionary
        viewController.attechmentName = dict["AttachmentName"] as! String
        viewController.attechmentUrl = dict["AttachmentUrl"] as! String
        self.navigationController?.pushViewController(viewController, animated: true)
        
        return
    }
    
}

// MARK: - Custom Cell Classes

class EmailDetailCell: UITableViewCell {
    
    @IBOutlet var titleLabel:UILabel!
    @IBOutlet var dateLabel:UILabel!
    @IBOutlet var descriptionLabel:UILabel!
    @IBOutlet var contentImgView:UIImageView!
    
}

class AttachmentDetailCell: UICollectionViewCell {

    @IBOutlet var attachContentImgView:UIImageView!

    @IBOutlet var buttonLabel:UILabel!
    @IBOutlet var imgButton:UIButton!
    
}

