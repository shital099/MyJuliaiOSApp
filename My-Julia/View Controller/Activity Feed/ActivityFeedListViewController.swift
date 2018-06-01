//
//  ActivityFeedListViewController.swift
//  My-Julia
//
//  Created by GCO on 5/4/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit
import AssetsLibrary
import MobileCoreServices
import SafariServices

extension UIImagePickerController
{
    override open var shouldAutorotate: Bool {
        return true
    }
    override open var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .all
    }
}

protocol ActivityCommentDelegate: class {
    
    func updateCommentCountDelegate( activityIndex : Int, count : String)
}

class ActivityFeedListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, ActivityCommentDelegate, SFSafariViewControllerDelegate, RTLabelDelegate {
    
    @IBOutlet weak var tableviewObj: UITableView!
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var postAct: UIBarButtonItem!
   
    var isRefreshList : Bool = true
//    var pageNo : NSInteger = 0
//    var isLastPage : Bool = false

   // let picker = UIImagePickerController()
   // var actionSheetContoller : UIAlertController!
    var attachmentHandler : AttachmentHandler!

   // var dataArray : [ActivityFeedsModel] = []
   // var dataArray:NSMutableArray = []
    fileprivate let feedsModelController = ActivityFeedViewModelController()

    var likeButtonTapped: ((ActivityCustomCell, AnyObject) -> Void)?
    var viewLikeButtonTapped: ((ActivityCustomCell, AnyObject) -> Void)?
    var commentButtonTapped: ((ActivityCustomCell, AnyObject) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
       // picker.delegate = self

        //apply application theme on screen
        CommonModel.sharedInstance.applyThemeOnScreen(viewController: self, bgImage: bgImageView)
        
        self.navigationItem.leftBarButtonItem?.tintColor = AppTheme.sharedInstance.headerTextColor

        //Show menu icon in ipad and iphone
        self.setupMenuBarButtonItems()
        
        //        if IS_IPHONE {
        //            self.setupMenuBarButtonItems()
        //        }

        
        let refreshControl: UIRefreshControl = {
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action:
                #selector(ActivityFeedListViewController.handleRefresh(_:)),
                                     for: UIControlEvents.valueChanged)
            refreshControl.tintColor = AppTheme.sharedInstance.backgroundColor.darker(by: 40)!
            
            return refreshControl
        }()
    
        self.tableviewObj.addSubview(refreshControl)
    
//        //Fetch data from Sqlite database
//        self.dataArray = DBManager.sharedInstance.fetchActivityFeedsDataFromDB(limit: Activity_Page_Limit, offset: pageNo).mutableCopy() as! NSMutableArray


        //Fetch data from server
        //self.getActivityFeedInfoListData()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {

        //Update side menu notification count
        self.feedsModelController.initializeModuleIndex(index : self.view.tag)

        if self.isRefreshList == true {
            //load data from db
            self.feedsModelController.loadItem()
            self.tableviewObj.reloadData()

            let queue = OperationQueue()
            queue.addOperation { () -> Void in

                self.feedsModelController.retrieveFirstPage()

                //Fetch data from server
                self.getActivityFeedInfoListData()
            }
            
            self.isRefreshList = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let vc = self.navigationController?.visibleViewController
        if ((vc as? PostPhotoViewController) != nil) {
            self.isRefreshList = true
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "ActivityDetailSegue" {
           let destinationVC = segue.destination as! ActivityFeedDetailsViewController
            destinationVC.feedModel = self.feedsModelController.viewModel(at: (self.tableviewObj.indexPathForSelectedRow?.row)!)
            self.isRefreshList = false
        }
    }

    // MARK: - Navigation UIBarButtonItems
    func setupMenuBarButtonItems() {
        
        // self.navigationItem.rightBarButtonItem = self.rightMenuBarButtonItem()
        let barItem = CommonModel.sharedInstance.leftMenuBarButtonItem()
        barItem.target = self;
        barItem.action = #selector(self.leftSideMenuButtonPressed(sender:))
        self.navigationItem.leftBarButtonItem = barItem
    }
    
    // MARK: - Navigation UIBarButtonItems
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

    // MARK: - UIRefreshControl Methods
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        
        let queue = OperationQueue()
        
        queue.addOperation { () -> Void in
            self.feedsModelController.retrieveFirstPage()
            //Fetch data from server
            self.getActivityFeedInfoListData()
        }
        
        self.tableviewObj.reloadData()
        refreshControl.endRefreshing()
    }

