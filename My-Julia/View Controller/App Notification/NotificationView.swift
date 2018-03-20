//
//  NotificationView.swift
//  EventApp
//
//  Created by GCO on 9/8/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

class NotificationView: UIView {
    
    @IBOutlet weak var appIconImage: UIImageView!
    @IBOutlet weak var appNameLbl: UILabel!
    @IBOutlet weak var message: UILabel!

    override func draw(_ rect: CGRect) {
        
        self.layoutIfNeeded()
        self.appIconImage.layer.cornerRadius = 3.0

        if UIImage.init(named: "AppIcon20x20", in: Bundle.main, compatibleWith: nil) != nil
        {
           let appIcon  = UIImage.init(named: "AppIcon20x20", in: Bundle.main, compatibleWith: nil)
           // print("app icon size : ",appIcon?.size.width)
            self.appIconImage.image = CommonModel.sharedInstance.resizeImage(image: appIcon!, newWidth: 20)
            self.appIconImage.contentMode = UIViewContentMode.scaleToFill
        }
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */

    
}
