//
//  AnimationListCell.swift
//  TelerikUIExamplesInSwift
//
//  Copyright (c) 2015 Telerik. All rights reserved.
//

import UIKit

class AnimationListCell: TKListViewCell {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.imageView.contentMode = UIViewContentMode.scaleAspectFill
        
        let view = self.backgroundView as! TKView
        view.stroke = TKStroke(color:UIColor(white:0.9, alpha:0.9), width:0.5)
        
        self.contentView.layer.masksToBounds = true
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.frame = self.contentView.frame.insetBy(dx: 1, dy: 1)
    }
    
    

}