    // MARK: - Data Methods

//    func loadItem()  {
//       // print("before fetch Data array count : ", self.dataArray.count)
//
//        //Calculate page offset offset
//       // print("Page no : ",self.pageNo)
//        let offset = self.pageNo * Activity_Page_Limit
//       // print("Offset : ",offset)
//
//        let array = DBManager.sharedInstance.fetchActivityFeedsDataFromDB(limit: Activity_Page_Limit, offset: offset).mutableCopy() as! NSMutableArray
//        if array.count < Activity_Page_Limit {
//            self.isLastPage = true
//        }
//        self.dataArray.addObjects(from: array as! [Any])
//        self.tableviewObj.reloadData()
//       // print("After load Data array count : ", self.dataArray.count)
//    }

    // MARK: - Webservice Methods
    
    func getActivityFeedInfoListData() {

        feedsModelController.retrieveActivityFeeds { [weak self] (success, error) in
            guard let strongSelf = self else { return }
            if !success {
                DispatchQueue.main.async {
                }
            } else {
                DispatchQueue.main.async {
                    strongSelf.tableviewObj.reloadData()
                }
            }
        }
   }

    func postLikeToActivityFeed(selectedCell: ActivityCustomCell) {
        
        //Show Indicator
        CommonModel.sharedInstance.showActitvityIndicator()
        let likeStatus = selectedCell.likesButton.isSelected
        self.feedsModelController.postActivityFeedsLikeStatus(index: selectedCell.likesButton.tag, status: likeStatus, view: self, completionBlock: { [weak self] (success, error) in
            guard let strongSelf = self else { return }
            if success {
                DispatchQueue.main.async {
                    //Sucess
                    DispatchQueue.main.async {
                        //Update new comment into and in list
                        strongSelf.tableviewObj.reloadRows(at: [IndexPath(row: selectedCell.likesButton.tag, section: 0)], with: .automatic)
                    }
                }
            } else {
                print("Error in post like")
                selectedCell.likesButton.isSelected = !likeStatus
            }
        })
    }

    // MARK: - TableView DataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedsModelController.viewFeedsModelsCount
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = feedsModelController.viewModel(at: indexPath.row)
        if (model?.postImageUrl.isEmpty)! {
            return 170
        }
        else if model?.messageText == "" {
            return 415
        }
        else {
            return 490
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model : ActivityFeedsModel = feedsModelController.viewModel(at: indexPath.row)!
        
        var cellId = ""
        if model.postImageUrl.isEmpty {
            cellId = "CellIdentifier"
        }
        else if model.messageText == "" {
            cellId = "ImageCellIdentifier"
        }
        else {
            cellId = "ImageWithTextCellId"
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ActivityCustomCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.backgroundColor = cell.contentView.backgroundColor

        self.configureCell(cell : cell, model : model, indexPath : indexPath)
        let sucess =  self.feedsModelController.checkLoadMoreViewModel(at: indexPath.row)

        //Last row scroll
        if sucess {
            self.getActivityFeedInfoListData()
        }

//        if indexPath.row == self.dataArray.count - 1 { // last cell
//
//            if isLastPage == false { // more items to fetch
//                // more items to fetch
//                self.pageNo += 1
//                getActivityFeedInfoListData() // increment `fromIndex` by 20 before server call
//            }
//        }
        return cell
    }

    func configureCell(cell:ActivityCustomCell, model : ActivityFeedsModel, indexPath : IndexPath) {

        cell.userNameLabel.text = model.userNameString
        cell.likesLbl.text = model.likesCount
        cell.commentsLbl.text = model.commentsCount
        cell.postDateLbl.text = CommonModel.sharedInstance.getDateAndTime(dateStr: model.postDateStr)
        cell.likesButton.tag = indexPath.row
        cell.commentButton.tag = indexPath.row
        cell.messageLbl.text = model.messageText
        cell.messageLbl.delegate = self
        //cell.textLbl.attributedText =  CommonModel.sharedInstance.stringFromHtml(string: model.messageText)
        //cell.textLbl.text = model.messageText

        print("read status : ",model.isRead)

        if cell.messageLbl.optimumSize.height > 55 {
            cell.readMoreLbl.isHidden = false
        }
        else {
            cell.readMoreLbl.isHidden = true
        }

        if !model.userIconUrl.isEmpty {
            let url = NSURL(string:model.userIconUrl)! as URL
            cell.userIconImage.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "user"))
        }
        else {
            cell.userIconImage.image = #imageLiteral(resourceName: "user")
        }

        cell.userIconImage.contentMode = .scaleAspectFill
        cell.userIconImage.layer.cornerRadius = cell.userIconImage.frame.size.width / 2
        cell.userIconImage.clipsToBounds = true

