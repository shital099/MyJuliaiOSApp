 //
//  GalleryViewController.swift
//  DemoSwift
//
//  Created by GCO on 07/04/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit
import AssetsLibrary

private let reuseIdentifier = "CellIndentifier"

class GalleryViewController: TKExamplesExampleViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate {
    var cellColor = true
    
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var postGallery: UIBarButtonItem!
    let picker = UIImagePickerController()

    var isRefreshList : Bool = true
    var actionSheetContoller : UIAlertController!
    let listView = TKListView()
    var dataSource = TKDataSource()
    
    var listArray:[PhotoGallery] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Show menu icon in ipad and iphone
        self.setupMenuBarButtonItems()
         self.addOption("Scale in", action: scaleInSelected)
        
//        if IS_IPHONE {
//            self.setupMenuBarButtonItems()
//
//            self.addOption("Scale in", action: scaleInSelected)
//        }
        
        CommonModel.sharedInstance.applyThemeOnScreen(viewController: self, bgImage: bgImageView)
        
        //Fetch data from Sqlite database
        listArray = DBManager.sharedInstance.fetchGalleryDataFromDB() as! [PhotoGallery]

//        if listArray.count != 0 {
//            self.dataSource.itemSource = listArray
//            self.showPhotosIntoListView()
//        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if self.isRefreshList == true {
            let queue = OperationQueue()
            
            queue.addOperation { () -> Void in
                //Fetch data from server
                self.getGalleryInfoListData()
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        
        self.setListViewItemSize()
    }

    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        //let destinationVC = segue.destination as! AgendaDetailsViewController
        
