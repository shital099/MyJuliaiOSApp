//
//  ActivityFeedDetailsViewController.swift
//  My-Julia
//
//  Created by GCO on 5/4/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

class ActivityFeedDetailsViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!

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
        
        self.textLabel.text = feedModel.messageText
        
        if !feedModel.isImageDeleted {
            
            if !feedModel.postImageUrl.isEmpty {
                
                let url = NSURL(string:feedModel.postImageUrl)! as URL
                self.postImageView.sd_setImage(with: url, placeholderImage: nil)
                self.createPanGestureRecognizer(targetView: postImageView)
            }
        }
        else {
            self.postImageView.isHidden = true
        }
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
            masterVC =  self.menuContainerViewController.leftMenuViewController as! MenuViewController!
        }
        else {
            masterVC = self.splitViewController?.viewControllers.first
        }
        
        if ((masterVC as? MenuViewController) != nil) {
            (masterVC as! MenuViewController).toggleLeftSplitMenuController()
        }
    }
}