        cell.bgView.layer.cornerRadius = 3.0
        cell.bgView.layer.borderColor = UIColor().HexToColor(hexString: "#D7D7D7", alpha: 1.0).cgColor
        cell.bgView.layer.borderWidth = 1.0

//        //Check post text message length
//        let textSize = CGSize(width: CGFloat(cell.textLbl.frame.size.width), height: CGFloat(MAXFLOAT))
//        let rHeight: Int = lroundf(Float(cell.textLbl.sizeThatFits(textSize).height))
//        let charSize: Int = lroundf(Float(cell.textLbl.font.pointSize))
//        let lineCount = rHeight / charSize
//       // print("No of lines: ",lineCount)
//        if lineCount > 2 {
//            cell.readMoreLbl.isHidden = false
//        }
//        else {
//            cell.readMoreLbl.isHidden = true
//        }

        if model.isImageDeleted {
            cell.postImageView.image = UIImage(named: "no_image")
        }
        else {
            if !model.postImageUrl.isEmpty {
                //print("feed image url ",model.postImageUrl)
                let url = NSURL(string: model.postImageUrl)! as URL
                cell.postImageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "no_image"))
                cell.postImageView.contentMode = .scaleAspectFit
            }
        }

        //Show like button status
        cell.likesButton.isSelected = model.isUserLike

        cell.likeButtonTapped = { (selectedCell, sender) -> Void in
            let button = sender as! UIButton
            button.isSelected = !button.isSelected
            self.postLikeToActivityFeed(selectedCell: cell)
        }

        cell.viewLikeButtonTapped = { (selectedCell, sender) -> Void in
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ActivityPostLikesViewController") as! ActivityPostLikesViewController
            viewController.activityPostId = model.id
            self.navigationController?.pushViewController(viewController, animated: true)
        }

        cell.commentButtonTapped = { [unowned self] (selectedCell, sender) -> Void in

            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "CommentsListViewController") as! CommentsListViewController
            viewController.feedModel = model
            viewController.index = indexPath.row
            viewController.delegate = self
            self.isRefreshList = false
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    // MARK: - UITableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        self.isRefreshList = false

        let model : ActivityFeedsModel = self.feedsModelController.viewModel(at: indexPath.row)!

        if model.isImageDeleted && model.messageText != "" {
        }
        else {
            let viewController = storyboard?.instantiateViewController(withIdentifier: "ActivityFeedDetailsViewController") as! ActivityFeedDetailsViewController
            viewController.feedModel = self.feedsModelController.viewModel(at: (self.tableviewObj.indexPathForSelectedRow?.row)!)
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    
    // MARK: - ActivityCommentDelegate Methods
    
    func updateCommentCountDelegate( activityIndex : Int, count : String) {

        //Update new comment into and in list
        _ = self.feedsModelController.updateCommentIntoDB(at: activityIndex, count: count)
        self.tableviewObj.reloadRows(at: [IndexPath.init(row: activityIndex, section: 0)], with: .none)
        //tableviewObj.reloadData()
    }


    //MARK:- RTLabel Delegate Dismiss

    func rtLabel(_ rtLabel: Any!, didSelectLinkWith url: URL!) {
     //   print("did select url %@", url)
        let urlStr = url.absoluteString
        var nUrl : URL = url
        if urlStr.lowercased().hasPrefix("http://") || urlStr.lowercased().hasPrefix("https://") {
        }
        else {
            if URL (string: String(format:"http://%@", urlStr)) != nil {
                nUrl = URL (string: String(format:"http://%@", urlStr))!
            }
        }

        if url != nil {
            let svc = SFSafariViewController(url: nUrl)
            svc.delegate = self
            self.present(svc, animated: true, completion: nil)
        }
    }

    //MARK:- SafatriViewConroller Dismiss

    func safariViewControllerDidFinish(_ controller: SFSafariViewController)
    {
        controller.dismiss(animated: true, completion: nil)
    }

    //MARK: - Button Action Methods

    @IBAction func postActBtn(_ sender: Any) {
        
       // self.showActionSheet()
        AttachmentHandler.shared.showAttachmentActionSheet(vc: self, isShowTextOption: true, button: self.postAct)
        AttachmentHandler.shared.imagePickedBlock = { (image) in
            self.isRefreshList = true

            /* get your image here */
            print("Get image : ",image)
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "PostPhotoViewController") as! PostPhotoViewController
            viewController.capturedPhoto = image
            let imageNo = Int(arc4random_uniform(1000)) + 1
            viewController.imageName = String(format:"CapturedPhoto-%d",imageNo) //"CapturedPhoto".appendingFormat("%d", imageNo)
            self.navigationController?.pushViewController(viewController, animated: true)
        }

        AttachmentHandler.shared.textPickedBlock = { (text) in

            /* text option selected */
            print("Text option click : ")
            self.isRefreshList = true
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "PostTextViewController") as! PostTextViewController
            self.navigationController?.pushViewController(viewController, animated: true)
        }