        self.isRefreshList = true
    }
    
    // MARK: - ListView animation Methods
    
    func showPhotosIntoListView() {
        
        // Do any additional setup after loading the view.
        // self.dataSource.loadData(fromJSONResource: "ListViewSampleData", ofType: "json", rootItemKeyPath: "photos")
        
        self.dataSource.settings.listView.createCell { (listView: TKListView, indexPath: IndexPath, item: Any) -> TKListViewCell? in
            return listView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! TKListViewCell?
        }
        
        self.dataSource.settings.listView.initCell { (listView: TKListView, indexPath: IndexPath, cell: TKListViewCell, item: Any) -> Void in
            
            listView.backgroundColor = UIColor.clear
            cell.backgroundColor = UIColor.clear
            let model = self.listArray[indexPath.row]
            
            cell.imageView.tag = indexPath.item
            
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped(tapGestureRecognizer:)))
            cell.imageView.isUserInteractionEnabled = true
            cell.imageView.addGestureRecognizer(tapGestureRecognizer)
            
            if model.isImageDeleted == true {
                cell.imageView.image = UIImage(named: "no_image")
            }
            else {
                if !model.iconUrl.isEmpty {
                    cell.imageView.sd_setImage(with: NSURL(string:model.iconUrl) as URL?, placeholderImage: #imageLiteral(resourceName: "no_image"))
                    //cell.imageView.contentMode = .scaleAspectFit
                }
            }
        }

            self.listView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
            self.listView.backgroundColor = UIColor.clear
            self.listView.autoresizingMask = UIViewAutoresizing(rawValue: UIViewAutoresizing.flexibleWidth.rawValue | UIViewAutoresizing.flexibleHeight.rawValue)
            self.listView.dataSource = self.dataSource
            self.listView.register(AnimationListCell.self, forCellWithReuseIdentifier: "cell")
            self.view.addSubview(self.listView)

        if listArray.count != 0 {
            self.setListViewItemSize()
        }
    }
    
    func setListViewItemSize() {
        
        let layout = TKListViewGridLayout()
        var noOfGrid = 5
        if IS_IPAD {
            noOfGrid = Int((AppDelegate.getAppDelegateInstance().window?.frame.width)! / 120)
            if noOfGrid <= 4 {
                noOfGrid = 6
            }
            layout.itemSize.height = 80
        }
        else {
            noOfGrid = Int(self.view.frame.size.width/80)
            layout.itemSize.height = 80
        }
        
        //layout.spanCount = Int(self.listView.frame.size.width / layout.itemSize.width)
        layout.spanCount = Int(noOfGrid)
        layout.itemSpacing = 7
        layout.lineSpacing = 7
        layout.headerReferenceSize = CGSize(width: 10, height:10)
        //layout.dynamicItemSize = true
        
        // layout.itemSize = CGSize(width: 80, height:80)
        
        // >> listview-alignment-swift
        layout.itemAlignment = TKListViewItemAlignment.center
        // << listview-alignment-swift
        
        layout.itemAppearAnimation = TKListViewItemAnimation.scale
        
        // >> listview-animation-duration-swift
        layout.animationDuration = 0.4
        // << listview-animation-duration-swift
        
        self.listView.layout = layout
        self.listView.reloadData()
    }
    
    func fadeInSelected() {
        let layout = listView.layout as! TKListViewLinearLayout
        layout.itemAppearAnimation = TKListViewItemAnimation.fade
        layout.itemInsertAnimation = TKListViewItemAnimation.fade
        layout.itemDeleteAnimation = TKListViewItemAnimation.fade
    }
    
    func slideInSelected() {
        let layout = listView.layout as! TKListViewLinearLayout
        layout.itemAppearAnimation = TKListViewItemAnimation.slide
        layout.itemInsertAnimation = TKListViewItemAnimation.slide
        layout.itemInsertAnimation = TKListViewItemAnimation.slide
    }
    
    func scaleInSelected() {
        let layout = listView.layout as! TKListViewLinearLayout
        // >> listview-appear-swift
        layout.itemAppearAnimation = TKListViewItemAnimation.scale
        // << listview-appear-swift
        
        // >> listview-insert-swift
        layout.itemInsertAnimation = TKListViewItemAnimation.scale
        // << listview-insert-swift
        
        // >> listview-delete-swift
        layout.itemInsertAnimation = TKListViewItemAnimation.scale
        // << listview-delete-swift
        
    }
    
    // MARK: - Web service Methods

    func getGalleryInfoListData() {
        
        //NetworkingHelper.getRequestFromUrl(name:PhotoGallery_List_url,  urlString: PhotoGallery_List_url.appendingFormat(EventData.sharedInstance.eventId), callback: { response in
        let urlStr = Get_AllModuleDetails_url.appendingFormat("Flag=%@",PhotoGallery_List_url)
        NetworkingHelper.getRequestFromUrl(name:PhotoGallery_List_url,  urlString: urlStr, callback: { response in
            if response is Array<Any> {
                //Fetch data from Sqlite database
                let arr = DBManager.sharedInstance.fetchGalleryDataFromDB() as! [PhotoGallery]
                if arr.count != self.listArray.count {
                    self.listArray = arr
                   // if self.listArray.count != 0 {
                        self.dataSource.itemSource = self.listArray
                        self.showPhotosIntoListView()
//                    }
//                    else {
//                        self.dataSource = TKDataSource()
//                        self.showPhotosIntoListView()
//                    }
                }
               // DispatchQueue.main.sync  {
               // }
            }
        }, errorBack: { error in
            NSLog("error : %@", error)
            if self.listArray.count != 0 {
                self.dataSource.itemSource = self.listArray
                self.showPhotosIntoListView()
            }
        })
    }
    
    // MARK: - Action Methods
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        
        let nextViewController = storyboard?.instantiateViewController(withIdentifier: "GDetailViewController") as! GDetailViewController
        nextViewController.imgIndex = tappedImage.tag
        nextViewController.listArray = listArray
        //nextViewController.modalPresentationStyle = .custom
        self.navigationController?.pushViewController(nextViewController, animated: true)
        DispatchQueue.main.async {
        //    self.present(nextViewController, animated: true, completion: nil)
        }

    }
    //MARK: - Button Action Methods
    
    @IBAction func postGallery(_ sender: Any) {
        
        self.showActionSheet()
        
        //        let viewController = storyboard?.instantiateViewController(withIdentifier: "ContentCaptureViewController") as! ContentCaptureViewController
        //        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func showActionSheet() {
        
        actionSheetContoller = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
        
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
        actionSheetContoller.addAction(galleryAction)
        actionSheetContoller.addAction(photoAction)
        actionSheetContoller.addAction(cancelAction)
        
        // 5
        actionSheetContoller.popoverPresentationController?.sourceView = self.postGallery.customView
        actionSheetContoller.popoverPresentationController?.barButtonItem = self.postGallery
        
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
        if error == nil {
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated:true, completion: nil) //5
    }
}


class GCustomCell:UICollectionViewCell {
    
    @IBOutlet weak var backView: UIImageView!
    @IBOutlet weak var imageTapped: UIImageView!

    
}
