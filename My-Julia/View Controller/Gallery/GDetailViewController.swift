//
//  GDetailViewController.swift
//  EventApp
//
//  Created by GCO on 27/04/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

class GDetailViewController: UIViewController, UIScrollViewDelegate {
    
    var imgIndex: Int = 0
    
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!

    var listArray:[PhotoGallery] = []
    var frame: CGRect!
    var screenWidth: CGFloat!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = String(format: "%d of %d",self.imgIndex + 1,listArray.count)

        //apply application theme on screen
        CommonModel.sharedInstance.applyThemeOnScreen(viewController: self, bgImage: bgImageView)

        if IS_IPAD {
            if self.splitViewController?.displayMode == UISplitViewControllerDisplayMode.primaryHidden {
                screenWidth = self.view.frame.size.width
                frame = CGRect(x: 10, y: 10, width: self.view.frame.size.width - 20, height: self.view.frame.size.height - 80)
            }
            else {
                screenWidth = self.view.frame.size.width - SPLIT_WIDTH
                frame = CGRect(x: 10, y: 10, width: self.view.frame.size.width - ( SPLIT_WIDTH + 20 ), height: self.view.frame.size.height - 80)
            }
        }
        else {
            screenWidth = self.view.frame.size.width
            frame = CGRect(x: 10, y: 10, width: self.view.frame.size.width-20, height: self.view.frame.size.height - 80)
        }

        for index in 0..<listArray.count {
            let model = self.listArray[index]

            self.scrollView.isPagingEnabled = true
            
            let subView = UIImageView(frame: frame)
            subView.sd_setImage(with: NSURL(string:model.iconUrl) as URL?, placeholderImage: nil)
            subView.tag = index
            subView.contentMode = UIViewContentMode.scaleAspectFit
            self.scrollView .addSubview(subView)
            
            frame.origin.x += frame.size.width + 20
        }

        self.scrollView.delegate = self
        self.scrollView.bounces = false
        self.scrollView.contentSize = CGSize(width: screenWidth * CGFloat(listArray.count), height: 1)
        
        //self.scrollView.contentSize = CGSize(width: (CGFloat(listArray.count * 20) + frame.width) * CGFloat(listArray.count), height: 1)
        
        let x : CGFloat = screenWidth * CGFloat(self.imgIndex)
        print("X ", x)
        self.scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
       // self.imgIndex = Int(scrollView.contentOffset.x / screenWidth);
       // self.title = String(format: "%d of %d",self.imgIndex,listArray.count)
        
        let pageNumber = Int(round(scrollView.contentOffset.x / scrollView.frame.size.width) + 1)
        self.title = String(format: "\(pageNumber) of %d",listArray.count)
    }
}