//        let viewController = storyboard?.instantiateViewController(withIdentifier: "ContentCaptureViewController") as! ContentCaptureViewController
//        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
   /* func showActionSheet() {
        
        actionSheetContoller = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
        
        // 1
        let textAction = UIAlertAction(title: "Post only text", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            self.isRefreshList = true
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "PostTextViewController") as! PostTextViewController
            self.navigationController?.pushViewController(viewController, animated: true)
        })

        // 2
        let galleryAction = UIAlertAction(title: "Photo from library", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                self.picker.delegate = self
                self.picker.allowsEditing = true
                self.picker.sourceType = .photoLibrary
                self.picker.modalPresentationStyle = .fullScreen
                self.picker.mediaTypes = [kUTTypeImage as String] //UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
                self.present(self.picker, animated: true, completion: nil)
            }
        })
        let photoAction = UIAlertAction(title: "Take photo", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in

            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    self.picker.delegate = self
                    self.picker.sourceType = .camera;
                    self.picker.allowsEditing = false
//                self.picker.cameraCaptureMode = .photo
//                self.picker.cameraDevice = .rear
                self.present(self.picker, animated: true, completion: nil)
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        // 4
        actionSheetContoller.addAction(textAction)
        actionSheetContoller.addAction(galleryAction)
        actionSheetContoller.addAction(photoAction)
        actionSheetContoller.addAction(cancelAction)
    
        // 5
        actionSheetContoller.popoverPresentationController?.sourceView = self.postAct.customView
        actionSheetContoller.popoverPresentationController?.barButtonItem = self.postAct
        
        // this is the center of the screen currently but it can be any point in the view
        self.present(actionSheetContoller, animated: true, completion: nil)
    }
    
    //MARK: - UIImagePickerController Delegates Methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated:true, completion: nil) //5

        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        var fileName = ""
        
        if let mediaType = info[UIImagePickerControllerMediaType] as? String {
            
            if mediaType  == "public.image" {
            }
            
            if mediaType == "public.movie" {
                print("Video Selected")
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
                viewController.capturedPhoto = chosenImage
                viewController.imageName = fileName
                self.navigationController?.pushViewController(viewController, animated: true)
                
            }, failureBlock: nil)
        }
        else {
            UIImageWriteToSavedPhotosAlbum(chosenImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)

            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "PostPhotoViewController") as! PostPhotoViewController
            viewController.capturedPhoto = chosenImage
            let imageNo = Int(arc4random_uniform(1000)) + 1
            viewController.imageName = String(format:"CapturedPhoto-%d",imageNo) //"CapturedPhoto".appendingFormat("%d", imageNo)
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    //MARK: - Add image to Library
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
    }
    
       
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated:true, completion: nil) //5
    }*/
}

// MARK: - Custom TableView Cell Class

class ActivityCustomCell: UITableViewCell {
    
    var likeButtonTapped: ((ActivityCustomCell, AnyObject) -> Void)?
    var viewLikeButtonTapped: ((ActivityCustomCell, AnyObject) -> Void)?

    var commentButtonTapped: ((ActivityCustomCell, AnyObject) -> Void)?

    @IBOutlet var userNameLabel:UILabel!
    @IBOutlet var postDateLbl:UILabel!
    @IBOutlet var userIconImage:UIImageView!
    @IBOutlet var bgView:UIView!
    @IBOutlet var messageLbl:RTLabel!
    @IBOutlet var descLbl:UILabel!

    @IBOutlet var likesLbl:UILabel!
    @IBOutlet var commentsLbl:UILabel!
    @IBOutlet var postImageView:UIImageView!
    @IBOutlet var likesButton:UIButton!
    @IBOutlet var commentButton:UIButton!
    @IBOutlet var readMoreLbl:UILabel!

    
    @IBAction func likeButtonTapped(sender: AnyObject) {
        likeButtonTapped?(self, sender)
    }
    
    @IBAction func commentButtonTapped(sender: AnyObject) {
        commentButtonTapped?(self, sender)
    }

    @IBAction func viewLikeButtonTapped(sender: AnyObject) {
        viewLikeButtonTapped?(self, sender)
    }
}

