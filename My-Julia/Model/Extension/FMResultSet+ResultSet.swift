//
//  UIColor+.swift
//  EventApp
//
//  Created by GCO on 5/3/17.
//  Copyright © 2017 GCO. All rights reserved.
//

extension FMResultSet {
    
    func isNullForColumnIndex(columnIdx: Int32) -> Bool {
        
        let value = self.object(forColumnIndex: columnIdx)
        if (value as? NSNull) != nil {
            return true
        } else {
            return (value == nil)
        }
    }
    
    func isNullForColumnName(columnName: String) -> Bool {
        
        let value = self.object(forColumnName: columnName)
        if (value as? NSNull) != nil {
            return true
        } else {
            return false
        }
    }

}
