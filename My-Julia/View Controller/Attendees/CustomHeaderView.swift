//
//  CustomHeaderView.swift
//  My-Julia
//
//  Created by GCO on 7/21/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

class CustomHeaderView: UITableViewHeaderFooterView {
    
    @IBOutlet var headerLabel:UILabel!
    @IBOutlet var gradientView:GradientView!
    @IBOutlet var upperLine:UILabel!
    @IBOutlet var bottomLine:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setGradientColor() {
        upperLine.backgroundColor = AppTheme.sharedInstance.backgroundColor.darker(by:10)
        bottomLine.backgroundColor = AppTheme.sharedInstance.backgroundColor.darker(by:10)
        
        gradientView?.colors = [
            AppTheme.sharedInstance.backgroundColor.darker(by: 4)!,
            AppTheme.sharedInstance.backgroundColor.darker(by: 4)!
        ]
    }
    
}
