//
//  ActivityFeedDetailsViewController.swift
//  My-Julia
//
//  Created by GCO on 5/4/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit
import SafariServices

class ActivityFeedDetailsViewController: UIViewController, RTLabelDelegate, SFSafariViewControllerDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var tableViewObj: UITableView!


    var cellHeight : CGFloat = 400

    var feedModel : ActivityFeedsModel!
    var lastScale : CGFloat = 0.0
    let kMaxScale : CGFloat = 2.0
    let kMinScale : CGFloat = 0.7
    var currentScale : CGFloat = 1.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Details"
        
        //apply application theme on screen
        CommonModel.sharedInstance.applyThemeOnScreen(viewController: self, bgImage: bgImageView)

        //Update dyanamic height of tableview cell
//        tableViewObj.estimatedRowHeight = 1000
//        tableViewObj.rowHeight = UITableViewAutomaticDimension

        let textLabel = UILabel()
        textLabel.frame = CGRect(x: 10, y: 10, width: self.view.frame.size.width, height: 21.0)
        textLabel.text = self.feedModel.messageText
        textLabel.numberOfLines = 0
        textLabel.lineBreakMode = .byWordWrapping
        textLabel.sizeToFit()

        //Calculate height of text
        cellHeight = cellHeight + textLabel.size.height

//
//        self.textLabel.height = self.textLabel.optimumSize.height
//        self.textLabel.updateConstraintsIfNeeded()
//
//        if !feedModel.isImageDeleted {
//
//            if !feedModel.postImageUrl.isEmpty {
//
//                let url = NSURL(string:feedModel.postImageUrl)! as URL
//                self.postImageView.sd_setImage(with: url, placeholderImage: nil)
//                self.createPanGestureRecognizer(targetView: postImageView)
//            }
//        }
//        else {
//            self.postImageView.isHidden = true
//        }
    }

    
    // MARK: - Gesture Methods

    // The Pan Gesture
    func createPanGestureRecognizer(targetView: UIImageView) {
        
        targetView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action:#selector(self.handlePanGesture(panGesture:))))
    }
    
    @IBAction func handlePinch(_ recognizer : UIPinchGestureRecognizer) {
        
        //        if let view = recognizer.view {
        //            view.transform = view.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
        //            recognizer.scale = 1
        //
        //            print("end ",recognizer.scale)
        //
        //        }
        
        if currentScale * recognizer.scale > kMinScale && currentScale * recognizer.scale < kMaxScale{
            currentScale = currentScale * recognizer.scale
            let zoomTransform : CGAffineTransform = CGAffineTransform.init(scaleX: currentScale, y: currentScale)
            recognizer.view?.transform = zoomTransform
        }
        recognizer.scale = 1.0
    }
    
    @objc func handlePanGesture(panGesture: UIPanGestureRecognizer) {
        // get translation-
        let translation = panGesture.translation(in: view)
        panGesture.setTranslation(CGPoint.zero, in: view)
        print(translation)
        
        // create a new Label and give it the parameters of the old one
        let label = panGesture.view as! UIImageView
        label.center = CGPoint(x: label.center.x+translation.x, y: label.center.y+translation.y)
        label.isMultipleTouchEnabled = true
        label.isUserInteractionEnabled = true
        
        if panGesture.state == UIGestureRecognizerState.began {
            // add something you want to happen when the Label Panning has started
        }
        
        if panGesture.state == UIGestureRecognizerState.ended {
            // add something you want to happen when the Label Panning has ended
        }
        
        if panGesture.state == UIGestureRecognizerState.changed {
            // add something you want to happen when the Label Panning has been change ( during the moving/panning )
        } else {
            // or something when its not moving
        }    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            masterVC =  self.menuContainerViewController.leftMenuViewController as! MenuViewController?
        }
        else {
            masterVC = self.splitViewController?.viewControllers.first
        }
        
        if ((masterVC as? MenuViewController) != nil) {
            (masterVC as! MenuViewController).toggleLeftSplitMenuController()
        }
    }

    //MARK:- RTLabel Delegate Dismiss

    func rtLabel(_ rtLabel: Any!, didSelectLinkWith url: URL!) {
       // print("did select url %@", url)
        let svc = SFSafariViewController(url: url)
        svc.delegate = self
        self.present(svc, animated: true, completion: nil)
    }

    //MARK:- SafatriViewConroller Dismiss

    func safariViewControllerDidFinish(_ controller: SFSafariViewController)
    {
        controller.dismiss(animated: true, completion: nil)
    }


    // MARK: - TableView DataSource Methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight //UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cellId = "CellIdentifier"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ActivityCustomCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.backgroundColor = cell.contentView.backgroundColor

        cell.messageLbl.text = feedModel.messageText
        cell.messageLbl.delegate = self
        cell.messageLbl.lineBreakMode = RTTextLineBreakModeWordWrapping
        cell.messageLbl.sizeToFit()

        if feedModel.isImageDeleted {
            cell.postImageView.image = UIImage(named: "no_image")
        }
        else {
            if !feedModel.postImageUrl.isEmpty {
                //print("feed image url ",model.postImageUrl)
                let url = NSURL(string: feedModel.postImageUrl)! as URL
                cell.postImageView.sd_setImage(with: url, placeholderImage: nil)
                cell.postImageView.contentMode = .scaleAspectFit
            }
        }

        return cell
    }
}
