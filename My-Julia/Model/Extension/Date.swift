//
//  Date.swift
//  My-Julia
//
//  Created by GCO on 8/9/17.
//  Copyright © 2017 GCO. All rights reserved.
//

extension Date {
    
    var millisecondsSince1970:Int {
        return Int((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }
    
    func yearsFrom(date:NSDate) -> Int{

        return NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!.components(NSCalendar.Unit.year, from: date as Date, to: self as Date, options: []).year!
    }
    func monthsFrom(date:NSDate) -> Int{
        return NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!.components(NSCalendar.Unit.month, from: date as Date, to: self as Date, options: []).month!
    }
    func weeksFrom(date:NSDate) -> Int{
        return NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!.components(NSCalendar.Unit.weekOfYear, from: date as Date, to: self as Date, options: []).weekOfYear!
    }
    func daysFrom(date:NSDate) -> Int{
        return NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!.components(NSCalendar.Unit.day, from: date as Date, to: self as Date, options: []).day!
    }
    func hoursFrom(date:NSDate) -> Int{
        return NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!.components(NSCalendar.Unit.hour, from: date as Date, to: self as Date, options: []).hour!
    }
    func minutesFrom(date:NSDate) -> Int{
        return NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!.components(NSCalendar.Unit.minute, from: date as Date, to: self as Date, options: []).minute!
    }
    func secondsFrom(date:NSDate) -> Int{
        return NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!.components(NSCalendar.Unit.second, from: date as Date, to: self as Date, options: []).second!
    }
    
    func offsetFrom(date:NSDate) -> String {
        let yearsFromDate   = yearsFrom(date: date)
        let monthsFromDate  = monthsFrom(date: date)
        let weeksFromDate   = weeksFrom(date: date)
        let daysFromDate    = daysFrom(date: date)
        let hoursFromDate   = hoursFrom(date: date)
        let minutesFromDate = minutesFrom(date: date)
        let secondsFromDate = secondsFrom(date: date)

        if yearsFromDate   > 0 { return "\(yearsFromDate) year"     + { return yearsFromDate   > 1 ? "s" : "" }() }
        if monthsFromDate  > 0 { return "\(monthsFromDate) month"   + { return monthsFromDate  > 1 ? "s" : "" }() }
        if weeksFromDate   > 0 { return "\(weeksFromDate) week"     + { return weeksFromDate   > 1 ? "s" : "" }() }
        if daysFromDate    > 0 { return "\(daysFromDate) day"       + { return daysFromDate    > 1 ? "s" : "" }() }
        if hoursFromDate   > 0 { return "\(hoursFromDate) hour"     + { return hoursFromDate   > 1 ? "s" : "" }() }
        if minutesFromDate > 0 { return "\(minutesFromDate) minute" + { return minutesFromDate > 1 ? "s" : "" }() }
        if secondsFromDate > 0 { return "\(secondsFromDate) second" + { return secondsFromDate > 1 ? "s" : "" }() }
        return "0"
    }
}
