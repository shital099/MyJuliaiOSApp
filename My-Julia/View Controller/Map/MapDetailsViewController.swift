//
//  MapDetailsViewController.swift
//  My-Julia
//
//  Created by GCO on 24/04/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

class MapDetailsViewController: UIViewController, UIScrollViewDelegate {
    
    var nameStr: String?
    var imgStr: String?
    var mapId: String?
    var lastScale : CGFloat = 0.0
    let kMaxScale : CGFloat = 2.0
    let kMinScale : CGFloat = 0.7
    var currentScale : CGFloat = 1.0

    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var bgImageView: UIImageView!

    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.title = nameStr
        
        SDImageCache.shared().removeImage(forKey: imgStr, withCompletion: nil)
        imageview.sd_setImage(with: NSURL(string:imgStr!)! as URL?, placeholderImage: nil)

        self.createPanGestureRecognizer(targetView: imageview)
        
        //apply application theme on screen
        CommonModel.sharedInstance.applyThemeOnScreen(viewController: self, bgImage: bgImageView)

        self.updateReadStatus()
    }

    // MARK: - Webservice Methods

    func updateReadStatus()  {

        let urlStr = UpdateReadStatus.appendingFormat("flag=%@&Id=%@",Update_Map_List,self.mapId!)
        print("map update url : ",urlStr)

        NetworkingHelper.getRequestFromUrl(name:UpdateReadStatus,  urlString:urlStr, callback: { response in
            print("map update responce : ",response)

        }, errorBack: { error in
        })
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
        // get translation
        let translation = panGesture.translation(in: view)
        panGesture.setTranslation(CGPoint.zero, in: view)

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

    /*//
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // textLabel.text = nameStr
        imageView.image = UIImage(named: imgStr!)
        
        let vWidth = self.view.frame.width
        let vHeight = self.view.frame.height
        
        let scrollImg: UIScrollView = UIScrollView()
        scrollImg.delegate = self
        scrollImg.frame = CGRect(x: 0, y: 0, width: vWidth, height: vHeight)
        scrollImg.backgroundColor = UIColor(red: 90, green: 90, blue: 90, alpha: 0.90)
        scrollImg.alwaysBounceVertical = false
        scrollImg.alwaysBounceHorizontal = false
        scrollImg.showsVerticalScrollIndicator = true
        scrollImg.flashScrollIndicators()
        
        scrollImg.minimumZoomScale = 1.0
        scrollImg.maximumZoomScale = 10.0
        
         self.view.addSubview(scrollImg)
        
        imageView!.layer.cornerRadius = 11.0
        imageView!.clipsToBounds = false
        scrollImg.addSubview(imageView!)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }*/

}
