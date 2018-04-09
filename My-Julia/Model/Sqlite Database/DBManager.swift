
//
//  DBManager.swift
//  My-Julia
//
//  Created by GCO on 5/25/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

class DBManager: NSObject {
    
    var databasePath = String()
    
    var database: FMDatabase!
    
    let databaseFileName = DATABASE_NAME
    
    //MARK: Shared Instance
    
    static let sharedInstance: DBManager = DBManager()
    
    override init() {
        super.init()
        
        let documentsDirectory = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString) as String
        databasePath = documentsDirectory.appending("/\(databaseFileName)")
    }
    
    func getPath(fileName: String) -> String {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(fileName)
        
        return fileURL.path
    }

    func copyFile(fileName: String) {
        
        let dbPath: String = getPath(fileName: fileName)
        let fileManager = FileManager.default

        if !fileManager.fileExists(atPath: dbPath) {
            
            let documentsURL = Bundle.main.resourceURL
            let fromPath = documentsURL!.appendingPathComponent(fileName as String)
            
            var error : NSError?
            do {
                try fileManager.copyItem(atPath: fromPath.path, toPath: dbPath)
            } catch let error1 as NSError {
                error = error1
            }
        }
        else {
            print("DB Copy error message ")
            //Add 1 colum in Attendee Table
            _ = addDBColumn(sTable:"Attendees", sColumnName:"DNDSetting", type: "boolean", value : false)
        
            //Add 1 colum in Attendee Profile Table
            _ = addDBColumn(sTable:"AttendeeProfile", sColumnName:"DNDSetting",type: "boolean", value : false)
         
            //Add 2 colum in Documents Table
            _ = addDBColumn(sTable:"Documents", sColumnName:"StartDate",type: "text", value : "")
            _ = addDBColumn(sTable:"Documents", sColumnName:"EndDate",type: "text", value : "")
            
        }
    }
    
    func createDatabase() -> Bool {
        var success = false
        
       // if !FileManager.default.fileExists(atPath: databasePath) {
            
            database = FMDatabase(path: databasePath)
            
            if database != nil {
                // Open the database.
                if database.open() {

                    //Create Login Details table
                    let login_details_sql = "CREATE TABLE IF NOT EXISTS LoginAttendee (EventID text, AttendeeId text, AttendeeCode text, Token text, IsAccept boolean default false, UNIQUE(EventID, AttendeeId) ON CONFLICT REPLACE);"

                    //Create Event Details table
//                    let event_details_sql = "CREATE TABLE IF NOT EXISTS EventDetails (EventID text, AttendeeId text, Name text, EventCode text, Location text, Type text, Status text, StartDate text, EndDate text, LogoUrl text, CoverImageLogo text, UNIQUE(EventID, AttendeeId) ON CONFLICT REPLACE);"

                    let event_details_sql = "CREATE TABLE IF NOT EXISTS EventDetails (EventID text unique, AttendeeId text, Name text, EventCode text, Location text, Type text, Status text, StartDate text, EndDate text, LogoUrl text, CoverImageLogo text);"

                    //Create Event Details table
                    let event_sql_stmt = "CREATE TABLE IF NOT EXISTS ApplicationTheme (ID INTEGER PRIMARY KEY AUTOINCREMENT, EventID text unique, IsHeaderImage text, HeaderImageUrl text, HeaderColor text, HeaderTextColor text ,HeaderFontName text, HeaderFontStyle text , HeaderFontSize Int, IsBackgroundImage text, BackgroundImageUrl text, BackgroundColor text, IsLogoIconImage text, LogoIconImageUrl text, LogoImageUrl text, LogoText text, LogoIconTextColor text, IconTextFontName text, IconTextFontStyle text , IconTextFontSize Int, SideMenuFontName text, SideMenuFontStyle text,  SideMenuFontSize Int, SideMenuColour text, SideMenuTextColor text);"
                    
                    //Create Modules table
                    let module_sql_stmt = "CREATE TABLE IF NOT EXISTS Module (ID INTEGER PRIMARY KEY AUTOINCREMENT,EventID text, ModuleID text unique, ModuleName text, LIconUrl text, SIconUrl text,  TextColor text, isUserRelated bool, isCustomModule bool, Content text, isDeleted boolean default false, OrderSequence Int);"
                    
                    //Create Attendee table
                    let attendee_sql = "CREATE TABLE IF NOT EXISTS Attendees (ID INTEGER PRIMARY KEY AUTOINCREMENT,EventID text, attendeeID text unique, name text, address text, phoneNo text, iconUrl text, designation text, email text, description text, PrivacySetting  boolean default true, DNDSetting boolean default false);"
                    
                    //Create MyNote table
                    let note_sql = "CREATE TABLE IF NOT EXISTS Notes (id INTEGER PRIMARY KEY AUTOINCREMENT, EventID text , AttendeeId text, title text, message text, date text, SessionId text, ActivityId text);"
                    
                    //Create Reminder table
                    let reminder_sql = "CREATE TABLE IF NOT EXISTS Reminder (id INTEGER PRIMARY KEY AUTOINCREMENT, EventID text, AttendeeId text, Title text, Message text, SortDate text, ReminderTime text, ActivitySessionId text, ActivityId text , ActivityStartTime text, ActivityEndTime text, UNIQUE (ActivityId, Title, SortDate));"
                    
                    //Create Speaker table
                    let speaker_sql = "CREATE TABLE IF NOT EXISTS Speaker ( EventID text, SpeakerId text, AttendeeID text, Name text, Description text, Designation text, Iconurl text, ContactNo text, Email text, Address text, activityIds text, ActivityId text, UNIQUE (EventID, SpeakerId, AttendeeID) ON CONFLICT REPLACE);"

                    //Create Agenda table
                    let agenda_sql = "CREATE TABLE IF NOT EXISTS Agenda (id INTEGER PRIMARY KEY AUTOINCREMENT, SessionID text, ActivitySessionId text, EventID text, ActivityID text, ActivityName text, AgendaId text, AgendaName text, ActivityStartDate text, ActivityEndDate text, SortStartDate text, SortEndDate text, SortActivityDate text, Location text, StartTime text, EndTime text, StartDate text, EndDate text, Day text, Description text,  SpeakerId text , UNIQUE (ActivitySessionId, EventID) ON CONFLICT REPLACE );"
                    
                    let myschedule_sql = "CREATE TABLE IF NOT EXISTS MySchedule (id INTEGER PRIMARY KEY AUTOINCREMENT,EventID text, AttendeeId text, ActivitySessionId text, SessionID text, ActivityID text, isUserSchedule boolean default false, UNIQUE (EventID, AttendeeId, ActivitySessionId) ON CONFLICT REPLACE);"

                   // CREATE TABLE name (column defs, UNIQUE (col_name1, col_name2) ON CONFLICT REPLACE);

                    //Create Map table
                    let map_sql = "CREATE TABLE IF NOT EXISTS Map (EventID text, Id text unique, Name text, FloorPlanImage text );"

                    //Create Feedback table
                    let feedback_sql = "CREATE TABLE IF NOT EXISTS Feedback (EventID text, QuestionId text unique, Question text, OptionArray text, QuestionType text);"

                    //Create Feedback table
                    let act_feedback_sql = "CREATE TABLE IF NOT EXISTS ActivityFeedback (id INTEGER PRIMARY KEY AUTOINCREMENT, EventID text, QuestionId text, ActivityId text, Question text, OptionArray text, QuestionType text, CreatedDate text, UNIQUE (EventID, ActivityId, QuestionId ) ON CONFLICT REPLACE);"

                    //Create Gallery table
                    let gallery_sql = "CREATE TABLE IF NOT EXISTS Gallery (EventID text, Id text unique, Images text, isDeleted boolean);"
                    
                    //Create Website table
                    let website_sql = "CREATE TABLE IF NOT EXISTS Website (EventID text, Id text unique, websiteUrl text);"
                    
                    //Create Sponsors table
                    let sponsor_sql = "CREATE TABLE IF NOT EXISTS Sponsors (EventID text, id text unique, Name text, Description text, IconUrl text, ContactNo text, Email text, Address text, Website text);"
                    

                    //Create Email table
                    let email_details_sql = "CREATE TABLE IF NOT EXISTS Email (EventID text, Eid text , eFrom text, eTo text, SentTime text, Content text, Subject text, AttachmentContent text, Attachments text, AttendeeId text,UNIQUE (EventID, AttendeeId, Eid) ON CONFLICT REPLACE);"
                    
                    //Create Documents table
                    let document_sql = "CREATE TABLE IF NOT EXISTS Documents (EventID text, docId text unique, Title text, Description text, UrlPath text, StartDate text, EndDate text);"

                    //Create Emergency Details table
                    let emergency_sql = "CREATE TABLE IF NOT EXISTS EmergencyInfo (id INTEGER PRIMARY KEY AUTOINCREMENT, EventID text, Title text unique, Description text, ContactNo text , Address text, Email text);"
                    
                    //Create User Profile table
                    let profile_sql = "CREATE TABLE IF NOT EXISTS AttendeeProfile (id INTEGER PRIMARY KEY AUTOINCREMENT, EventID text, AttendeeId text unique, AttendeeName text, AttendeeCode text, AttendeeEmail text, ContactNo text, ProfileSetting bool default true, QRCode text, GroupsName text, Department text, ImgPath text, DNDSetting boolean default false, isSpeaker boolean default false, SpeakerId text);"
                    
                    //Create Wifi table
                    let wifi_details_sql = "CREATE TABLE IF NOT EXISTS Wifi (EventID text, Id text unique, Name text, Network text, Password text, Note text, CreatedDate text);"
                    
                    //Create Agenda and Speaker Relational table
                    let activity_details_sql = "CREATE TABLE IF NOT EXISTS AgendaSpeakerRelation (id INTEGER PRIMARY KEY AUTOINCREMENT, EventID text, ActivityId text, SpeakerId text, AttendeeId text, UNIQUE (EventID, ActivityId, SpeakerId) ON CONFLICT REPLACE);"

                    //Create All completed session table
                    /*REmove session id logic
                    let sessions_sql = "CREATE TABLE IF NOT EXISTS QuestionActivities (id INTEGER PRIMARY KEY AUTOINCREMENT, EventID text, ActivitySessionId text unique, SessionId text, ActivityId text, SpeakerId text, ActivityName text, ActivityStartDate text, ActivityEndDate text, StartTime text, EndTime text, SortActivityDate text, ActivityDay text, isActive bool, AgendaId text, AgendaName text, Location text, QuesCount text);"*/
                    let sessions_sql = "CREATE TABLE IF NOT EXISTS QuestionActivities (id INTEGER PRIMARY KEY AUTOINCREMENT, EventID text, ActivitySessionId text, SessionId text, ActivityId text, SpeakerId text, ActivityName text, ActivityStartDate text, ActivityEndDate text, StartTime text, EndTime text, SortActivityDate text, ActivityDay text, isActive bool, AgendaId text, AgendaName text, Location text, QuesCount text, UNIQUE (EventID, ActivityId) ON CONFLICT REPLACE);"

                    //Create Question table
                    let sessions_que_sql = "CREATE TABLE IF NOT EXISTS QAQuestions (id INTEGER PRIMARY KEY AUTOINCREMENT, EventID text,  QueId text unique, ActivityId text,SessionId text, Question text, AttendeeId text, Name text, QueCount text, isUserLike bool, Time text);"

                    //Poll completed session table
                    /*REmove session id logic
                    let poll_activity_sql = "CREATE TABLE IF NOT EXISTS PollActivities (id INTEGER PRIMARY KEY AUTOINCREMENT, EventID text, ActivitySessionId text unique, SessionId text, ActivityId text, SpeakerId text, ActivityName text, ActivityStartDate text, ActivityEndDate text, StartTime text, EndTime text, SortActivityDate text, ActivityDay text, isActive bool, AgendaId text, AgendaName text, Location text, QuesCount text;"*/

                    let poll_activity_sql = "CREATE TABLE IF NOT EXISTS PollActivities (id INTEGER PRIMARY KEY AUTOINCREMENT, EventID text, ActivitySessionId text, SessionId text, ActivityId text, SpeakerId text, ActivityName text, ActivityStartDate text, ActivityEndDate text, StartTime text, EndTime text, SortActivityDate text, ActivityDay text, isActive bool, AgendaId text, AgendaName text, Location text, QuesCount text, UNIQUE (EventID, ActivityId) ON CONFLICT REPLACE);"
                    
                    //Poll Activity Question list table
                    let poll_sessions_que_sql = "CREATE TABLE IF NOT EXISTS PollQuestions (id INTEGER PRIMARY KEY AUTOINCREMENT, EventID text,  QueId text unique, ActivityId text,SessionId text, Question text,Options text, AttendeeId text, OptionsCount text, isUserAnswered bool, UserAnswer text);"

                    //Create Notificatio table
                     let noti_sql = "CREATE TABLE IF NOT EXISTS Notifications (EventID text, AttendeeId text, notiId text, Title text, Description text, CreatedDate text, IsRead boolean default false,  UNIQUE (EventID, notiId, AttendeeId) ON CONFLICT REPLACE);"

                    //Create Activity Feeds table
                    let activityFeed_sql = "CREATE TABLE IF NOT EXISTS ActivityFeeds (id INTEGER PRIMARY KEY AUTOINCREMENT, EventID text, ActivityFeedID text, Message text, LikeCount text, CommentCount text, CreatedDate text, IsImageDeleted boolean default false, PostImagePath text, PostUserName text, PostUserImage text, PostUserId text, UNIQUE (EventID, ActivityFeedID) ON CONFLICT REPLACE);"
                    
                    let activityFeedLikes_sql = "CREATE TABLE IF NOT EXISTS ActivityFeedsLikes (id INTEGER PRIMARY KEY AUTOINCREMENT, EventID text, ActivityFeedID text, AttendeeId text, Name text, IconUrl text, IsUserLike boolean default false, CreatedDate text, UNIQUE (EventID, ActivityFeedID, AttendeeId) ON CONFLICT REPLACE);"

                    let activityFeedComments_sql = "CREATE TABLE IF NOT EXISTS ActivityFeedsComments (id INTEGER PRIMARY KEY AUTOINCREMENT, EventID text, ActivityFeedID text, CommentId text, AttendeeId text, Name text, IconUrl text, Comments text,CreatedDate text, UNIQUE (EventID, ActivityFeedID, AttendeeId, CommentId) ON CONFLICT REPLACE);"
                    
                    //Chat
                    let chatlist_sql = "CREATE TABLE IF NOT EXISTS ChatList (id INTEGER PRIMARY KEY AUTOINCREMENT, EventID text, AttendeeId text, GroupId text, FromId text, ToId text, Name text,  GroupIconUrl text, LastMessage text, MessageImgUrl text, CreatedDate text, ModifiedDate text, GroupCreatedBy text, isGroupChat boolean default false, PrivacySetting  boolean default true, DNDSetting boolean default false, IsDeleted boolean default false, IsReadList boolean default true, UnreadCount text,  UNIQUE (EventID, AttendeeId, GroupId ) ON CONFLICT REPLACE);"
                    
                    let chathistorySql = "CREATE TABLE IF NOT EXISTS ChatHistory (id INTEGER PRIMARY KEY AUTOINCREMENT, EventID text, AttendeeId text, GroupId text, ChatMessageId text, CreatedBy text, FromId text, ToId text, CreatedDate text, ModifiedDate text, UserIconUrl text, UserName text, ToIconUrl text, ToUserName text,  MessageIconUrl text, Message text, Status text, MessageType text, MessageFromMe Integer, isGroupChat Integer, IsRead boolean default false , IsDeleted boolean default false , IsFromDeleted boolean default false , IsToDeleted boolean default false , UNIQUE (EventID, AttendeeId, GroupId, ChatMessageId) ON CONFLICT REPLACE);"

                    //Poll Speaker Activity lis table
                    let poll_speaker_act_sql = "CREATE TABLE IF NOT EXISTS PollSpeakerActivity (id INTEGER PRIMARY KEY AUTOINCREMENT, EventID text, ActivityId text unique, ActivityName text, ActivityStartDate text, ActivityEndDate text, SpeakerId text, UNIQUE (EventID, ActivityId, SpeakerId) ON CONFLICT REPLACE );"

                    //Poll Speaker Act questions
                    let poll_act_question_sql = "CREATE TABLE IF NOT EXISTS SpeakerPollQuestions(id INTEGER PRIMARY KEY AUTOINCREMENT, EventID text, ActivityId text, Question text, QuestionId text, Option1 text, Option2 text, Option3 text, Option4 text, Op1Id text, Op2Id text, Op3Id text, Op4Id text, UNIQUE (EventID, ActivityId, QuestionId ) ON CONFLICT REPLACE );"

                    let sql_stmt = login_details_sql + event_sql_stmt + module_sql_stmt + attendee_sql + note_sql + reminder_sql + speaker_sql + map_sql + feedback_sql + sponsor_sql + event_details_sql + document_sql + emergency_sql + gallery_sql + website_sql + wifi_details_sql + email_details_sql + activity_details_sql + profile_sql + sessions_sql + sessions_que_sql + poll_activity_sql + poll_sessions_que_sql + myschedule_sql + agenda_sql + noti_sql + activityFeed_sql + activityFeedComments_sql + activityFeedLikes_sql + act_feedback_sql + chatlist_sql + chathistorySql + poll_speaker_act_sql + poll_act_question_sql
                    
                   // do {
                        success = database.executeStatements(sql_stmt)
//                    }
//                    catch {
//                        print("Could not create tables.")
//                        print(error.localizedDescription)
//                    }

                    database.close()
                }
                else {
                    print("Could not open the database.")
                }
          //  }
        }
        return success
    }
    
    func openDatabase() -> Bool {
        //print("database path ", databasePath)
//        print("DB Path ", self.databasePath)

        if database == nil {
            if FileManager.default.fileExists(atPath: databasePath) {
                database = FMDatabase(path: databasePath)
            }
        }
        
        if database != nil {
            if database.open() {
                return true
            }
        }
        
        return false
    }
    
/**
 
     ADD Column in table
 **/
    
    func addDBColumn( sTable : String, sColumnName : String, type : String, value : Any) -> Bool
    {
        var sucess : Bool = false
        if openDatabase() {
            
            if !database.columnExists(sColumnName, inTableWithName:sTable) {
                //do {
                //try database.executeUpdate("ALTER TABLE ? ADD COLUMN ? TEXT", values: [sTable, sColumnName])
                var querySQL = ""
                if type == "boolean" {
                    querySQL = "ALTER TABLE \(sTable) ADD COLUMN \(sColumnName) \(type) default \(value)"
                }
                else {
                    querySQL = "ALTER TABLE \(sTable) ADD COLUMN \(sColumnName) \(type)"
                }
                
                sucess =  database.executeUpdate(querySQL, withArgumentsIn: nil)
            }
            //                catch  {
            //                    print("error adding column in table = \(error)")
            //                }
            
            database.close()
        }
        return sucess
    }
    
    // MARK: - Data EVENT DETAILS / APP THEME / USER PROFILE methods

    func saveLoginEventDataIntoDB(response: AnyObject) {
        
        if openDatabase() {
            
            self.database.beginTransaction()
            
            if response is NSDictionary {
                let dict = response as! NSDictionary
                
                //Save events details
                if (dict.value(forKey:"events") as? NSNull) == nil {
                    
                    var dataDict : NSDictionary!
                    if dict.value(forKey:"events") is NSArray {
                        let arr = dict.value(forKey:"events") as! NSArray
                        if arr.count != 0 {
                            dataDict = arr[0] as! NSDictionary
                        }
                    }
                    else {
                        dataDict = dict.value(forKey:"events") as! NSDictionary
                    }
                    
                    self.saveEventDetailsDataIntoDB(responce: dataDict)
                }
                
                //Save modules and Theme details
                if (dict.value(forKey:"alldetails") as? NSNull) == nil {
                    
                    //Without sp
                    // let moduleDict = dict.value(forKey:"alldetails") as! NSDictionary
                    
                    //With Sp
                    var moduleDict : NSDictionary!
                    if dict.value(forKey:"alldetails") is NSArray {
                        let arr = dict.value(forKey:"alldetails") as! NSArray
                        if arr.count != 0 {
                            moduleDict = arr[0] as! NSDictionary
                        }
                    }
                    else {
                        moduleDict = dict.value(forKey:"alldetails") as! NSDictionary
                    }
                    
                    //Save modules
                    let themeDict = moduleDict.value(forKey:"CommonForAll") as! NSDictionary
                    self.insertApplicationThemeDataIntoDB(themeDict: themeDict)
                    
                    //Save Theme
                    self.insertApplicationModulesDataIntoDB(responce: moduleDict as AnyObject)
                }
                
                //Save Attendee Profile
                if (dict.value(forKey:"profile") as? NSNull) == nil {
                    
                    var dataDict : NSDictionary!
                    if dict.value(forKey:"profile") is NSArray {
                        let arr = dict.value(forKey:"profile") as! NSArray
                        if arr.count != 0 {
                            dataDict = arr[0] as! NSDictionary
                        }
                    }
                    else {
                        dataDict = dict.value(forKey:"profile") as! NSDictionary
                    }
                    
                    //Add All Profile data in database
                    self.saveProfileDataIntoDB(response: dataDict)
                }
            }

            self.database.commit()
            self.database.close()
        }        
    }
    
    func saveAllEventDataIntoDB(response: AnyObject, apiNname: String) {

        if openDatabase() {
            if response is NSArray {
                let arr = response as! NSArray
                let rawDict = arr[0]
                
                if rawDict is NSDictionary {
                    let dict = rawDict as! NSDictionary

                    //Save All module data
                    if apiNname == Get_AllModuleDetails_url {
                        //Save Feedback List Profile
                        if (dict.value(forKey:"feedbackList") as? NSNull) == nil {
                            self.saveFeedbackDataIntoDB(responce: dict.value(forKey:"feedbackList") as AnyObject)
                        }
                        //Save Notification List Profile
                        if (dict.value(forKey:"notificationlst") as? NSNull) == nil {
                            self.saveNotificationDataIntoDB(response: dict.value(forKey: "notificationlst") as AnyObject)
                        }
                        //Save Speaker List Profile
                        if (dict.value(forKey:"speackerlist") as? NSNull) == nil {
                            self.saveSpeakersDataIntoDB(responce: dict.value(forKey:"speackerlist") as AnyObject)
                        }
                        //Save Sponsors List Profile
                        if (dict.value(forKey:"sponsorlist") as? NSNull) == nil {
                            self.saveSponsorsDataIntoDB(responce: dict.value(forKey:"sponsorlist") as AnyObject)
                        }
                        //Save WiFi List Profile
                        if (dict.value(forKey:"wifiList") as? NSNull) == nil {
                            self.saveWifiDataIntoDB(response: dict.value(forKey:"wifiList") as AnyObject)
                        }
                        //Save Poll Activity List Profile
                        if (dict.value(forKey:"pollActivitylst") as? NSNull) == nil {
                            self.savePollActivitySessionsIntoDB(response: dict.value(forKey:"pollActivitylst") as AnyObject)
                        }
                        //Save Map list
                        if (dict.value(forKey:"maplist") as? NSNull) == nil {
                            self.saveMapDataIntoDB(response: dict.value(forKey:"maplist") as AnyObject)
                        }
                            //Save Activity Feeds list
                        if (dict.value(forKey:"activtyfeed") as? NSNull) == nil {
                            self.saveActivityFeedDataIntoDB(response: dict.value(forKey:"activtyfeed") as AnyObject)
                        }
                            //Save Photo gallery list
                        if (dict.value(forKey:"photoGallery") as? NSNull) == nil {
                            self.saveGalleryDataIntoDB(response: dict.value(forKey:"photoGallery") as AnyObject)
                        }
                        //Save Website list
                        if (dict.value(forKey:"website") as? NSNull) == nil {
                            self.saveWebsiteDataIntoDB(response: dict.value(forKey:"website") as AnyObject)
                        }
                            //Save Emergency list
                        if (dict.value(forKey:"emergencyNos") as? NSNull) == nil {
                            self.saveEmergencyDataIntoDB(response: dict.value(forKey:"emergencyNos") as AnyObject)
                        }
                            //Save Document list
                        if (dict.value(forKey:"documents") as? NSNull) == nil {
                            self.saveDocumentsDataIntoDB(response: dict.value(forKey:"documents") as AnyObject)
                        }
                            //Save Email List
                        if (dict.value(forKey:"emails") as? NSNull) == nil {
                            self.saveEmailDataIntoDB(response: dict.value(forKey:"emails") as AnyObject)
                        }
                            //Save Questions activity List
                        if (dict.value(forKey:"qaActivityList") as? NSNull) == nil {
                            self.saveActiveSessionIntoDB(response: dict.value(forKey:"qaActivityList") as AnyObject)
                        }

                        //Save Chat Attendee List
                        if (dict.value(forKey:"attChatList") as? NSNull) == nil {
                            //Delete chat list
                            self.updateChatListDataFromDB()
                             self.saveChatListIntoDB(response: dict.value(forKey:"attChatList") as AnyObject, isGroupChat: 0)
                        }
                        //Save Chat Group List
                        if (dict.value(forKey:"attGroupChatList") as? NSNull) == nil {
                            self.saveChatListIntoDB(response: dict.value(forKey:"attGroupChatList") as AnyObject, isGroupChat: 1)
                        }
                        //Save Agenda details
                        if (dict.value(forKey:"activities") as? NSNull) == nil {
                            self.saveAgendaDataIntoDB(responce: dict.value(forKey:"activities") as AnyObject)
                        }
                        //Save Attendee modules details
                        if (dict.value(forKey:"allAttendeeList") as? NSNull) == nil {
                            self.saveAttendeesDataIntoDB(responce: dict.value(forKey:"allAttendeeList") as AnyObject)
                        }
                    }
                    else if apiNname == GetPollActivities__url {
                        //Save Poll Activity List Profile
                        if (dict.value(forKey:"pollActivitylst") as? NSNull) == nil {
                            self.savePollActivitySessionsIntoDB(response: dict.value(forKey:"pollActivitylst") as AnyObject)
                        }
                    }
                    else if apiNname == GetQuestionActivities_url {
                        //Save Questions activity List
                        if (dict.value(forKey:"qaActivityList") as? NSNull) == nil {
                            self.saveActiveSessionIntoDB(response: dict.value(forKey:"qaActivityList") as AnyObject)
                        }
                    }
                    else if apiNname == ActivityFeed_List_url {
                       
                        //Save Activity Feeds list
                        if (dict.value(forKey:"activtyfeed") as? NSNull) == nil {
                            self.saveActivityFeedDataIntoDB(response: dict.value(forKey:"activtyfeed") as AnyObject)
                        }
                    }
                    else if apiNname == PhotoGallery_List_url {
                        //Save Photo gallery list
                        if (dict.value(forKey:"photoGallery") as? NSNull) == nil {
                            self.saveGalleryDataIntoDB(response: dict.value(forKey:"photoGallery") as AnyObject)
                        }
                    }
                    else if apiNname == Notification_List_url {
                        if (dict.value(forKey:"notificationlst") as? NSNull) == nil {
                            self.saveNotificationDataIntoDB(response: dict.value(forKey: "notificationlst") as AnyObject)
                        }
                    }
                    else if apiNname == Attendees_List_url {
                        //Save Attendee modules details
                        if (dict.value(forKey:"allAttendeeList") as? NSNull) == nil {
                            self.saveAttendeesDataIntoDB(responce: dict.value(forKey:"allAttendeeList") as AnyObject)
                        }
                    }
                    else if apiNname == Website_List_url {
                        //Save Website list
                        if (dict.value(forKey:"website") as? NSNull) == nil {
                            self.saveWebsiteDataIntoDB(response: dict.value(forKey:"website") as AnyObject)
                        }
                    }
                    else if apiNname == Email_List_url {
                        //Save Email List
                        if (dict.value(forKey:"emails") as? NSNull) == nil {
                            self.saveEmailDataIntoDB(response: dict.value(forKey:"emails") as AnyObject)
                        }
                    }
                    else if apiNname == Chat_Contact_List {
                        //Delete chat list
                        self.updateChatListDataFromDB()

                        //Save Chat Attendee List
                        if (dict.value(forKey:"attChatList") as? NSNull) == nil {
                            self.saveChatListIntoDB(response: dict.value(forKey:"attChatList") as AnyObject, isGroupChat: 0)
                        }
                        //Save Chat Group List
                        if (dict.value(forKey:"attGroupChatList") as? NSNull) == nil {
                            self.saveChatListIntoDB(response: dict.value(forKey:"attGroupChatList") as AnyObject, isGroupChat: 1)
                        }
                    }
                    else if apiNname == Documents_List_url {
                        //Save Document list
                        if (dict.value(forKey:"documents") as? NSNull) == nil {
                            self.saveDocumentsDataIntoDB(response: dict.value(forKey:"documents") as AnyObject)
                        }
                    }
                }
            }
        }
        
        database.close()
    }

    // MARK: - Login attendee details methods

    func saveLoginAttendeeDataIntoDB() {

        if openDatabase() {
            do {
                let event = EventData.sharedInstance
                try database.executeUpdate("INSERT OR REPLACE INTO LoginAttendee (EventID, AttendeeId, AttendeeCode, Token, IsAccept) VALUES (?, ?, ?, ?, ?)", values: [event.eventId, event.attendeeId, event.attendeeCode, event.auth_token, event.attendeeStatus])

            } catch {
                print("error = \(error)")
            }
            database.close()
        }
    }

    func fetchLoginAttendeeDetailsFromDB(attendeeCode : String) {

        if openDatabase() {

            let querySQL = "Select * from LoginAttendee where AttendeeCode = ?"
            let results:FMResultSet? = database.executeQuery(querySQL, withArgumentsIn: [attendeeCode])

            while results?.next() == true {

                let model = EventData.sharedInstance
                model.eventId = (results?.string(forColumn: "EventID"))!
                model.attendeeId = (results?.string(forColumn: "AttendeeId"))!
                model.attendeeCode = (results?.string(forColumn: "AttendeeCode"))!
                model.auth_token = (results?.string(forColumn: "Token"))!
                model.attendeeStatus = (results?.bool(forColumn: "IsAccept"))!
            }
            database.close()
        }
    }


    // MARK: - Event details methods
    
    func saveEventDetailsDataIntoDB(responce: AnyObject) {
        
        //if openDatabase() {
            
            if responce is NSDictionary {
                
                do {
                    let  dict = responce as! NSDictionary
                    let eventId = self.isNullString(str: dict.value(forKey: "EventId") as Any)
                    let eventCode = self.isNullString(str: dict.value(forKey: "EventCode") as Any)
                    let eventName = self.isNullString(str: dict.value(forKey: "EventName") as Any)
                    let eventStartDate = self.isNullString(str: dict.value(forKey: "EventStartDate") as Any)
                    let eventEndDate = self.isNullString(str: dict.value(forKey: "EventEndDate") as Any)
                    let eventType = self.isNullString(str: dict.value(forKey: "EventType") as Any)
                    let eventDescription = self.isNullString(str: dict.value(forKey: "Description") as Any)
                    let eventVenue = self.isNullString(str: dict.value(forKey: "Location") as Any)
                    let eventLogoUrl = self.appendImagePath(path: dict.value(forKey: "LogoUrl") as Any)
                    let eventCoverImageUrl = self.appendImagePath(path: dict.value(forKey: "CoverImageUrl") as Any)
                                        
                    try database.executeUpdate("INSERT OR REPLACE INTO EventDetails (EventID, Name, EventCode, Location, Type, Status, StartDate, EndDate, LogoUrl, CoverImageLogo, AttendeeId) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", values: [eventId,eventName, eventCode, eventVenue, eventType, eventDescription, eventStartDate, eventEndDate, eventLogoUrl, eventCoverImageUrl, EventData.sharedInstance.attendeeId])
                    
                } catch {
                    print("error = \(error)")
                }
            }
       // }
      //  database.close()
    }

    func fetchAllEventsListFromDB() -> NSArray {

        var array = [EventModel]()

        if openDatabase() {

            let querySQL = "Select * from EventDetails"
            let results:FMResultSet? = database.executeQuery(querySQL, withArgumentsIn: [])


            while results?.next() == true {

                let model = EventModel()
                model.eventId = (results?.string(forColumn: "EventID"))!
                model.eventName = (results?.string(forColumn: "Name"))!
                model.eventCode = (results?.string(forColumn: "EventCode"))!
                model.eventVenue = (results?.string(forColumn: "Location"))!
                model.eventType = (results?.string(forColumn: "Type"))!
                model.eventDescription = (results?.string(forColumn: "Status"))!
                model.eventStartDate = (results?.string(forColumn: "StartDate"))!
                model.eventEndDate = (results?.string(forColumn: "EndDate"))!
                model.eventLogoUrl = (results?.string(forColumn: "LogoUrl"))!
                model.eventCoverImageUrl = (results?.string(forColumn: "CoverImageLogo"))!


                //Check event date status
                let currentDate = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                let eventDate = dateFormatter.date(from: model.eventEndDate)
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let str = dateFormatter.string(from: eventDate!)
                let cStr = dateFormatter.string(from: currentDate)

                let eventDate1 = dateFormatter.date(from: str)
                let currentDate1 = dateFormatter.date(from: cStr)

                if eventDate1!.compare(currentDate1!) == .orderedAscending {
                    print("event is past ")
                    model.isPastEvent = true
                }
                array.append(model)
            }
            database.close()
        }
        return array as NSArray
    }

    func fetchEventDetailsDataFromDB() -> EventData {
        let model = EventData.sharedInstance
        
        if openDatabase() {
            
            let querySQL = "Select * from EventDetails where EventID = ? AND AttendeeId = ?"
            let results:FMResultSet? = database.executeQuery(querySQL, withArgumentsIn: [model.eventId,EventData.sharedInstance.attendeeId])
            
            while results?.next() == true {
                
                model.eventId = (results?.string(forColumn: "EventID"))!
                model.eventName = (results?.string(forColumn: "Name"))!
                model.eventCode = (results?.string(forColumn: "EventCode"))!
                model.eventVenue = (results?.string(forColumn: "Location"))!
                model.eventType = (results?.string(forColumn: "Type"))!
                model.eventDescription = (results?.string(forColumn: "Status"))!
                model.eventStartDate = (results?.string(forColumn: "StartDate"))!
                model.eventEndDate = (results?.string(forColumn: "EndDate"))!
                model.eventLogoUrl = (results?.string(forColumn: "LogoUrl"))!
                model.eventCoverImageUrl = (results?.string(forColumn: "CoverImageLogo"))!
                
            }
            database.close()
        }
        return model
    }

    func deleteEventAllDetails(eventId : String) {

        if openDatabase() {
            self.database.beginTransaction()

            //Delete all data of this events

            var sqlQuery = ""
            sqlQuery += "DELETE FROM ApplicationTheme WHERE EventID = '\(eventId)'; "
            sqlQuery += "DELETE FROM EventDetails WHERE EventID = '\(eventId)'; "
            sqlQuery += "DELETE FROM Module WHERE EventID = '\(eventId)'; "
            sqlQuery += "DELETE FROM Attendees WHERE EventID = '\(eventId)'; "
            sqlQuery += "DELETE FROM Notes WHERE EventID = '\(eventId)'; "
            sqlQuery += "DELETE FROM Reminder WHERE EventID = '\(eventId)'; "
            sqlQuery += "DELETE FROM Speaker WHERE EventID = '\(eventId)'; "
            sqlQuery += "DELETE FROM Agenda WHERE EventID = '\(eventId)'; "
            sqlQuery += "DELETE FROM MySchedule WHERE EventID = '\(eventId)'; "
            sqlQuery += "DELETE FROM Map WHERE EventID = '\(eventId)'; "
            sqlQuery += "DELETE FROM Feedback WHERE EventID = '\(eventId)'; "
            sqlQuery += "DELETE FROM ActivityFeedback WHERE EventID = '\(eventId)'; "
            sqlQuery += "DELETE FROM Gallery WHERE EventID = '\(eventId)'; "
            sqlQuery += "DELETE FROM Website WHERE EventID = '\(eventId)'; "
            sqlQuery += "DELETE FROM Sponsors WHERE EventID = '\(eventId)'; "
            sqlQuery += "DELETE FROM Email WHERE EventID = '\(eventId)'; "
            sqlQuery += "DELETE FROM Documents WHERE EventID = '\(eventId)'; "
            sqlQuery += "DELETE FROM EmergencyInfo WHERE EventID = '\(eventId)'; "
            sqlQuery += "DELETE FROM AttendeeProfile WHERE EventID = '\(eventId)'; "
            sqlQuery += "DELETE FROM Wifi WHERE EventID = '\(eventId)'; "
            sqlQuery += "DELETE FROM AgendaSpeakerRelation WHERE EventID = '\(eventId)'; "
            sqlQuery += "DELETE FROM ChatList WHERE EventID = '\(eventId)'; "
            sqlQuery += "DELETE FROM ChatHistory WHERE EventID = '\(eventId)'; "
            sqlQuery += "DELETE FROM PollSpeakerActivity WHERE EventID = '\(eventId)'; "
            sqlQuery += "DELETE FROM SpeakerPollQuestions WHERE EventID = '\(eventId)'; "
            sqlQuery += "DELETE FROM ActivityFeedsLikes  WHERE EventID = '\(eventId)'; "
            sqlQuery += "DELETE FROM ActivityFeedsComments WHERE EventID = '\(eventId)'; "
            sqlQuery += "DELETE FROM ActivityFeeds WHERE EventID = '\(eventId)'; "
            sqlQuery += "DELETE FROM Notifications WHERE EventID = '\(eventId)'; "
            sqlQuery += "DELETE FROM PollQuestions WHERE EventID = '\(eventId)'; "
            sqlQuery += "DELETE FROM PollActivities WHERE EventID = '\(eventId)'; "
            sqlQuery += "DELETE FROM QuestionActivities WHERE EventID = '\(eventId)'; "
            sqlQuery += "DELETE FROM QAQuestions WHERE EventID = '\(eventId)'; "

            if !database.executeStatements(sqlQuery) {
                // print(database.lastError(), database.lastErrorMessage())
            }

            database.commit()
            database.close()
        }
    }


    // MARK: - Application Theme methods
    
    func insertApplicationThemeDataIntoDB(themeDict: NSDictionary) {
        
       // if openDatabase() {
            
            do {
                let eventId = EventData.sharedInstance.eventId
                
                //Header
                let headerColor = self.isNullString(str: themeDict.value(forKey: "Header_Color") as Any)
                let isHeaderImage = themeDict.value(forKey:"IsHeaderImage")
                let headerImgUrl = self.appendImagePath(path: themeDict.value(forKey: "Header_ImgPath") as Any)
                let headerTextColor = self.isNullString(str: themeDict.value(forKey: "HeaderText_Color") as Any)
                let headerFontName = self.isNullString(str: themeDict.value(forKey: "Header_FontName") as Any)
                let headerFontStyle = self.isNullString(str: themeDict.value(forKey: "Header_FontStyle") as Any).replacingOccurrences(of: " ", with: "")
                let headerFontSize = self.isNullString(str: themeDict.value(forKey: "Header_FontSize") as Any)
                
                //Background
                let isBgImage = themeDict.value(forKey: "IsBackgroundImage")
                let bgImageUrl = self.appendImagePath(path: themeDict.value(forKey: "Background_ImgPath") as Any)
                let bgColor = self.isNullString(str: themeDict.value(forKey: "Background_Color") as Any)
                
                //Side Menu
                let bgMenuColor = self.isNullString(str: themeDict.value(forKey: "SideMenu_Color") as Any)
                let menuTextColor = self.isNullString(str: themeDict.value(forKey: "SideMenu_TextColor") as Any)
                let menuFontName = self.isNullString(str: themeDict.value(forKey: "SideMenu_FontName") as Any)
                let menuFontStyle = self.isNullString(str: themeDict.value(forKey: "SideMenu_FontStyle") as Any).replacingOccurrences(of: " ", with: "") // trimmingCharacters(in: .whitespaces)
                let menuFontSize = self.isNullString(str: themeDict.value(forKey: "SideMenu_FontSize") as Any)
                let islogoIcon = themeDict.value(forKey: "IsLogoIconImage")
                let logoIconTextColor = self.isNullString(str: themeDict.value(forKey: "LogoText_Color") as Any)
                let logoText = self.isNullString(str: themeDict.value(forKey: "LogoText") as Any)

                let logo_ImgPath = self.appendImagePath(path: themeDict.value(forKey: "Logo_ImgPath")  as Any)
                let logoIcon_ImgPath = self.appendImagePath(path: themeDict.value(forKey: "LogoIcon_ImgPath") as Any)
                let iconTextFontName = self.isNullString(str: themeDict.value(forKey: "LogoText_FontName") as Any)
                let iconTextFontStyle = self.isNullString(str: themeDict.value(forKey: "LogoText_FontStyle") as Any).replacingOccurrences(of: " ", with: "")
                let iconTextFontSize = self.isNullString(str: themeDict.value(forKey: "LogoText_FontSize") as Any)

                try database.executeUpdate("INSERT OR REPLACE INTO ApplicationTheme (EventID, IsHeaderImage , HeaderImageUrl , HeaderColor , HeaderTextColor, HeaderFontName, HeaderFontStyle, HeaderFontSize, IsBackgroundImage , BackgroundImageUrl , BackgroundColor , IsLogoIconImage ,LogoText, LogoIconImageUrl , LogoImageUrl , LogoIconTextColor, IconTextFontName , IconTextFontStyle , IconTextFontSize, SideMenuColour , SideMenuTextColor, SideMenuFontName,SideMenuFontStyle, SideMenuFontSize) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", values: [eventId, isHeaderImage ?? 0, headerImgUrl, headerColor, headerTextColor ,headerFontName ,headerFontStyle , headerFontSize , isBgImage ?? 0 , bgImageUrl, bgColor, islogoIcon ?? 0 ,logoText, logoIcon_ImgPath, logo_ImgPath, logoIconTextColor ,iconTextFontName, iconTextFontStyle, iconTextFontSize,  bgMenuColor , menuTextColor , menuFontName, menuFontStyle , menuFontSize])
            }
                
            catch {
                print("error = \(error)")
            }
            //}
            
          // database.close()
        //}
    }
 
    
    func fetchAppThemeDataFromDB() -> AppTheme {
        
        let appTheme = AppTheme.sharedInstance
        //Clear all setting
        appTheme.setDefaultSetting()
        
        if openDatabase() {
            
            let querySQL = "Select * from ApplicationTheme where EventID = ?"
            let results:FMResultSet? = database.executeQuery(querySQL, withArgumentsIn: [EventData.sharedInstance.eventId])
            
            while (results?.next())! {
                
                
                appTheme.isHeaderColor = !((results?.bool(forColumn: "IsHeaderImage"))!)
                appTheme.headerImage = (results?.string(forColumn: "HeaderImageUrl"))!

                let headerColor = (results?.isNullForColumnName(columnName: "HeaderColor"))!
                if !headerColor {
                    appTheme.headerColor = UIColor().HexToColor(hexString: (results?.string(forColumn: "HeaderColor")!)!, alpha: 1.0)
                }

                let headerTextColor = (results?.isNullForColumnName(columnName: "HeaderTextColor"))!
                if !headerTextColor {
                    appTheme.headerTextColor = UIColor().HexToColor(hexString: (results?.string(forColumn: "HeaderTextColor")!)!, alpha: 1.0)
                }
                if (results?.string(forColumn: "HeaderFontName"))! != "" {
                    appTheme.headerFontName = (results?.string(forColumn: "HeaderFontName"))!
                }
                if (results?.string(forColumn: "HeaderFontStyle"))! != "" {
                    appTheme.headerFontStyle = (results?.string(forColumn: "HeaderFontStyle"))!
                }
                let headerFontSize = Int((results?.int(forColumn: "HeaderFontSize"))!)
                if headerFontSize != 0 {
                    appTheme.headerFontSize = headerFontSize
                }
                appTheme.isbackgroundColor = !((results?.bool(forColumn: "IsBackgroundImage"))!)
                appTheme.backgroundImage = (results?.string(forColumn: "BackgroundImageUrl"))!

                if appTheme.isbackgroundColor == true  {
                    appTheme.backgroundColor = UIColor().HexToColor(hexString: (results?.string(forColumn: "BackgroundColor")!)!, alpha: 1.0)
                }
                
                appTheme.isEventLogoIcon = (results?.bool(forColumn: "IsLogoIconImage"))!
                appTheme.eventIconImage = (results?.string(forColumn: "LogoIconImageUrl"))!
                appTheme.eventLogoImage = (results?.string(forColumn: "LogoImageUrl"))!
                appTheme.logoText = (results?.string(forColumn: "LogoText"))!
                
                appTheme.eventNameTextColor = UIColor().HexToColor(hexString: (results?.string(forColumn: "LogoIconTextColor")!)!, alpha: 1.0)
                if (results?.string(forColumn: "IconTextFontName"))! != "" {
                    appTheme.iconTextFontName = (results?.string(forColumn: "IconTextFontName"))!
                }
                if (results?.string(forColumn: "IconTextFontStyle"))! != "" {
                    appTheme.iconTextFontStyle = (results?.string(forColumn: "IconTextFontStyle"))!
                }
                let iconFontSize = Int((results?.int(forColumn: "IconTextFontSize"))!)
                if iconFontSize != 0 {
                    appTheme.iconTextFontSize = iconFontSize
                }

                let mSideBackgroundColor = results?.string(forColumn: "SideMenuColour")!
                if mSideBackgroundColor != "" {
                    appTheme.menuBackgroundColor = UIColor().HexToColor(hexString: (results?.string(forColumn: "SideMenuColour")!)!, alpha: 1.0)
                }
                
                let mSideMenuTextColor = results?.string(forColumn: "SideMenuTextColor")!
                if mSideMenuTextColor != "" {
                    appTheme.menuTextColor = UIColor().HexToColor(hexString: (results?.string(forColumn: "SideMenuTextColor")!)!, alpha: 1.0)
                }
                let mFontSize = Int((results?.int(forColumn: "SideMenuFontSize"))!)
                if mFontSize != 0 {
                    appTheme.menuFontSize = mFontSize
                }
                if (results?.string(forColumn: "SideMenuFontName"))! != "" {
                    appTheme.menuFontName = (results?.string(forColumn: "SideMenuFontName"))!
                }
                if (results?.string(forColumn: "SideMenuFontStyle"))! != "" {
                    appTheme.menuFontStyle = (results?.string(forColumn: "SideMenuFontStyle"))!
                }
            }
            database.close()
        }
        return appTheme
    }

    // MARK: - Module methods
    
    func insertApplicationModulesDataIntoDB(responce: AnyObject) {
        do {
            let eventId = EventData.sharedInstance.eventId

            //  Update isdeleted flag for all module
            try database.executeUpdate("UPDATE Module SET isDeleted = ? WHERE EventID = ?", values: [true, eventId])

            if (responce.value(forKey:"ModuleRelated") as? NSNull) == nil {

                for item in responce.value(forKey:"ModuleRelated") as! NSArray {
                    if (item as? NSNull) == nil {
                        let  dict = item as! NSDictionary
                        let mId = dict.value(forKey: "ModuleID") as! String
                        let name = self.isNullString(str: dict.value(forKey: "ModuleName") as Any)
                        let isUserRelated = false
                        let isCustom = dict.value(forKey: "IsCustom")
                        let content = self.isNullString(str: dict.value(forKey: "ModuleDescription") as Any)
                        let isDeleted = false

                        let sIconUrl = self.appendImagePath(path: dict.value(forKey: "SIconUrl") as Any)
                        let lIconUrl = self.appendImagePath(path: dict.value(forKey: "LIconUrl") as Any)

                        let sequence = dict.value(forKey:"OrderSequence")

                        try database.executeUpdate("insert or replace into Module (EventID, ModuleID, ModuleName, LIconUrl, SIconUrl , isUserRelated, isCustomModule, Content, isDeleted, OrderSequence ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", values: [eventId, mId , name  , lIconUrl ,sIconUrl ,isUserRelated, isCustom ?? false, content , isDeleted, sequence ?? 0 ])
                        //   query = query + "insert or replace into Module EventID = '\(eventId )', ModuleID = '\(mId )', ModuleName = '\(name )', LIconUrl = '\(lIconUrl )', SIconUrl = '\(sIconUrl )', isUserRelated = '\(isUserRelated )', isCustomModule = '\(isCustom )', Content = '\(content )', isDeleted = '\(isDeleted )', OrderSequence = '\(String(describing: sequence ))'; "
                    }
                }
            }

            if (responce.value(forKey:"UserRelated") as? NSNull) == nil {

                for item in responce.value(forKey:"UserRelated") as! NSArray {

                    if (item as? NSNull) == nil {

                        let  dict = item as! NSDictionary
                        let mId = dict.value(forKey: "ModuleID") as! String
                        let name = dict.value(forKey:"ModuleName") as! String
                        let isUserRelated = true
                        let isDeleted = false
                        let sIconUrl = self.appendImagePath(path: dict.value(forKey: "SIconUrl") as Any)
                        let lIconUrl = self.appendImagePath(path: dict.value(forKey: "LIconUrl") as Any)
                        let isCustom = dict.value(forKey:"IsCustom")
                        let content = self.isNullString(str: dict.value(forKey: "ModuleDescription") as Any)
                        let sequence = dict.value(forKey:"OrderSequence")

                        try database.executeUpdate("insert or replace into Module (EventID, ModuleID, ModuleName, LIconUrl, SIconUrl , isUserRelated, isCustomModule, Content , isDeleted ,OrderSequence) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", values: [eventId, mId , name  , lIconUrl ,sIconUrl , isUserRelated, isCustom ?? false , content, isDeleted, sequence ?? 0 ])
                    }
                }
            }
        }
        catch {
            print("error = \(error)")
        }
    }
    
    func fetchModulesDataFromDB() -> NSArray {
        
        var array = [Modules]()
        
        if openDatabase() {
            
            let querySQL = "Select * from Module where EventID = ? AND isDeleted = ? ORDER BY OrderSequence ASC"
            let results:FMResultSet? = database.executeQuery(querySQL, withArgumentsIn: [EventData.sharedInstance.eventId,false])
            
            while results?.next() == true {
                
                  let model = Modules()
                model.index = Int((results?.int(forColumn: "ID"))!)
                model.moduleId = (results?.string(forColumn: "ModuleID"))!
                model.name = (results?.string(forColumn: "ModuleName"))!
                model.sIconUrl = (results?.string(forColumn: "SIconUrl"))!
                model.lIconUrl = (results?.string(forColumn: "LIconUrl"))!
                model.isUserRelated = (results?.bool(forColumn: "isUserRelated"))!
                model.isCustomModule = (results?.bool(forColumn: "isCustomModule"))!
                model.moduleContent = (results?.string(forColumn: "Content"))!
                model.moduleSequence = Int((results?.int(forColumn: "OrderSequence"))!)

                array.append(model)
            }
            
            do {
                //Delete
                try database.executeUpdate("DELETE from Module Where EventID = ? AND isDeleted = ?", values: [EventData.sharedInstance.eventId,true])
            }
            catch {
            }
            
            database.close()
        }
        return array as NSArray
    }

    func fetchModuleOrderFromDB(moduleId: String) -> Int {

        var index : Int = 0
        if openDatabase() {

            let querySQL = "Select OrderSequence from Module where EventID = ? AND ModuleID = ? ORDER BY OrderSequence ASC"
            let results:FMResultSet? = database.executeQuery(querySQL, withArgumentsIn: [EventData.sharedInstance.eventId,moduleId])

            while results?.next() == true {

                let model = Modules()
                index = Int((results?.int(forColumn: "OrderSequence"))!)
            }
            database.close()
        }
        return index
    }

    func fetchModuleOrderFromDB(moduleName: String) -> Int {

        var index : Int = 0
        if openDatabase() {

            let querySQL = "Select OrderSequence from Module where EventID = ? AND ModuleName = ? ORDER BY OrderSequence ASC"
            let results:FMResultSet? = database.executeQuery(querySQL, withArgumentsIn: [EventData.sharedInstance.eventId,moduleName])

            while results?.next() == true {

                let model = Modules()
                index = Int((results?.int(forColumn: "OrderSequence"))!)
            }
            database.close()
        }
        return index
    }

    // MARK: - Profile methods
    
    func saveProfileDataIntoDB(response: AnyObject) {
        
       // if openDatabase() {
            let eventId = EventData.sharedInstance.eventId
            
            if response is NSDictionary {
                
                do {
                    let  dict = response as! NSDictionary
                    let id = dict.value(forKey: "AttendeeId")!
                    let name = self.isNullString(str: dict.value(forKey: "Name") as Any)
                    let code = self.isNullString(str: dict.value(forKey: "AttendeeCode") as Any)
                    let email = self.isNullString(str: dict.value(forKey: "EmailAddress") as Any)
                    let mNumber = self.isNullString(str: dict.value(forKey: "Mobile") as Any)
                    let qr_code = self.appendImagePath(path: dict.value(forKey: "QR_ImgPath") as Any)
                    let group = self.isNullString(str: dict.value(forKey: "Group") as Any)
                    let desc = self.isNullString(str: dict.value(forKey: "Department") as Any)
                    let iconurl = self.appendImagePath(path: dict.value(forKey: "ImgPath") as Any)
                    let isvisible = dict.value(forKey: "IsVisible")!
                    let isDND = dict.value(forKey: "IsDND")!
                    let isSpeaker = dict.value(forKey: "IsSpeaker")!
                    let speakerId = dict.value(forKey: "SpeakerId")!

                    try database.executeUpdate("INSERT OR REPLACE INTO AttendeeProfile (EventID, AttendeeId, AttendeeName, AttendeeCode, AttendeeEmail, ContactNo, ProfileSetting, QRCode, GroupsName, Department, ImgPath, DNDSetting, isSpeaker, SpeakerId) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", values: [eventId, id, name , code, email, mNumber, isvisible, qr_code , group , desc , iconurl,isDND,isSpeaker, speakerId])

                } catch {
                    print("error = \(error)")
                }
            }
       // }
       // database.close()
    }
    
    func fetchProfileDataFromDB() -> AttendeeInfo {
        
        let model = AttendeeInfo.sharedInstance
        
        if openDatabase() {
            
            let querySQL = "Select * from AttendeeProfile where EventID = ? AND AttendeeId = ?"
            let results:FMResultSet? = database.executeQuery(querySQL, withArgumentsIn: [EventData.sharedInstance.eventId, EventData.sharedInstance.attendeeId])
            
            while results?.next() == true {
                
                model.attendeeId = (results?.string(forColumn: "AttendeeId"))!
                model.eventId = (results?.string(forColumn: "EventID"))!
                model.attendeeName = (results?.string(forColumn: "AttendeeName"))!
                model.group = (results?.string(forColumn: "GroupsName"))!
                model.designation = results?.string(forColumn: "Department")
                model.iconUrl = (results?.string(forColumn: "ImgPath"))!
                model.code = (results?.string(forColumn: "AttendeeCode"))!
                model.email = (results?.string(forColumn: "AttendeeEmail"))!
                model.number = (results?.string(forColumn: "ContactNo"))!
                model.isvisible = (results?.bool(forColumn:"ProfileSetting"))!
                model.qr_code = (results?.string(forColumn: "QRCode"))!
                model.isDND = (results?.bool(forColumn:"DNDSetting"))!
                model.isSpeaker = (results?.bool(forColumn:"isSpeaker"))!
                model.speakerId = (results?.string(forColumn: "SpeakerId"))!
            }
            database.close()
        }
        return model
    }
    
    func updateUserProfileDataIntoDB(setting: Bool, dnd : Bool, profileImgPath : String) {
        
        if openDatabase() {
            let eventId = EventData.sharedInstance.eventId
            
            do {
                try database.executeUpdate("UPDATE AttendeeProfile SET ProfileSetting = ?, DNDSetting = ? , ImgPath = ? WHERE EventID = ? AND AttendeeId = ?", values: [setting, dnd, profileImgPath, eventId,EventData.sharedInstance.attendeeId])
                
            } catch {
                print("error = \(error)")
            }
        }
        database.close()
    }


    // MARK: - Map methods
    
    func saveMapDataIntoDB(response: AnyObject) {
        
        if openDatabase() {
            let eventId = EventData.sharedInstance.eventId
            
            //Delete local data which is deleted from admin
            do {
                try database.executeUpdate("DELETE FROM Map WHERE EventID = ?", values: [eventId])
                
            } catch {
                print("error = \(error)")
            }

            for item in response as! NSArray {
                
                do {
                    let  dict = item as! NSDictionary
                    let id = self.isNullString(str: dict.value(forKey: "ID") as Any)
                    let name = self.isNullString(str: dict.value(forKey: "Location") as Any)
                    let image = self.appendImagePath(path: dict.value(forKey: "ImagePath") as Any)
                    
                    try database.executeUpdate("INSERT OR REPLACE INTO Map (EventID, Id, Name, FloorPlanImage) VALUES (?, ?, ?, ?)", values: [eventId, id, name, image])
                    
                } catch {
                    print("error = \(error)")
                }
            }
        }
        
        database.close()
    }
    
    func fetchMapDataFromDB() -> NSArray {
        var array = [Map]()
        
        if openDatabase() {
            
            let querySQL = "Select * from Map where EventID = ?"
            let results:FMResultSet? = database.executeQuery(querySQL, withArgumentsIn: [EventData.sharedInstance.eventId, false])
            
            while results?.next() == true {

                let model = Map()
                model.id = results?.string(forColumn: "Id")
                model.name = results?.string(forColumn: "Name")
                model.iconUrl = results?.string(forColumn: "FloorPlanImage")
                
                array.append(model)
            }
            database.close()
        }
        return array as NSArray
    }
    
    // MARK: - Sponsors methods

    func saveSponsorsDataIntoDB(responce: AnyObject) {
        
        if openDatabase() {
            let eventId = EventData.sharedInstance.eventId
            //Delete local data which is deleted from admin
            do {
                try database.executeUpdate("DELETE FROM Sponsors WHERE EventID = ?", values: [eventId])
                
            } catch {
                print("error = \(error)")
            }

            for item in responce as! NSArray {
                
                do {
                    let  dict = item as! NSDictionary
                    let name = self.isNullString(str: dict.value(forKey: "Name") as Any)
                    let sponsorId = self.isNullString(str: dict.value(forKey: "SponsorID") as Any)
                    let website = self.isNullString(str: dict.value(forKey: "Website") as Any)
                    let descInfo = self.isNullString(str: dict.value(forKey: "Description") as Any)
                    let address = self.isNullString(str: dict.value(forKey: "Address") as Any)
                    let email = self.isNullString(str: dict.value(forKey: "Email") as Any)
                    let contactNo = self.isNullString(str: dict.value(forKey: "ContactNo") as Any)
                    let iconurl = self.appendImagePath(path: dict.value(forKey: "ImgPath") as Any)
                    try database.executeUpdate("INSERT OR REPLACE INTO Sponsors (EventId, id, Name, Website, Description, Address, Email, ContactNo, IconUrl) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)", values: [eventId, sponsorId , name, website, descInfo, address, email, contactNo, iconurl])
                    
                } catch {
                    print("error = \(error)")
                }
            }
        }
        
        database.close()
    }
    
    func fetchSponsorsDataFromDB() -> NSArray {
        var array = [Sponsors]()
        
        if openDatabase() {
            
            let querySQL = "Select * from Sponsors where EventID = ? Order by lower(Name)"
            let results:FMResultSet? = database.executeQuery(querySQL, withArgumentsIn: [EventData.sharedInstance.eventId, false])
            
            while results?.next() == true {
                
                let model = Sponsors()
                model.sponsorId = (results?.string(forColumn: "id"))!
                model.name = (results?.string(forColumn: "Name"))!
                model.website = (results?.string(forColumn: "Website"))!
                model.address = (results?.string(forColumn: "Address"))!
                model.descInfo = (results?.string(forColumn: "Description"))!
                model.email = (results?.string(forColumn: "Email"))!
                model.contactNo = (results?.string(forColumn: "ContactNo"))!
                model.iconUrl = (results?.string(forColumn: "IconUrl"))!

                array.append(model)
            }
            database.close()
        }
        return array as NSArray
    }

    // MARK: - Activity Feedback methods
    
    func saveActivityFeedbackDataIntoDB(responce: AnyObject) {
        print("Activity Feedback : ",responce)
        
        if openDatabase() {
            let eventId = EventData.sharedInstance.eventId
            
            //Delete local data which is deleted from admin
//
            do {
                if responce is NSArray {
                    var sqlQuery = ""
                    var activityId = ""
                    for item in responce as! NSArray {
                        let  dict = item as! NSDictionary
                        activityId = self.isNullString(str: dict.value(forKey: "ActivityId") as Any)
                        let questionId = self.isNullString(str: dict.value(forKey: "QuestionID") as Any)
                        let question = self.isNullString(str: dict.value(forKey: "Question") as Any)
                        let questionType = self.isNullString(str: dict.value(forKey: "QuestionType") as Any)
                        var optionData = "[]"
                        if (dict.value(forKey: "OptionArray") as? NSNull) == nil {
                            optionData = convertDataToString(data: dict.value(forKey: "OptionArray") as AnyObject) as! String
                        }

                        let createdDate = self.isNullString(str: dict.value(forKey: "CreatedDate") as Any)

                        sqlQuery += "INSERT OR REPLACE INTO ActivityFeedback (EventID, ActivityId, QuestionId, Question, OptionArray, QuestionType, CreatedDate) VALUES ('\(eventId)', '\(activityId)', '\(questionId)', \"\(question)\", '\(optionData)','\(questionType)','\(createdDate)');"
                        
                        //  try database.executeUpdate("INSERT OR REPLACE INTO ActivityFeedback (EventID,ActivityId, QuestionId, Question, OptionArray, QuestionType) VALUES (?, ?, ?, ?, ?, ?)", values: [eventId,activityId, id , question , optionData  , questionType ?? false])
                    }
                    
                    //Delete data
                    try database.executeUpdate("DELETE FROM ActivityFeedback WHERE EventID = ? AND ActivityId = ?", values: [eventId, activityId])
                    
                    if !database.executeStatements(sqlQuery) {
                       // print(database.lastError(), database.lastErrorMessage())
                    }
                }
            }catch {
                print("error = \(error)")
            }
        }
        
        database.close()
    }
    
    func fetchActivityFeedbackDataFromDB(activityId : String) -> NSArray {
        
        var array = [FeedbackModel]()
        
        if openDatabase() {
            
            let querySQL = "Select * from ActivityFeedback where EventID = ? AND ActivityId = ? Order by CreatedDate"
            let results:FMResultSet? = database.executeQuery(querySQL, withArgumentsIn: [EventData.sharedInstance.eventId, activityId])
            
            while results?.next() == true {
                
                let model = FeedbackModel()
                model.activityId = results?.string(forColumn: "ActivityId")
                model.eventId = results?.string(forColumn: "EventID")
                model.questionId = results?.string(forColumn: "QuestionId")
                model.questionText = results?.string(forColumn: "Question")
                let str = results?.string(forColumn: "OptionArray")
                let dict = convertToJsonData(text: str!)
                if ((dict as? Array<Any>) != nil) {
                    model.optionsArr = dict as! Array<Any>
                }
                model.questionType = results?.string(forColumn: "QuestionType")
                
                array.append(model)
            }
            database.close()
        }
        return array as NSArray
    }
    
    func deleteActivityFeedbackDataFromDB(activityId : String) {
        if openDatabase() {
            //Delete local data which is deleted from admin
            do {
                try database.executeUpdate("DELETE FROM ActivityFeedback WHERE EventID = ? AND ActivityId = ?", values: [EventData.sharedInstance.eventId, activityId])
                
            } catch {
                print("error = \(error)")
            }
        }
        database.close()
    }
    

    // MARK: - Feedback methods

    func saveFeedbackDataIntoDB(responce: AnyObject) {
        
        if openDatabase() {
            let eventId = EventData.sharedInstance.eventId
            
            //Delete local data which is deleted from admin
            do {
                try database.executeUpdate("DELETE FROM Feedback WHERE EventID = ?", values: [eventId, true])
                
            } catch {
                print("error = \(error)")
            }
            
            for item in responce as! NSArray {
                
                do {
                    let  dict = item as! NSDictionary
                    let id = self.isNullString(str: dict.value(forKey: "QuestionID") as Any)
                    let question = self.isNullString(str: dict.value(forKey: "Question") as Any)
                    let questionType = self.isNullString(str: dict.value(forKey: "QuestionType") as Any)
                    var optionData = "[]"
                    if (dict.value(forKey: "OptionArray") as? NSNull) == nil {
                        optionData = convertDataToString(data: dict.value(forKey: "OptionArray") as AnyObject) as! String
                    }

                    //let optionData = dict.value(forKey: "OptionArray")

                    try database.executeUpdate("INSERT OR REPLACE INTO Feedback (EventID, QuestionId, Question, OptionArray, QuestionType) VALUES (?, ?, ?, ?, ?)", values: [eventId, id , question , optionData  , questionType])
                    
                } catch {
                    print("error = \(error)")
                }
            }
        }
        database.close()
    }

    func fetchFeedbackDataFromDB() -> NSArray {
        
        var array = [FeedbackModel]()
        
        if openDatabase() {
            
            let querySQL = "Select * from Feedback where EventID = ?"
            let results:FMResultSet? = database.executeQuery(querySQL, withArgumentsIn: [EventData.sharedInstance.eventId, false])
            
            while results?.next() == true {
                
                let model = FeedbackModel()
                model.questionId = results?.string(forColumn: "QuestionId")
                model.questionText = results?.string(forColumn: "Question")
                let str = results?.string(forColumn: "OptionArray")
                let dict = convertToJsonData(text: str!)
                if ((dict as? Array<Any>) != nil) {
                    model.optionsArr = dict as! Array<Any>
                }
                model.questionType = results?.string(forColumn: "QuestionType")

                array.append(model)
            }
            database.close()
        }
        return array as NSArray
    }
    
    // MARK: - Documents methods
    
    func saveDocumentsDataIntoDB(response: AnyObject) {
        
        if openDatabase() {
            let eventId = EventData.sharedInstance.eventId

            //Delete local data which is deleted from admin
            do {
                try database.executeUpdate("DELETE FROM Documents WHERE EventID = ?", values: [eventId])
                
            } catch {
                print("error = \(error)")
            }
            
            for item in response as! NSArray {
                
                do {
                    let  dict = item as! NSDictionary
                    let docId = self.isNullString(str: dict.value(forKey: "DocId") as Any)
                    let title = self.isNullString(str: dict.value(forKey: "Title") as Any)
                    let desc = self.isNullString(str: dict.value(forKey: "Description") as Any)
                    let sDate = self.isNullString(str: dict.value(forKey: "FromDateTime") as Any)
                    let eDate = self.isNullString(str: dict.value(forKey: "ExpiryDatetime") as Any)
                    let url = self.appendImagePath(path: dict.value(forKey: "UrlPath") as Any)

                    try database.executeUpdate("INSERT OR REPLACE INTO Documents (EventID, DocId, Title, UrlPath, Description,StartDate, EndDate ) VALUES (?, ?, ?, ?, ?, ?, ?)", values: [eventId, docId ,title , url, desc, sDate, eDate])
                    
                } catch {
                    print("error = \(error)")
                }
            }
           
        }
        database.close()
    }
    
    func fetchDocumentsListFromDB() -> NSArray {
        
        var array = [DocumentModel]()

        if openDatabase() {
            
            let querySQL = "Select * from Documents Where EventID = ?"
            let results:FMResultSet? = database.executeQuery(querySQL, withArgumentsIn: [EventData.sharedInstance.eventId])
            
            while results?.next() == true {
                
                let model = DocumentModel()
                model.docId = results?.string(forColumn: "DocId")
                model.title = results?.string(forColumn: "Title")
                model.descStr = results?.string(forColumn: "Description")
                model.pdfUrlStr = results?.string(forColumn: "UrlPath")
                model.startDateStr = results?.string(forColumn: "StartDate")
                model.endDateStr = results?.string(forColumn: "EndDate")

                array.append(model)
            }
            database.close()
        }
        return array as NSArray
    }

    // MARK: - Emergency methods

    func saveEmergencyDataIntoDB(response: AnyObject) {
        
        if openDatabase() {
            self.database.beginTransaction()

            let eventId = EventData.sharedInstance.eventId
            
            //Delete local data which is deleted from admin
            do {
                try database.executeUpdate("DELETE FROM EmergencyInfo WHERE EventID = ?", values: [eventId])
                
            } catch {
                print("error = \(error)")
            }
            var sqlQuery = ""

            for item in response as! NSArray {
                
               // do {
                    let  dict = item as! NSDictionary
                    let title = self.isNullString(str: dict.value(forKey: "Title") as Any)
                    let desc = self.isNullString(str: dict.value(forKey: "Description") as Any)
                    let contactNo = self.isNullString(str: dict.value(forKey: "ContactNo") as Any)
                    let address = self.isNullString(str: dict.value(forKey: "Address") as Any)
                    let email = self.isNullString(str: dict.value(forKey:"Email") as Any)
                    
                    //try database.executeUpdate("INSERT OR REPLACE INTO EmergencyInfo (EventID, Title, Description, ContactNo , Address, Email) VALUES (?, ?, ?, ?, ?, ?)", values: [eventId, title , desc , contactNo , address, email ])
                    sqlQuery += "INSERT OR REPLACE INTO EmergencyInfo (EventID, Title, Description, ContactNo , Address, Email) VALUES ('\(eventId)', \"\(title)\",'\(desc)','\(contactNo)',\"\(address)\", \"\(email)\");"

//                } catch {
//                    print("error = \(error)")
//                }
            }
            if !database.executeStatements(sqlQuery) {
                print(database.lastError(), database.lastErrorMessage())
            }

            self.database.commit()
            database.close()
        }
    }

    func fetchEmergencyDataFromDB() -> NSArray {
        
        var array = [EmergencyModel]()
        
        if openDatabase() {
            
            let querySQL = "Select * from EmergencyInfo where EventID = ?"
            let results:FMResultSet? = database.executeQuery(querySQL, withArgumentsIn: [EventData.sharedInstance.eventId])
            
            while results?.next() == true {
                
                let model = EmergencyModel()
                model.title = results?.string(forColumn: "Title")
                model.desc = results?.string(forColumn: "Description")
                model.contactNo = results?.string(forColumn: "ContactNo")
                model.address = results?.string(forColumn: "Address")
                model.email = results?.string(forColumn:"Email")
                
                array.append(model)
            }
            database.close()
        }
        return array as NSArray
    }

    // MARK: - Notification methods

    func saveNotificationDataIntoDB(response: AnyObject) {
        
        if openDatabase() {
            let eventId = EventData.sharedInstance.eventId
            
//            //Delete local data which is deleted from admin
//            do {
//                try database.executeUpdate("DELETE FROM Notifications WHERE EventID = ?", values: [eventId])
//
//            } catch {
//                print("error = \(error)")
//            }

            for item in response as! NSArray {
                
                do {
                    let  dict = item as! NSDictionary
                    let id = dict.value(forKey: "Id") as! String
                    let title = self.isNullString(str: dict.value(forKey: "Title") as Any)
                    let desc = self.isNullString(str: dict.value(forKey: "Message") as Any)
                    let date = self.isNullString(str: dict.value(forKey: "CreatedDate") as Any)
                    let status = dict.value(forKey: "IsRead")
                   // print("Name : ",desc)
                   // print("Status : ",status)
                    try database.executeUpdate("INSERT OR REPLACE INTO Notifications (EventID, notiId,AttendeeId, Title, Description, CreatedDate, IsRead) VALUES (?, ?, ?, ?, ?, ?, ?)", values: [eventId, id, EventData.sharedInstance.attendeeId, title , desc , date , status ?? 0])
                    
                } catch {
                    print("error = \(error)")
                }
            }
        }
        
        database.close()
    }

    func saveBroadCastNotification(data: NSDictionary) {

        if openDatabase() {
            let eventId = EventData.sharedInstance.eventId

                do {
                    let id = data.value(forKey: "Id") as! String
                    let attendeeId = data.value(forKey: "AttendeeId") as! String
                    let title = self.isNullString(str: data.value(forKey: "Title") as Any)
                    let desc = self.isNullString(str: data.value(forKey: "Message") as Any)
                    let date = self.isNullString(str: data.value(forKey: "CreatedDate") as Any)
                    let status = data.value(forKey: "IsRead")

                    try database.executeUpdate("INSERT OR REPLACE INTO Notifications (EventID,AttendeeId, notiId, Title, Description, CreatedDate, IsRead) VALUES (?, ?, ?, ?, ?, ?, ?)", values: [eventId,attendeeId, id, title , desc , date , status ?? 0])

                } catch {
                    print("error = \(error)")
                }
        }

        database.close()
    }

    func fetchNotificationDataFromDB(limit : NSInteger, offset : NSInteger) -> NSArray {
        
        var array = [NotificationsModel]()
        
        if openDatabase() {
            
            let querySQL = "Select * from Notifications where EventID = ? AND AttendeeId = ? Order by CreatedDate DESC limit \(offset),\(limit)"
            let results:FMResultSet? = database.executeQuery(querySQL, withArgumentsIn: [EventData.sharedInstance.eventId, EventData.sharedInstance.attendeeId])
            
            while results?.next() == true {
                
                let model = NotificationsModel()
                model.id = results?.string(forColumn: "notiId")
                model.title = results?.string(forColumn: "Title")
                model.message = results?.string(forColumn: "Description")
                model.cretedDate = results?.string(forColumn: "CreatedDate")
                model.isRead = (results?.bool(forColumn:"IsRead"))!

                array.append(model)
            }
            database.close()
        }
        return array as NSArray
    }

    func fetchUnreadNotificationsCount() -> Int {

        var count : Int = 0
        if openDatabase() {
            let querySQL = "Select Count(IsRead) from Notifications Where IsRead = ? AND EventID = ? AND AttendeeId = ?"
            var results:FMResultSet!
            results = database.executeQuery(querySQL, withArgumentsIn: [0, EventData.sharedInstance.eventId,EventData.sharedInstance.attendeeId])
            while results?.next() == true {
                count = results?.object(forColumnIndex: 0) as! Int
            }
        }
        database.close()
        return count
    }

    func updateNotificationStatus() {
        if openDatabase() {

            //Delete local data which is deleted from admin
            do {
                try database.executeUpdate("Update Notifications SET IsRead = ? Where EventID = ?", values: [0, EventData.sharedInstance.eventId])
            } catch {
                print("error = \(error)")
            }

            database.close()
        }
    }

    // MARK: - WiFi methods

    func saveWifiDataIntoDB(response: AnyObject) {
        
        if openDatabase() {
            let eventId = EventData.sharedInstance.eventId

            //Delete local data which is deleted from admin
            do {
                try database.executeUpdate("DELETE FROM WiFi WHERE EventID = ?", values: [eventId])
                
            } catch {
                print("error = \(error)")
            }
            
            for item in response as! NSArray {
                
                do {
                    let  dict = item as! NSDictionary
                    let id = self.isNullString(str: dict.value(forKey: "Id") as Any)
                    let name = self.isNullString(str: dict.value(forKey: "LocationName") as Any)
                    let network = self.isNullString(str: dict.value(forKey: "Network") as Any)
                    let password = self.isNullString(str: dict.value(forKey: "Password") as Any)
                    let note = self.isNullString(str: dict.value(forKey: "Note") as Any)
                    let date = self.isNullString(str: dict.value(forKey: "CreatedDate") as Any)

                    try database.executeUpdate("INSERT OR REPLACE INTO Wifi (EventID, Id, Name, Network, Password, Note, CreatedDate) VALUES (?, ?, ?, ?, ?, ?, ?)", values: [eventId, id ,name , network , password , note, date ])
                    
                } catch {
                    print("error = \(error)")
                }
            }
        }
        
        database.close()
    }
    
    func fetchWifiDataFromDB() -> NSArray {
        
        var array = [WiFiModel]()
        
        if openDatabase() {
            
            let querySQL = "Select * from Wifi where EventID = ? Order by CreatedDate DESC"
            let results:FMResultSet? = database.executeQuery(querySQL, withArgumentsIn: [EventData.sharedInstance.eventId])
            
            while results?.next() == true {
                
                let model = WiFiModel()
                model.id = (results?.string(forColumn: "Id"))!
                model.name = (results?.string(forColumn: "Name"))!
                model.network = (results?.string(forColumn: "Network"))!
                model.password = (results?.string(forColumn: "Password"))!
                model.note = (results?.string(forColumn: "Note"))!

                array.append(model)
            }
            database.close()
        }
        return array as NSArray
    }

    
    
    // MARK: - Email methods
    
    func saveEmailDataIntoDB(response: AnyObject) {
        
        if openDatabase() {
            let eventId = EventData.sharedInstance.eventId

            //Delete local data which is deleted from admin
            do {
                try database.executeUpdate("DELETE FROM Email WHERE EventID = ?", values: [eventId])
                
            } catch {
                print("error = \(error)")
            }

            for item in response as! NSArray {
                
                do {
                    let  dict = item as! NSDictionary
                    let Eid = self.isNullString(str: dict.value(forKey: "Eid") as Any)
                    let from = self.isNullString(str: dict.value(forKey: "From") as Any)
                    let to = self.isNullString(str: dict.value(forKey: "To") as Any)
                    let date = self.isNullString(str: dict.value(forKey: "SentTime") as Any)
                   // let date = CommonModel.sharedInstance.UTCToLocalDate(date: dict.value(forKey: "SentTime") as! String)//dict.value(forKey: "SentTime")
                    let desc = self.isNullString(str: dict.value(forKey: "Content") as Any)
                    let subject = self.isNullString(str: dict.value(forKey: "Subject") as Any)
                    let attendeeId =  self.isNullString(str: dict.value(forKey: "RecepientId") as Any)
                    let attachmentContent =  self.isNullString(str: dict.value(forKey: "AttachmentContent") as Any)
                    var attachment = "[]"
                    if (dict.value(forKey: "Attachments") as? NSNull) == nil {
                        attachment = convertDataToString(data: dict.value(forKey: "Attachments") as AnyObject) as! String
                    }

                    try database.executeUpdate("INSERT OR REPLACE INTO Email (EventID, Eid, eFrom, eTo, SentTime, Content, Subject, AttachmentContent, Attachments, AttendeeId) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", values: [eventId, Eid , from , to ,date , desc , subject , attachmentContent , attachment, attendeeId ])
                    
                } catch {
                    print("error = \(error)")
                }
            }
        }
        database.close()
    }
    
    
    func fetchEmailDataFromDB() -> NSArray {
        
        var array = [EmailModel]()
        
        if openDatabase() {
            
            let querySQL = "Select * from Email where EventID = ? AND AttendeeId = ? Order by SentTime DESC"
            let results:FMResultSet? = database.executeQuery(querySQL, withArgumentsIn: [EventData.sharedInstance.eventId, EventData.sharedInstance.attendeeId])
            
            while results?.next() == true {
                
                let model = EmailModel()
                model.eId = (results?.string(forColumn:"Eid"))!
                model.content = (results?.string(forColumn:"Content"))!
                model.from = (results?.string(forColumn: "eFrom"))!
                model.to = (results?.string(forColumn: "eTo"))!
                model.date = (results?.string(forColumn: "SentTime"))!
                model.subject = (results?.string(forColumn:"Subject"))!
                model.attendeeId = (results?.string(forColumn:"AttendeeId"))!
                model.attachments = convertToJsonData(text: (results!.string(forColumn: "Attachments"))!) as! NSArray
                
                array.append(model)
            }
            database.close()
        
        }
        return array as NSArray
    }
    
    // MARK: - Chat Module methods
    func updateChatListDataFromDB() {
        if openDatabase() {

            //Update deleleted chat list data
            do {
                try database.executeUpdate("DELETE FROM ChatList WHERE EventID = ?", values: [EventData.sharedInstance.eventId])
               // try database.executeUpdate("Update ChatList set IsDeleted = \(1) WHERE EventID = ?", values: [eventId])
            } catch {
                print("error = \(error)")
            }
        }
        database.close()
    }

    func saveChatListIntoDB(response: AnyObject, isGroupChat:Int) {        
        if openDatabase() {
            database.beginTransaction()
            
            let eventId = EventData.sharedInstance.eventId
            let attendeeId = EventData.sharedInstance.attendeeId
            

            var sqlQuery = ""
            for item in response as! NSArray {
                
                let  dict = item as! NSDictionary
                
                var groupId = ""
                var fromId = ""
                var toId = ""
                var createdDateStr = ""
                var modifiedDateStr = ""
                var groupAdminId = ""
                var name = ""
                var dndSetting = 1
                var visibility = 0
                let isDeleted = 0
                var isRead = 1
               // let unreadCount = 0

                //Group chat list
                if isGroupChat == 1 {
                    groupId = dict.value(forKey: "GroupId") as! String
                    fromId = EventData.sharedInstance.attendeeId //dict.value(forKey: "GroupId") as! String
                    toId = dict.value(forKey: "GroupId") as! String
                    createdDateStr = dict.value(forKey: "CreatedDate") as! String
                    modifiedDateStr = dict.value(forKey: "LastMessageSent") as! String
                    name = self.isNullString(str: dict.value(forKey: "GroupName") as Any)
                    groupAdminId = dict.value(forKey: "CreatedBy") as! String
                    isRead = dict.value(forKey: "IsRead") as! Int
                }
                else {
                    groupId = dict.value(forKey: "AttendeeId") as! String
                    fromId = EventData.sharedInstance.attendeeId //dict.value(forKey: "AttendeeId") as! String
                    toId = dict.value(forKey: "AttendeeId") as! String
                    createdDateStr = dict.value(forKey: "CreatedDate") as! String
                    modifiedDateStr = dict.value(forKey: "LastMessageSent") as! String
                    name = self.isNullString(str: dict.value(forKey: "Name") as Any)
                    dndSetting = dict.value(forKey: "IsDND") as! Int
                    visibility = dict.value(forKey: "IsVisible") as! Int
                    isRead = dict.value(forKey: "IsRead") as! Int
                }
                
                let iconImage = self.appendImagePath(path: dict.value(forKey: "ImgPath") as Any)
                var lastMessage = ""
                if (dict.value(forKey: "LastMessage") as? NSNull) == nil {
                    lastMessage = dict.value(forKey: "LastMessage") as! String
                }
                
                sqlQuery += "INSERT OR REPLACE INTO ChatList (EventID, AttendeeId, GroupId, FromId , ToId , GroupIconUrl , LastMessage , CreatedDate , ModifiedDate , GroupCreatedBy, isGroupChat, Name, PrivacySetting, DNDSetting, IsReadList, IsDeleted) VALUES ('\(eventId)','\(attendeeId)', '\(groupId)', '\(fromId)', '\(toId)','\(iconImage)', \"\(lastMessage)\",'\(createdDateStr)', '\(modifiedDateStr)','\(groupAdminId)',\(isGroupChat),\"\(name)\",\(visibility),\(dndSetting),\(isRead),\(isDeleted));"
                //print("isRead: ",isRead)
                
            }
            
            if !database.executeStatements(sqlQuery) {
            }
        }
        
        database.commit()
        database.close()
    }

    func saveChatNotificationMessageIntoDB(response: AnyObject) {
        if openDatabase() {

            let eventId = EventData.sharedInstance.eventId
            let attendeeId = EventData.sharedInstance.attendeeId

            let  dict = response as! NSDictionary

            var groupId = ""
            var fromId = ""
            var toId = ""
            var createdDateStr = ""
            var modifiedDateStr = ""
            var groupAdminId = ""
            var name = ""
            var dndSetting = 1
            var visibility = 0
            var isDeleted = 0
            var isRead = 1
            var isGroupChat = 1
            // let unreadCount = 0

            //Group chat list
            if self.isNullString(str: dict.value(forKey: "GroupChatId") as Any) != "" {
                isGroupChat = 1
                groupId = dict.value(forKey: "GroupChatId") as! String
                fromId = dict.value(forKey: "ToId") as! String
                toId = dict.value(forKey: "GroupChatId") as! String
                createdDateStr = dict.value(forKey: "CreatedDate") as! String
                modifiedDateStr = dict.value(forKey: "CreatedDate") as! String
                name = self.isNullString(str: dict.value(forKey: "ToName") as Any)
                groupAdminId = dict.value(forKey: "CreatedBy") as! String
                isRead = dict.value(forKey: "IsRead") as! Int
            }
            else {
                isGroupChat = 0

                groupId = dict.value(forKey: "FromId") as! String
                fromId = dict.value(forKey: "ToId") as! String
                toId = dict.value(forKey: "FromId") as! String
                createdDateStr = dict.value(forKey: "CreatedDate") as! String
                modifiedDateStr = dict.value(forKey: "CreatedDate") as! String
                name = self.isNullString(str: dict.value(forKey: "FromName") as Any)
                dndSetting = dict.value(forKey: "IsDND") as! Int
                visibility = dict.value(forKey: "IsVisible") as! Int
                isRead = dict.value(forKey: "IsRead") as! Int
                isDeleted = dict.value(forKey: "ToDeleted") as! Int
            }

            let iconImage = self.appendImagePath(path: dict.value(forKey: "ToIconUrl") as Any)
            var lastMessage = ""
            if (dict.value(forKey: "Message") as? NSNull) == nil {
                lastMessage = dict.value(forKey: "Message") as! String
            }

            let sqlQuery = "INSERT OR REPLACE INTO ChatList (EventID, AttendeeId, GroupId, FromId , ToId , GroupIconUrl , LastMessage , CreatedDate , ModifiedDate , GroupCreatedBy, isGroupChat, Name, PrivacySetting, DNDSetting, IsReadList, IsDeleted) VALUES ('\(eventId)','\(attendeeId)', '\(groupId)', '\(fromId)', '\(toId)','\(iconImage)', \"\(lastMessage)\",'\(createdDateStr)', '\(modifiedDateStr)','\(groupAdminId)',\(isGroupChat),\"\(name)\",\(visibility),\(dndSetting),\(isRead),\(isDeleted));"
            database.executeUpdate(sqlQuery, withArgumentsIn:[])

            database.close()
        }
    }

    func fetchChatListDataFromDB(isGroupList : Bool) -> NSArray {
        var array = [ChatGroupModel]()

        if openDatabase() {
            
            let querySQL = "Select * from ChatList Where isGroupChat = ? AND IsDeleted = ? AND AttendeeId = ? AND EventID = ? Order by ModifiedDate DESC"
            let results:FMResultSet? = database.executeQuery(querySQL, withArgumentsIn: [isGroupList, false, EventData.sharedInstance.attendeeId, EventData.sharedInstance.eventId])
            
            while results?.next() == true {
                
                let model = ChatGroupModel()
                model.groupId = (results?.string(forColumn: "GroupId"))!
                model.fromId = (results?.string(forColumn: "FromId"))!
                model.lastMessage = (results?.string(forColumn: "LastMessage"))!
                model.groupCreatedUserId = (results?.string(forColumn: "GroupCreatedBy"))!
                model.modifiedDateStr = (results?.string(forColumn: "ModifiedDate"))!
                model.dateStr = (results?.string(forColumn: "CreatedDate"))!
                model.isGroupChat = (results?.bool(forColumn: "isGroupChat"))!
                model.name = (results?.string(forColumn: "Name"))!
                model.iconUrl = (results?.string(forColumn: "GroupIconUrl"))!
                model.dndSetting = (results?.bool(forColumn: "DNDSetting"))!
                model.visibilitySetting =  (results?.bool(forColumn: "PrivacySetting"))!
                model.listStatus =  (results?.bool(forColumn: "IsReadList"))!
                //model.unreadCount = (results?.string(forColumn: "UnreadCount"))!

                array.append(model)
            }
            database.close()
        }
        return array as NSArray
    }

//    func deleteChatHistory() {
//        if openDatabase() {
//            let eventId = EventData.sharedInstance.eventId
//            //  If fetching whole chat history then only remove previous chat
//                //Delete local chat list data
//                do {
//                    try database.executeUpdate("DELETE FROM ChatHistory WHERE GroupId = ? AND EventID = ?", values: [groupId, eventId])
//
//                } catch {
//                    print("error = \(error)")
//                }
//        }
//        database.close()
//    }

    func saveChatHistory(response: AnyObject) {
        
        if openDatabase() {
            database.beginTransaction()
            
            let eventId = EventData.sharedInstance.eventId
            let attendeeId = EventData.sharedInstance.attendeeId
            //If fetching whole chat history then only remove previous chat
//            if isChatHistory {
//                //Delete local chat list data
//                do {
//                    try database.executeUpdate("DELETE FROM ChatHistory WHERE GroupId = ? AND EventID = ?", values: [groupId, eventId])
//
//                } catch {
//                    print("error = \(error)")
//                }
//            }

            var sqlQuery = ""
            var groupId = ""

            for item in response as! NSArray {
                
                let  dict = item as! NSDictionary
                var isGroupChat = 0

                //Group history
                if (dict.value(forKey: "GroupChatId") as? NSNull) == nil  {
                    groupId = dict.value(forKey: "GroupChatId") as! String
                    isGroupChat = 1
                }
                else {
                    groupId = dict.value(forKey: "ToId") as! String
                }
                
                let chatId = dict.value(forKey: "ChatId") as! String
                let createdBy = dict.value(forKey: "CreatedBy") as! String
                let fromId = dict.value(forKey: "FromId") as! String
                let toId = dict.value(forKey: "ToId") as! String
                let createdDateStr = dict.value(forKey: "CreatedDate") as! String
                let modifiedDateStr = dict.value(forKey: "CreatedDate") as! String
                let message = self.isNullString(str: dict.value(forKey: "Message") as Any)
                let name = self.isNullString(str: dict.value(forKey: "FromName") as Any)
                let iconImage = self.appendImagePath(path: dict.value(forKey: "FromIconUrl") as Any)
                let pictureImage = self.appendImagePath(path: dict.value(forKey: "ImageUrl") as Any)
                let toName = self.isNullString(str: dict.value(forKey: "ToName") as Any)
                let toIconUrl = self.appendImagePath(path: dict.value(forKey: "ToIconUrl") as Any)
               // let isFromDeleted = dict.value(forKey: "FromDeleted") as! Int
              //  let isToDeleted = dict.value(forKey: "ToDeleted") as! Int
                let isDeleted = 0 //dict.value(forKey: "FromDeleted") as! Int
                let isRead = dict.value(forKey: "IsRead") as! Int

                var type = 0
                if (dict.value(forKey: "ImageUrl") as? NSNull) == nil {
                    type = 1
                }
                
                var fromMe = 1
                //Check message frame
                if AttendeeInfo.sharedInstance.attendeeId == toId {
                    fromMe = 0
                }
                
                sqlQuery += "INSERT OR REPLACE INTO ChatHistory (EventID,AttendeeId, GroupId, FromId, ChatMessageId, CreatedBy, ToId , CreatedDate , ModifiedDate, UserIconUrl, UserName,  ToUserName, ToIconUrl , MessageIconUrl, Message, MessageType, MessageFromMe, isGroupChat, isDeleted ,  IsRead ) VALUES ('\(eventId)','\(attendeeId)','\(groupId)', '\(fromId)', '\(chatId)', '\(createdBy)', '\(toId)','\(createdDateStr)', '\(modifiedDateStr)', \"\(iconImage)\", \"\(name)\", \"\(toName)\", \"\(toIconUrl)\", \"\(pictureImage)\", \"\(message)\", '\(type)', \(fromMe), '\(isGroupChat)', \(isDeleted),\(isRead));"
            }

//            //Update previous chat history data
//            do {
//                try database.executeUpdate("Update ChatHistory SET isDeleted = 1 Where GroupId = ? AND EventID = ?", values: [groupId, EventData.sharedInstance.eventId])
//            } catch {
//                print("error = \(error)")
//            }

            if !database.executeStatements(sqlQuery) {
            }
        }
        
        database.commit()
        database.close()
    }

    func saveChatGroupHistory(response: AnyObject) {

        if openDatabase() {
            database.beginTransaction()

            let eventId = EventData.sharedInstance.eventId
            let attendeeId = EventData.sharedInstance.attendeeId

            //If fetching whole chat history then only remove previous chat
            //            if isChatHistory {
            //                //Delete local chat list data
            //                do {
            //                    try database.executeUpdate("DELETE FROM ChatHistory WHERE GroupId = ? AND EventID = ?", values: [groupId, eventId])
            //
            //                } catch {
            //                    print("error = \(error)")
            //                }
            //            }

            var sqlQuery = ""
            var groupId = ""

            for item in response as! NSArray {

                let  dict = item as! NSDictionary
                var isGroupChat = 0

                //Group history
                if (dict.value(forKey: "GroupChatId") as? NSNull) == nil  {
                    groupId = dict.value(forKey: "GroupChatId") as! String
                    isGroupChat = 1
                }
                else {
                    groupId = dict.value(forKey: "ToId") as! String
                }

                let chatId = dict.value(forKey: "ChatId") as! String
                let createdBy = dict.value(forKey: "CreatedBy") as! String
                let fromId = dict.value(forKey: "FromId") as! String
                let toId = dict.value(forKey: "ToId") as! String
                let createdDateStr = dict.value(forKey: "CreatedDate") as! String
                let modifiedDateStr = dict.value(forKey: "CreatedDate") as! String
                let message = self.isNullString(str: dict.value(forKey: "Message") as Any)
                let name = self.isNullString(str: dict.value(forKey: "FromName") as Any)
                let iconImage = self.appendImagePath(path: dict.value(forKey: "FromIconUrl") as Any)
                let pictureImage = self.appendImagePath(path: dict.value(forKey: "ImageUrl") as Any)
                let toName = self.isNullString(str: dict.value(forKey: "ToName") as Any)
                let toIconUrl = self.appendImagePath(path: dict.value(forKey: "ToIconUrl") as Any)
                let isDeleted = 0
                let isRead = dict.value(forKey: "IsRead") as! Int

                var type = 0
                if (dict.value(forKey: "ImageUrl") as? NSNull) == nil {
                    type = 1
                }

                var fromMe = 1
                //Check message frame
                if AttendeeInfo.sharedInstance.attendeeId == toId {
                    fromMe = 0
                }

                sqlQuery += "INSERT OR REPLACE INTO ChatHistory (EventID, AttendeeId, GroupId, CreatedBy, FromId, ChatMessageId, ToId , CreatedDate , ModifiedDate, UserIconUrl, UserName,  ToUserName, ToIconUrl , MessageIconUrl, Message, MessageType, MessageFromMe, isGroupChat, isDeleted, IsRead ) VALUES ('\(eventId)','\(attendeeId)','\(groupId)','\(createdBy)', '\(fromId)', '\(chatId)', '\(toId)','\(createdDateStr)', '\(modifiedDateStr)', \"\(iconImage)\", \"\(name)\", \"\(toName)\", \"\(toIconUrl)\", \"\(pictureImage)\", \"\(message)\", '\(type)', \(fromMe), '\(isGroupChat)',\(isDeleted), \(isRead));"
            }

            //Update previous chat history data
            do {
                try database.executeUpdate("Update ChatHistory SET isDeleted = 1 Where GroupId = ? AND EventID = ?", values: [groupId, EventData.sharedInstance.eventId])
            } catch {
                print("error = \(error)")
            }

            if !database.executeStatements(sqlQuery) {
            }
        }

        database.commit()
        database.close()
    }

    func saveChatMessage(dict: NSDictionary) {
        
        if openDatabase() {
            database.beginTransaction()
            
            let eventId = EventData.sharedInstance.eventId
            let attendeeId = EventData.sharedInstance.attendeeId

            var sqlQuery = ""
            
            
            var groupId = ""
            var isGroupChat = 0
            
            //Group history
            if (dict.value(forKey: "GroupChatId") as? NSNull) == nil  {
                groupId = dict.value(forKey: "GroupChatId") as! String
                isGroupChat = 1
            }
            else {
                groupId = dict.value(forKey: "ToId") as! String
            }
            
            let chatId = dict.value(forKey: "ChatId") as! String
            let createdBy = dict.value(forKey: "CreatedBy") as! String
            let fromId = dict.value(forKey: "FromId") as! String
            let toId = dict.value(forKey: "ToId") as! String
            let createdDateStr = dict.value(forKey: "CreatedDate") as! String
            let modifiedDateStr = dict.value(forKey: "CreatedDate") as! String
            let message = self.isNullString(str: dict.value(forKey: "Message") as Any)
            let pictureImage = self.appendImagePath(path: dict.value(forKey: "ImageUrl") as Any)
            let name =  "" //self.isNullString(str: dict.value(forKey: "FromName") as Any)
            let iconImage =  "" //self.appendImagePath(path: dict.value(forKey: "FromIconUrl") as Any)
            let toName =  "" //self.isNullString(str: dict.value(forKey: "ToName") as Any)
            let toIconUrl =  "" //self.appendImagePath(path: dict.value(forKey: "ToIconUrl") as Any)
            var type = 0
            if (dict.value(forKey: "ImageUrl") as? NSNull) == nil {
                type = 1
            }
            
            var fromMe = 1
            //Check message frame
            if AttendeeInfo.sharedInstance.attendeeId == toId {
                fromMe = 0
            }
            
            sqlQuery = "INSERT OR REPLACE INTO ChatHistory (EventID, AttendeeId, GroupId,CreatedBy, FromId, ChatMessageId, ToId , CreatedDate , ModifiedDate, UserIconUrl, UserName,  ToUserName, ToIconUrl , MessageIconUrl, Message, MessageType, MessageFromMe, isGroupChat, isDeleted ) VALUES ('\(eventId)','\(attendeeId)','\(groupId)','\(createdBy)', '\(fromId)', '\(chatId)', '\(toId)','\(createdDateStr)', '\(modifiedDateStr)', \"\(iconImage)\", \"\(name)\", \"\(toName)\", \"\(toIconUrl)\", \"\(pictureImage)\", \"\(message)\", '\(type)', \(fromMe), '\(isGroupChat)',0);"
            
            
            
            if !database.executeStatements(sqlQuery) {
               // print(database.lastError(), database.lastErrorMessage())
            }
        }
        
        database.commit()
        database.close()
    }
    
   /* func fetchChatMessages(chatId: String, isGroupChat : Bool, lastMessageTime :String) -> UUMessageFrame {
        
        let messageFrame = UUMessageFrame()

        if openDatabase() {
            
            let querySQL = "Select * from ChatHistory Where ChatMessageId = ? AND isDeleted = ? AND EventID = ? Order by CreatedDate ASC"
            let results:FMResultSet? = database.executeQuery(querySQL, withArgumentsIn: [chatId, 0, EventData.sharedInstance.eventId])

            while results?.next() == true {
                
                let message = UUMessage()
                message.chatId = (results?.string(forColumn: "GroupId"))!
                message.strId = (results?.string(forColumn: "FromId"))!
                message.strName = (results?.string(forColumn: "UserName"))!
                message.strIcon = (results?.string(forColumn: "UserIconUrl"))!
                message.toUserName = (results?.string(forColumn: "ToUserName"))!
                message.toUserIcon = (results?.string(forColumn: "ToIconUrl"))!
                
                message.pictureString = (results?.string(forColumn: "MessageIconUrl"))!
                message.strTime = message.changeTheDateString((results?.string(forColumn: "CreatedDate"))!)
                message.messageTime = message.changeTheTime((results?.string(forColumn: "CreatedDate"))!)
                message.messageDate = (results?.string(forColumn: "CreatedDate"))!
                let type = Int((results?.string(forColumn:"MessageType"))!)
                
                message.type = message.setMessageType(type!)
                message.strContent = (CryptLib.sharedManager() as AnyObject).decryptCipherText(with: (results?.string(forColumn: "Message"))!)
                
                message.minuteOffSetStart(lastMessageTime, end: message.messageDate)
                messageFrame.showTime = message.showDateLabel
                messageFrame.showName = isGroupChat
                messageFrame.message = message
                
                //Check message frame
                if AttendeeInfo.sharedInstance.attendeeId == message.strId {
                    message.from = MessageFrom(rawValue: 0)!
                }
                else {
                    message.from = MessageFrom(rawValue: 1)!
                }
                messageFrame.message = message
            }
            database.close()
        }
        return messageFrame
    } */
    
    func fetchChatHistoryMessages(groupId: String,fromId: String, isGroupChat : Bool, lastFetchTime : String ) -> NSArray {
        var array:[UUMessageFrame] = []

        var previousTime : String!

        if openDatabase() {
            var results:FMResultSet!
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
            let currentTime = dateFormatter.string(from: Date())

            if isGroupChat == false {
                if lastFetchTime == "All" {
                    let querySQL = "Select * from ChatHistory Where ((FromId = ? AND ToId = ?) OR (FromId = ? AND ToId = ?)) AND isGroupChat = ? AND isDeleted = ? AND EventID = ? AND AttendeeId = ? Order by CreatedDate ASC"
                    results = database.executeQuery(querySQL, withArgumentsIn: [fromId, groupId, groupId, fromId, isGroupChat, 0, EventData.sharedInstance.eventId,EventData.sharedInstance.attendeeId])

//                    let querySQL = "Select * from ChatHistory Where ((FromId = ? AND ToId = ?) OR (FromId = ? AND ToId = ?)) AND isGroupChat = ? AND EventID = ? Order by CreatedDate ASC"
//                    results = database.executeQuery(querySQL, withArgumentsIn: [fromId, groupId, groupId, fromId, isGroupChat, EventData.sharedInstance.eventId])
                    print("All History Query : ",querySQL)

                }
                else {

                    let querySQL = "Select * from ChatHistory Where ((FromId = ? AND ToId = ?) OR (FromId = ? AND ToId = ?)) AND CreatedDate >= ? AND CreatedDate <= ? AND isGroupChat = ? AND isDeleted = ? AND EventID = ? AND AttendeeId = ?  Order by CreatedDate ASC"
                    results = database.executeQuery(querySQL, withArgumentsIn: [fromId, groupId, groupId, fromId, lastFetchTime,currentTime, 0, 0, EventData.sharedInstance.eventId,EventData.sharedInstance.attendeeId])
                    
                    print("Refresh query : ",querySQL)
                }
            }
            else {
                if previousTime == nil {

                    let querySQL = "Select * from ChatHistory Where GroupId = ? AND isDeleted = ? AND EventID = ? AND AttendeeId = ? Order by CreatedDate ASC"
                    results = database.executeQuery(querySQL, withArgumentsIn: [groupId, 0, EventData.sharedInstance.eventId,EventData.sharedInstance.attendeeId])
                    print("Group history query : ",querySQL)
                }
                else {
                    let querySQL = "Select * from ChatHistory Where GroupId = ? AND CreatedDate >= ? AND CreatedDate <= ? AND isDeleted = ? AND EventID = ? AND AttendeeId = ? Order by CreatedDate ASC"
                    results = database.executeQuery(querySQL, withArgumentsIn: [groupId, previousTime, currentTime, 0, EventData.sharedInstance.eventId,EventData.sharedInstance.attendeeId])
                    print("Group history query refresh : ",querySQL)
                }
//                if previousTime == nil {
//                    let querySQL = "Select * from ChatHistory Where GroupId = ? AND EventID = ? Order by CreatedDate ASC"
//                    results = database.executeQuery(querySQL, withArgumentsIn: [groupId, EventData.sharedInstance.eventId])
//                    print("Group history query : ",querySQL)
//                }
//                else {
//                    let querySQL = "Select * from ChatHistory Where GroupId = ? AND CreatedDate >= ? AND CreatedDate <= ? AND EventID = ? Order by CreatedDate ASC"
//                    results = database.executeQuery(querySQL, withArgumentsIn: [groupId, previousTime, currentTime, EventData.sharedInstance.eventId])
//                    print("Group history query refresh : ",querySQL)
//                }

            }
            
            while results?.next() == true {
                
                let messageFrame = UUMessageFrame()
                let message = UUMessage()
                message.chatId = (results?.string(forColumn: "ChatMessageId"))!
                message.createdBy = (results?.string(forColumn: "CreatedBy"))!
                message.strId = (results?.string(forColumn: "FromId"))!
                message.strName = (results?.string(forColumn: "UserName"))!
                message.strIcon = (results?.string(forColumn: "UserIconUrl"))!
                message.toUserName = (results?.string(forColumn: "ToUserName"))!
                message.toUserIcon = (results?.string(forColumn: "ToIconUrl"))!

                message.pictureString = (results?.string(forColumn: "MessageIconUrl"))!
                message.strTime = message.changeTheDateString((results?.string(forColumn: "CreatedDate"))!)
                message.messageTime = message.changeTheTime((results?.string(forColumn: "CreatedDate"))!)
                message.messageDate = (results?.string(forColumn: "CreatedDate"))!
                let type = Int((results?.string(forColumn:"MessageType"))!)

                message.type = message.setMessageType(type!)
                message.strContent = (CryptLib.sharedManager() as AnyObject).decryptCipherText(with: (results?.string(forColumn: "Message"))!)
                
                message.minuteOffSetStart(previousTime, end: message.messageDate)
                messageFrame.showTime = message.showDateLabel
                messageFrame.showName = isGroupChat
                messageFrame.message = message
                
                //Check message frame
                if AttendeeInfo.sharedInstance.attendeeId == message.strId {
                    message.from = MessageFrom(rawValue: 0)!
                }
                else {
                    message.from = MessageFrom(rawValue: 1)!
                }
                messageFrame.message = message
                
                if (message.showDateLabel) {
                    previousTime = (results?.string(forColumn: "CreatedDate"))!
                }

                array.append(messageFrame)
            }
            database.close()
        }
        return array as NSArray
    }

    
    func deleteChatMessageDataFromDB(chatId : NSArray) {
        if openDatabase() {
            database.beginTransaction()

            var sqlQuery = ""
            for item in chatId {
                let  dict = item as! NSDictionary
                let id = dict.value(forKey: "ChatId") as! String
                sqlQuery += "Update ChatHistory SET isDeleted = 1 Where ChatMessageId = '\(id)' AND EventID = '\(EventData.sharedInstance.eventId)' AND AttendeeId ='\(EventData.sharedInstance.attendeeId)';"
            }

            if !database.executeStatements(sqlQuery) {
               // print(database.lastError(), database.lastErrorMessage())
            }
        }
        database.commit()
        database.close()
    }

    func deleteChatConversionFromDB(groupId : NSArray) {
        if openDatabase() {
            database.beginTransaction()

            var sqlQuery = ""
            var conversationQuery = ""

            for item in groupId {
                let  dict = item as! NSDictionary
                let id = dict.value(forKey: "ToId") as! String
                sqlQuery += "Update ChatList SET isDeleted = 1 Where GroupId = '\(id)' AND EventID = '\(EventData.sharedInstance.eventId)';"

                conversationQuery += "Update ChatHistory SET isDeleted = 1 Where ((FromId = '\(EventData.sharedInstance.attendeeId)' AND GroupId = '\(id)') OR (FromId = '\(id)' AND GroupId = '\(EventData.sharedInstance.attendeeId)')) AND EventID = '\(EventData.sharedInstance.eventId)' AND AttendeeId = '\(EventData.sharedInstance.attendeeId)';"

            }

            //Delete chat conversion from chatlist table
            if !database.executeStatements(sqlQuery) {
            }

            //Delete chat messages from chat history table
            if !database.executeStatements(conversationQuery) {
            }
        }
        database.commit()
        database.close()
    }

    func updateChatListStatusIntoDB(groupId : String) {
        if openDatabase() {
            do {
                try database.executeUpdate("Update ChatList SET IsReadList = ? Where GroupId = ? AND EventID = ?", values: [1, groupId, EventData.sharedInstance.eventId])
            }catch {
                print("error = \(error)")
            }
        }
        database.close()
    }


    func updateGroupNameIntoDB(groupName : String, groupIcon: String, groupId : String) {
        if openDatabase() {
            do {
                try database.executeUpdate("Update ChatList SET Name = ?, GroupIconUrl = ? Where GroupId = ? AND AttendeeId = ? AND EventID = ?", values: [groupName, groupIcon, groupId, EventData.sharedInstance.attendeeId, EventData.sharedInstance.eventId])
            }catch {
                print("error = \(error)")
            }
        }
        database.close()
    }

    func fetchGroupName(groupId: String) -> String {

        var name = ""
        if openDatabase() {
            let querySQL = "Select Name from ChatList Where GroupId = ? AND AttendeeId = ? AND EventID = ?"
            let results:FMResultSet = database.executeQuery(querySQL, withArgumentsIn: [groupId, EventData.sharedInstance.attendeeId, EventData.sharedInstance.eventId])
            while results.next() == true {
                name = results.string(forColumn: "Name")
            }
            database.close()
        }
        return name
    }

    func fetchChatUnreadListCount() -> Int {

        var count : Int = 0
        if openDatabase() {
            let querySQL = "Select Count(IsReadList) from ChatList Where IsReadList = ? AND AttendeeId = ? AND EventID = ?"
            var results:FMResultSet = database.executeQuery(querySQL, withArgumentsIn: [0, EventData.sharedInstance.attendeeId, EventData.sharedInstance.eventId])
            while results.next() == true {
                count = results.object(forColumnIndex: 0) as! Int
            }
          //  count = database.intForQuery(sql: querySQL)

            database.close()
        }
        return count
    }

    // MARK: - Activity Feed methods

    func saveActivityFeedDataIntoDB(response: AnyObject) {

        if openDatabase() {
            database.beginTransaction()
            
            let eventId = EventData.sharedInstance.eventId
            
//            //Delete local data which is deleted from admin
//            do {
//                try database.executeUpdate("DELETE FROM ActivityFeeds WHERE EventID = ?", values: [eventId])
//
//            } catch {
//                print("error = \(error)")
//            }

            var sqlQuery = ""

            for item in response as! NSArray {
                
                
                let  dict = item as! NSDictionary
                
                let aId = dict.value(forKey: "ActivityFeedID") as! String
                let message = self.isNullString(str: dict.value(forKey: "Comment") as Any)
                let likesCount = dict.value(forKey: "Likes") as! Int
                let commentsCount = dict.value(forKey: "Comments") as! Int
                let postDateStr = dict.value(forKey: "CreatedDate") as! String
                let isDeleted = dict.value(forKey: "isDeleted") as! Int
                let image = self.appendImagePath(path: dict.value(forKey: "ImgPath") as Any)
                var username = ""
                var usericon = ""
                var userId = ""
                
                if (dict.value(forKey: "FeedUser") as? NSNull) == nil {
                    let user = dict.value(forKey: "FeedUser") as! NSDictionary
                    username = self.isNullString(str: user.value(forKey: "Name") as Any)
                    usericon = self.appendImagePath(path: user.value(forKey: "iconurl") as Any)
                    userId = self.isNullString(str: user.value(forKey: "userid") as Any)
                }
                
                //Save likes data in db
                if (dict.value(forKey: "UserLiked") as? NSNull) == nil {
                    self.saveActivityFeedLikesDataIntoDB(response: dict.value(forKey: "UserLiked") as AnyObject, activityFeedId: aId , createdDate:postDateStr )
                }
                
                //  try database.executeUpdate("INSERT OR REPLACE INTO ActivityFeeds (EventID, ActivityFeedID, Message, LikeCount, CommentCount, CreatedDate, IsImageDeleted, PostImagePath, PostUserName, PostUserImage, PostUserId) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? )", values: [eventId, aId ,message,likesCount, commentsCount, postDateStr, isDeleted, image, username, usericon, userId])
                
                sqlQuery += "INSERT OR REPLACE INTO ActivityFeeds (EventID, ActivityFeedID, Message, LikeCount, CommentCount, CreatedDate, IsImageDeleted, PostImagePath, PostUserName, PostUserImage, PostUserId) VALUES ('\(eventId)', '\(aId)', \"\(message)\", '\(likesCount)', '\(commentsCount)','\(postDateStr)', \(isDeleted),'\(image)',\"\(username)\",'\(usericon)','\(userId)');"
                
            }
            
            if !database.executeStatements(sqlQuery) {
//                print("Failed to insert Activityfeed data into the database.")
//                print(database.lastError(), database.lastErrorMessage())
            }
        }
    
        database.commit()
        database.close()
    }
    
    func saveActivityFeedCommentsDataIntoDB(response: AnyObject) {

        if openDatabase() {
            let eventId = EventData.sharedInstance.eventId
            
            if response is NSDictionary {
                let aDict = response as! NSDictionary
                let aId = aDict.value(forKey: "ActivityFeedID") as! String
                let arr = aDict.value(forKey: "UserComments")

                for item in arr as! Array<Any> {
                    do {
                        let  cDict = item as! NSDictionary
                        let message = self.isNullString(str: cDict.value(forKey: "comment") as Any)
                        let username = self.isNullString(str: cDict.value(forKey: "Name") as Any)
                        let usericon = self.appendImagePath(path: cDict.value(forKey: "iconurl") as Any)
                        let userId = self.isNullString(str: cDict.value(forKey: "userid") as Any)
                        let createdDate = self.isNullString(str: cDict.value(forKey: "CreatedDate") as Any)
                        let commentId = self.isNullString(str: cDict.value(forKey: "CommentId") as Any)
                        
                        try database.executeUpdate("INSERT OR REPLACE INTO ActivityFeedsComments (EventID, ActivityFeedID, CommentId, AttendeeId, Name, IconUrl, Comments, CreatedDate) VALUES (?, ?, ?, ?, ?, ?, ?, ?)", values: [eventId, aId ,commentId, userId, username, usericon, message, createdDate])
                        
                    } catch {
                        print("error = \(error)")
                    }
                }
            }
        }
        
        database.close()
    }
    
    func saveActivityFeedLikesDataIntoDB(response: AnyObject, activityFeedId : String, createdDate : String) {
        
        if openDatabase() {
            let eventId = EventData.sharedInstance.eventId
            
            //Delete local data which is deleted from admin
            do {
                try database.executeUpdate("DELETE FROM ActivityFeedsLikes WHERE EventID = ? AND ActivityFeedID = ?", values: [eventId, activityFeedId])
                
            } catch {
                print("error = \(error)")
            }
            
            for item in response as! NSArray {
                
                do {
                    let  dict = item as! NSDictionary
                    let username = self.isNullString(str: dict.value(forKey: "Name") as Any)
                    let usericon = self.appendImagePath(path: dict.value(forKey: "iconurl") as Any)
                    let userId = self.isNullString(str: dict.value(forKey: "userid") as Any)
                    let isUserLike = 1 //(userId == EventData.sharedInstance.attendeeId) ? true : false

                    try database.executeUpdate("INSERT OR REPLACE INTO ActivityFeedsLikes (EventID, ActivityFeedID, AttendeeId, Name, IconUrl, IsUserLike, CreatedDate) VALUES (?, ?, ?, ?, ?, ?, ?)", values: [eventId, activityFeedId ,userId,username, usericon,isUserLike, createdDate])

                } catch {
                    print("error = \(error)")
                }
            }
        }
    }

    func fetchActivityFeedsDataFromDB(limit : NSInteger, offset : NSInteger) -> NSArray {
        var array = [ActivityFeedsModel]()
        
        if openDatabase() {
            
            let querySQL = "Select ActivityFeeds.*, ActivityFeedsLikes.IsUserLike from ActivityFeeds LEFT JOIN ActivityFeedsLikes ON ActivityFeeds.ActivityFeedID = ActivityFeedsLikes.ActivityFeedID AND ActivityFeedsLikes.AttendeeId = \'\(EventData.sharedInstance.attendeeId)' where ActivityFeeds.EventID = \'\(EventData.sharedInstance.eventId)' Order by CreatedDate DESC limit \(offset),\(limit)"
          //  let querySQL = "Select * from ActivityFeeds where EventID = \'\(EventData.sharedInstance.eventId)'"
            let results:FMResultSet? = database.executeQuery(querySQL, withArgumentsIn: nil)
            
            while results?.next() == true {

                let model = ActivityFeedsModel()
                model.id = (results?.string(forColumn: "ActivityFeedID"))!
                model.messageText = (results?.string(forColumn: "Message"))!
                model.likesCount = (results?.string(forColumn: "LikeCount"))!
                model.commentsCount = (results?.string(forColumn: "CommentCount"))!
                model.postDateStr = (results?.string(forColumn: "CreatedDate"))!
                model.isImageDeleted = (results?.bool(forColumn: "IsImageDeleted"))!
                model.postImageUrl = (results?.string(forColumn: "PostImagePath"))!
                model.userNameString = (results?.string(forColumn: "PostUserName"))!
                model.userIconUrl = (results?.string(forColumn: "PostUserImage"))!
                model.userId = (results?.string(forColumn: "PostUserId"))!
                model.isUserLike =  (results?.bool(forColumn: "IsUserLike"))!

                let query = "Select IsUserLike from ActivityFeedsLikes where ActivityFeedID = \'\(model.id)' AND AttendeeId = \'\(EventData.sharedInstance.eventId)' AND ActivityFeedID = \'\(EventData.sharedInstance.eventId)'"
                let results1:FMResultSet? = database.executeQuery(query, withArgumentsIn: nil)
                while results1?.next() == true {
                    model.isUserLike =  (results1?.bool(forColumn: "IsUserLike"))!
                }
                array.append(model)
            }
            database.close()
        }
        return array as NSArray
    }
    
    func fetchActivityFeedsCommentsDataFromDB(activityFeedId : String) -> NSArray {
        var array = [FeedsCommentModel]()
        
        if openDatabase() {
            
            let querySQL = "Select * from ActivityFeedsComments WHERE ActivityFeedID = ? AND EventID = ? Order by CreatedDate"
            let results:FMResultSet? = database.executeQuery(querySQL, withArgumentsIn: [activityFeedId, EventData.sharedInstance.eventId])
            
            while results?.next() == true {
                let model = FeedsCommentModel()
                model.commentId = (results?.string(forColumn: "ActivityFeedID"))!
                model.messageText = (results?.string(forColumn: "Comments"))!
                model.name = (results?.string(forColumn: "Name"))!
                model.createdDate = (results?.string(forColumn: "CreatedDate"))!
                model.userIconUrl = (results?.string(forColumn: "IconUrl"))!
                model.userId = (results?.string(forColumn: "AttendeeId"))!
                array.append(model)
            }
            database.close()
        }
        return array as NSArray
    }

    func fetchActivityFeedsLikesDataFromDB(activityFeedId : String) -> NSArray {
        var array = [ActivityLikeModel]()

        if openDatabase() {

            let querySQL = "Select * from ActivityFeedsLikes WHERE ActivityFeedID = ? AND IsUserLike = ? AND EventID = ? Order by CreatedDate"
            let results:FMResultSet? = database.executeQuery(querySQL, withArgumentsIn: [activityFeedId, 1, EventData.sharedInstance.eventId])

            while results?.next() == true {
                let model = ActivityLikeModel()
                model.activityFeedId = (results?.string(forColumn: "ActivityFeedID"))!
                model.name = (results?.string(forColumn: "Name"))!
                model.userIconUrl = (results?.string(forColumn: "IconUrl"))!
                model.userId = (results?.string(forColumn: "AttendeeId"))!
                array.append(model)
            }
            database.close()
        }
        return array as NSArray
    }

    func updateActivityLikeDataIntoDB(userLike: Bool, activityId : String) {
        
        if openDatabase() {
            let eventId = EventData.sharedInstance.eventId
            
            do {
                let createdDate = CommonModel.sharedInstance.getCurrentDateInMM()
                try database.executeUpdate("INSERT OR REPLACE INTO ActivityFeedsLikes (ActivityFeedID, EventID, AttendeeId, IsUserLike, Name, IconUrl, CreatedDate) VALUES (?, ?, ?, ?, ?, ?, ?)", values: [activityId, eventId, EventData.sharedInstance.attendeeId, userLike, AttendeeInfo.sharedInstance.attendeeName,AttendeeInfo.sharedInstance.iconUrl,createdDate])

            } catch {
                print("error = \(error)")
            }
        }
        
        database.close()
    }
    
    func updateActivityFeedsDataIntoDB(likesCount: String, commentsCount : String, activityFeedId : String) {
        
        if openDatabase() {
            let eventId = EventData.sharedInstance.eventId
            
            do {
                try database.executeUpdate("UPDATE ActivityFeeds SET LikeCount = ?, CommentCount = ? WHERE ActivityFeedID = ? AND EventID = ?", values: [likesCount, commentsCount,activityFeedId, eventId])

            } catch {
                print("error = \(error)")
            }
        }
        
        database.close()
    }
    // MARK: - Gallery methods
    
    func saveGalleryDataIntoDB(response: AnyObject) {

        if openDatabase() {
            self.database.beginTransaction()

            let eventId = EventData.sharedInstance.eventId

            //Delete local data which is deleted from admin
            do {
                try database.executeUpdate("DELETE FROM Gallery WHERE EventID = ?", values: [eventId])
                
            } catch {
                print("error = \(error)")
            }

            var sqlQuery = ""
            for item in response as! NSArray {
                
               // do {
                    let  dict = item as! NSDictionary
                    let id = dict.value(forKey: "ImageID") as! String
                    let image = self.appendImagePath(path: dict.value(forKey: "ImageIconUrl") as Any)
                    let isDeleted = dict.value(forKey: "IsDeleted")

                    //CreatedDate
                  //  try database.executeUpdate("INSERT OR REPLACE INTO Gallery (EventID, Id, Images, isDeleted) VALUES (?, ?, ?, ?)", values: [eventId, id ,image , isDeleted ?? false])

                sqlQuery += "INSERT OR REPLACE INTO Gallery (EventID, Id, Images, isDeleted) VALUES ('\(eventId)', '\(id)', \"\(image)\",\(isDeleted ?? 0));"

//                } catch {
//                    print("error = \(error)")
//                }
            }

            if !database.executeStatements(sqlQuery) {
                //print(database.lastError(), database.lastErrorMessage())
            }

            self.database.commit()
            database.close()
        }
    }
    
    func fetchGalleryDataFromDB() -> NSArray {
        var array = [PhotoGallery]()
        
        if openDatabase() {
           
           // for i in 0...20 {
                
                let querySQL = "Select * from Gallery where EventID = ?"
                let results:FMResultSet? = self.database.executeQuery(querySQL, withArgumentsIn: [EventData.sharedInstance.eventId])
                
                while results?.next() == true {
                    
                    let model = PhotoGallery()
                    model.id = results?.string(forColumn: "Id")
                    model.iconUrl = results?.string(forColumn: "Images")
                    model.isImageDeleted = (results?.bool(forColumn: "isDeleted"))!
                    
                    array.append(model)
                }
          //  }
            database.close()
        }
        return array as NSArray
    }
    
    
    // MARK: - Website methods
    
    func saveWebsiteDataIntoDB(response: AnyObject) {
        
        if openDatabase() {
            let eventId = EventData.sharedInstance.eventId
            
            //Delete local data which is deleted from admin
            do {
                try database.executeUpdate("DELETE FROM Website WHERE EventID = ?", values: [eventId])
                
            } catch {
                print("error = \(error)")
            }
            
            for item in response as! NSArray {
                do {
                    let  dict = item as! NSDictionary
                    let id = dict.value(forKey: "Id") as! String
                    let url = self.isNullString(str: dict.value(forKey: "Url") as Any)
                    
                    //CreatedDate
                    try database.executeUpdate("INSERT OR REPLACE INTO Website (EventID, Id, WebsiteUrl) VALUES (?, ?, ?)", values: [eventId, id ,url])
                    
                } catch {
                    print("error = \(error)")
                }
            }
        }
        
        database.close()
    }
    
    func fetchWebsiteDataFromDB() -> WebsiteModel {
        let model = WebsiteModel()

        if openDatabase() {
            // for i in 0...20 {
            
            let querySQL = "Select * from Website where EventID = ?"
            let results:FMResultSet? = self.database.executeQuery(querySQL, withArgumentsIn: [EventData.sharedInstance.eventId])
            
            while results?.next() == true {
                
                model.eventid = (results?.string(forColumn: "EventID"))!
                model.id = (results?.string(forColumn: "Id"))!
                model.websiteUrl = (results?.string(forColumn: "WebsiteUrl"))!
//                model.append(model)
            }
            //  }
            database.close()
        }
        return model
    }
    
    
    // MARK: - Conversion methods
    
    func convertToJsonData(text: String) -> Any? {
        
        if let data = text.data(using: .utf8) {
            do {
                return try (JSONSerialization.jsonObject(with: data, options: []))
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }

    func convertDataToString(data: AnyObject) -> Any? {
        do {
            let jsonData: NSData = try JSONSerialization.data(withJSONObject: data, options: JSONSerialization.WritingOptions.prettyPrinted) as NSData
            return NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue)! as String
        }catch {
            print(error.localizedDescription)
        }
        
        return ""
    }

    // MARK: - Note methods
    
    func saveNewNoteDataIntoDB(note: Notes) {
        note.dateStr = CommonModel.sharedInstance.getCurrentDateAndTime()

        if openDatabase() {
            let eventId = EventData.sharedInstance.eventId

            do {
                try database.executeUpdate("insert or replace into Notes (EventID, title, message, date, SessionId, ActivityId, AttendeeId) VALUES (?, ?, ?, ?, ?, ?, ?)", values: [eventId, note.titleStr, note.messageStr, note.dateStr, note.sessionId, note.activityId, EventData.sharedInstance.attendeeId])
                
            } catch {
                print("error = \(error)")
            }
        }
        
        database.close()
    }
    
    func updateNoteDataIntoDB(note: Notes) {
        
        if openDatabase() {
            let eventId = EventData.sharedInstance.eventId
            note.dateStr = CommonModel.sharedInstance.getCurrentDateAndTime()

            do {
              try database.executeUpdate("UPDATE Notes SET title = ?, message = ?, date = ? WHERE id = ? AND EventID = ? AND AttendeeId = ?", values: [note.titleStr, note.messageStr, note.dateStr, note.id, eventId, EventData.sharedInstance.attendeeId])
                
            } catch {
                print("error = \(error)")
            }
        }
        
        database.close()
    }
    
    func deleteNoteDataIntoDB(note: Notes) {
        
        if openDatabase() {
            
            do {
                try database.executeUpdate("DELETE FROM Notes WHERE id = ? And EventID = ? AND AttendeeId = ?", values: [note.id, EventData.sharedInstance.eventId,EventData.sharedInstance.attendeeId])
                
            } catch {
                print("error = \(error)")
            }
        }
        database.close()
    }

    func fetchAllNotesListFromDB() -> NSArray {
        var array = [Notes]()
        
        if openDatabase() {
            
            let querySQL = "Select * from Notes where EventID = ? AND AttendeeId = ? ORDER BY date DESC"
            let results:FMResultSet? = database.executeQuery(querySQL, withArgumentsIn: [EventData.sharedInstance.eventId,EventData.sharedInstance.attendeeId])
            
            while results?.next() == true {
                
                let model = Notes()
                model.id = Int((results?.int(forColumn: "id"))!)
                model.titleStr = results?.string(forColumn: "title")
                model.messageStr = results?.string(forColumn: "message")
                model.dateStr = results?.string(forColumn: "date")
                model.sessionId = (results?.string(forColumn: "SessionId"))!

                array.append(model)
            }
            database.close()
        }
        return array as NSArray
    }

    func fetchNotesFromDB(activityId: String) -> Notes {
        let model = Notes()

        if openDatabase() {
            
            let querySQL = "Select * from Notes WHERE ActivityId = '\(activityId )' AND EventID = ? AND AttendeeId = ?"
            let results:FMResultSet? = database.executeQuery(querySQL, withArgumentsIn: [EventData.sharedInstance.eventId,EventData.sharedInstance.attendeeId])
            
            while results?.next() == true {
                
                model.id = Int((results?.int(forColumn: "id"))!)
                model.titleStr = results?.string(forColumn: "title")
                model.messageStr = results?.string(forColumn: "message")
                model.dateStr = results?.string(forColumn: "date")
                model.sessionId = (results?.string(forColumn: "SessionId"))!
                model.activityId = (results?.string(forColumn: "ActivityId"))!
            }
            database.close()
        }
        return model
    }

    // MARK: - Reminders methods
    
    func saveNewReminderDataIntoDB(reminder: ReminderModel) {
        
        if openDatabase() {
            
            do {
                try database.executeUpdate("insert or replace into Reminder (EventID, Title, message, SortDate, ReminderTime,ActivityStartTime, ActivityEndTime, ActivitySessionId, ActivityId, AttendeeId) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", values: [EventData.sharedInstance.eventId, reminder.title, reminder.message, reminder.sortDate, reminder.reminderTime,reminder.activityStartTime, reminder.activityEndTime, reminder.sessionId, reminder.activityId, EventData.sharedInstance.attendeeId ])
                
            } catch {
                print("error = \(error)")
            }
        }
        
        database.close()
    }
    
    func deleteReminderDataIntoDB(reminder: ReminderModel) {
        
        if openDatabase() {
            
            do {
                try database.executeUpdate("DELETE FROM Reminder WHERE id = ? AND EventID = ? AND AttendeeId = ?", values: [reminder.id, EventData.sharedInstance.eventId,EventData.sharedInstance.attendeeId])
                
            } catch {
                print("error = \(error)")
            }
        }
        database.close()
    }
    
    func fetchAllRemindersListFromDB() -> NSArray {
        var array = [ReminderModel]()
        
        if openDatabase() {
            
            let querySQL = "Select * from Reminder where EventID = ? AND AttendeeId = ? ORDER BY SortDate DESC"
            let results:FMResultSet? = database.executeQuery(querySQL, withArgumentsIn: [EventData.sharedInstance.eventId, EventData.sharedInstance.attendeeId])
            
            while results?.next() == true {
                
                let model = ReminderModel()
                model.id = Int((results?.int(forColumn: "id"))!)
                model.title = (results?.string(forColumn: "Title"))!
                model.message = (results?.string(forColumn: "Message"))!
                model.sortDate = (results?.string(forColumn: "SortDate"))!
                model.reminderTime = (results?.string(forColumn: "ReminderTime"))!
                model.activityStartTime = (results?.string(forColumn: "ActivityStartTime"))!
                model.activityEndTime = (results?.string(forColumn: "ActivityEndTime"))!
                model.sessionId = (results?.string(forColumn: "ActivitySessionId"))!

                array.append(model)
            }
            database.close()
        }
        return array as NSArray
    }
    
    func isReminderAddedIntoDB(activityId: String) -> Bool {
        
        var result = false
        
        if openDatabase() {
            
            let querySQL = "Select *from Reminder WHERE ActivityId = '\(activityId )' and EventID = ? AND AttendeeId = ?"
            let results:FMResultSet? = database.executeQuery(querySQL, withArgumentsIn: [EventData.sharedInstance.eventId,EventData.sharedInstance.attendeeId])
            
            while results?.next() == true {
                result = true
            }
            database.close()
        }
        return result
    }

    // MARK: - Poll activities and Activity history methods
    
    func savePollActivitySessionsIntoDB(response: AnyObject) {
        
        if openDatabase() {
            self.database.beginTransaction()

            //Delete local data which is deleted from admin
            do {
                try database.executeUpdate("DELETE FROM PollActivities WHERE EventID = ?", values: [EventData.sharedInstance.eventId])
                
            } catch {
                print("error = \(error)")
            }

            var sqlQuery = ""
            for item in response as! NSArray {
               // do {
                    if item is NSDictionary {
                        
                        let  dict = item as! NSDictionary
                        // print("Dict ",dict)
                        let sessionId = dict.value(forKey: "Session") as! Int
                        let eventId = self.isNullString(str: dict.value(forKey: "EventId") as Any)
                        let activityId = dict.value(forKey: "ActivityId") as! String
                        let activitySessionId = String(format: "%@-%d", activityId, sessionId as CVarArg)
                        
                        let speakerId = ""//self.isNullString(str: dict.value(forKey: "Designation") as Any)
                        let name = self.isNullString(str: dict.value(forKey: "ActivityName") as Any)
//                        let startDate = CommonModel.sharedInstance.UTCToLocalDate(date: self.isNullString(str: dict.value(forKey: "StartDate") as Any))
//                        let endDate = CommonModel.sharedInstance.UTCToLocalDate(date: self.isNullString(str: dict.value(forKey: "EndDate") as Any))
                        //Remove UTC - Change Shital on 15 Dec
                        let startDate = self.isNullString(str: dict.value(forKey: "StartDate") as Any)
                        let endDate = self.isNullString(str: dict.value(forKey: "EndDate") as Any)
                        let sortDate = self.isNullString(str: dict.value(forKey: "SortActivityDate") as Any)
                        let day = self.isNullString(str: dict.value(forKey: "Day") as Any)
                        //Remove UTC - Change Shital on 15 Dec
                        //let startTime = CommonModel.sharedInstance.UTCToLocalDate(date:dict.value(forKey: "StartTime") as! String)
                        //let endTime = CommonModel.sharedInstance.UTCToLocalDate(date:dict.value(forKey: "EndTime") as! String)
                        let startTime = self.isNullString(str: dict.value(forKey: "StartTime") as Any)
                        let endTime = self.isNullString(str: dict.value(forKey: "EndTime") as Any)
                        let isActive = 0 //dict.value(forKey: "Description")
                        let agendaId = self.isNullString(str: dict.value(forKey: "AgendaId") as Any)
                        let agendaName = self.isNullString(str: dict.value(forKey: "AgendaName") as Any)
                        let location = self.isNullString(str: dict.value(forKey: "Location") as Any)
                        let count = dict.value(forKey: "QACount")
                        
                       // try database.executeUpdate("INSERT OR REPLACE INTO PollActivities (EventID, SessionId, ActivitySessionId, ActivityId, SpeakerId, ActivityName,ActivityStartDate,ActivityEndDate, StartTime, EndTime,SortActivityDate, ActivityDay, isActive, AgendaId, AgendaName, Location,QuesCount) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", values: [eventId, sessionId, activitySessionId, activityId, speakerId,name, startDate, endDate, startTime , endTime,sortDate, day,isActive, agendaId, agendaName, location,count ?? 0])

                        sqlQuery += "INSERT OR REPLACE INTO PollActivities (EventID, SessionId, ActivitySessionId, ActivityId, SpeakerId, ActivityName,ActivityStartDate,ActivityEndDate, StartTime, EndTime,SortActivityDate, ActivityDay, isActive, AgendaId, AgendaName, Location,QuesCount) VALUES ('\(eventId)', '\(sessionId)', '\(activitySessionId)','\(activityId)','\(speakerId)', \"\(name)\",'\(startDate)', '\(endDate)','\(startTime)','\(endTime)','\(sortDate)','\(day)',\(isActive),'\(agendaId)', \"\(agendaName)\",\"\(location)\",'\(count ?? 0)');"
                    }
//                } catch {
//                    print("error = \(error)")
//                }
            }
            if !database.executeStatements(sqlQuery) {
               // print(database.lastError(), database.lastErrorMessage())
            }

            database.commit()
            self.database.close()
        }
        self.database.close()
    }
    
    func fetchPollActivitiesDataFromDB() -> NSArray {
        var array = [SessionsModel]()
        
        if openDatabase() {
            
            //Fetch current date and time
            let (_, endDate) = self.getCurrentTime()
            let querySQL =  "Select * from PollActivities WHERE ActivityEndDate < ? AND EventID = ? ORDER BY SortActivityDate DESC"
            let results:FMResultSet? = database.executeQuery(querySQL, withArgumentsIn: [endDate, EventData.sharedInstance.eventId])
            
            while results?.next() == true {
                
                let model = SessionsModel()
                model.id = (results?.string(forColumn: "ID"))!
                model.eventId = results?.string(forColumn: "EventID")
                model.sessionId = results?.string(forColumn: "SessionId")
                model.activitySessionId = results?.string(forColumn: "ActivitySesssionId")
                model.activityId = results?.string(forColumn: "ActivityId")
                model.activityName = results?.string(forColumn: "ActivityName")
                model.agendaId = results?.string(forColumn: "AgendaId")
                model.agendaName = results?.string(forColumn: "AgendaName")
                model.startActivityDate = results?.string(forColumn: "ActivityStartDate")
                model.endActivityDate = results?.string(forColumn: "ActivityEndDate")
                model.sortActivityDate = results?.string(forColumn: "SortActivityDate")
                model.day = results?.string(forColumn: "ActivityDay")
                model.location = results?.string(forColumn: "Location")
                model.startTime =  results?.string(forColumn: "StartTime")
                model.endTime =  results?.string(forColumn: "EndTime")
                model.isActive = (results?.bool(forColumn: "isActive"))!
                
                array.append(model)
            }
            database.close()
        }
        return array as NSArray
    }
    
    func savePollActivityQuestionsIntoDB(response: AnyObject) {
        
        if openDatabase() {
            
            for item in response as! NSArray {
                do {
                    if item is NSDictionary {
                        
                        let  dict = item as! NSDictionary
                        
                        let queId = self.isNullString(str: dict.value(forKey: "Id") as Any)
                        let eventId = self.isNullString(str: dict.value(forKey: "EventId") as Any)
                        let activityId = self.isNullString(str: dict.value(forKey: "ActivityId") as Any)
                        let sessionId = 0 //dict.value(forKey: "Session")
                        let question = self.isNullString(str: dict.value(forKey: "Questions") as Any)
                        let optionsCount = 4 //dict.value(forKey: "Options") as Array
                        let optionsArr = convertDataToString(data: dict.value(forKey: "Options") as AnyObject)
                        let isUserAnswered = dict.value(forKey: "IsUserAnswered")
                        let userAnswer = self.isNullString(str: dict.value(forKey: "UserAnswerId") as Any)

                        //Create Question table
                        try database.executeUpdate("INSERT OR REPLACE INTO PollQuestions (EventID, QueId, ActivityId,SessionId, Question, OptionsCount,Options, isUserAnswered, UserAnswer) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)", values: [eventId,queId ,activityId, sessionId ,question , optionsCount, optionsArr ?? "", isUserAnswered ?? false, userAnswer])
                    }
                    
                } catch {
                    print("error = \(error)")
                }
            }
        }
    }
    
    func fetchPollActivityQuestionsListFromDB(sessionId : String, activityId : String) -> NSArray {
        var array = [PollModel]()

        if openDatabase() {
            
          //  let querySQL = "Select * from PollQuestions where ActivityId = ? AND SessionId = ? AND EventID = ?"
            let querySQL = "Select * from PollQuestions where ActivityId = ? AND EventID = ?"

            let results:FMResultSet? = database.executeQuery(querySQL, withArgumentsIn: [activityId, EventData.sharedInstance.eventId])
            
            while results?.next() == true {
                
                let model = PollModel()
                model.id = (results?.string(forColumn: "QueId"))!
                model.eventId = results?.string(forColumn: "EventID")
                model.questionText = results?.string(forColumn: "Question")
               // model.queCount = Int((results?.string(forColumn: "OptionsCount"))!)!
               // model.timeStr = (results?.string(forColumn: "Time"))!
                model.activityId = results?.string(forColumn: "ActivityId")
                model.optionsArr = convertToJsonData(text: (results?.string(forColumn: "Options"))!) as! Array<Any>
                model.isUserAnswered = results?.bool(forColumn: "isUserAnswered")
                model.userAnswerId = results?.string(forColumn: "UserAnswer")

                array.append(model)
            }
            database.close()
        }
        return array as NSArray
    }

   //MARK: -  Add Speaker Poll Methods

    //Get Speaker Poll Activities
    func saveSpeakerPollActListIntoDB(response: AnyObject) {

        if openDatabase() {

            //Delete local data which is deleted from admin
            do {
                try database.executeUpdate("DELETE FROM PollSpeakerActivity WHERE EventID = ?", values: [EventData.sharedInstance.eventId])

            } catch {
                print("error = \(error)")
            }

            let eventId = EventData.sharedInstance.eventId
            let speakerId = AttendeeInfo.sharedInstance.speakerId
            for item in response as! NSArray {
                do {
                    if item is NSDictionary {

                        let  dict = item as! NSDictionary
                        let actid = dict.value(forKey: "Value") as! String!
                        let actname =  dict.value(forKey: "Text") as! String!
                        let startdate = dict.value(forKey: "StartDateTime") as! String!
                        let endate = dict.value(forKey: "EndDateTime") as! String!

                        //Create  table
                        try database.executeUpdate("INSERT OR REPLACE INTO PollSpeakerActivity (EventId, ActivityId, ActivityName, ActivityStartDate, ActivityEndDate, SpeakerId) VALUES ( ?, ?, ?, ?, ?, ?)", values: [eventId, actid ?? "", actname, startdate, endate, speakerId])

                    }

                } catch {
                    print("error = \(error)")
                }
            }
            database.close()
        }
    }

    func fetchSpeakerPollActListFromDB() -> NSArray {
        var listArray = [AgendaModel]()

        if openDatabase() {
            let (_, endDate) = self.getCurrentTime()
            let querySQL = "Select * from PollSpeakerActivity where ActivityEndDate > ? AND EventID = ? AND SpeakerId = ? "
            let results:FMResultSet? = database.executeQuery(querySQL, withArgumentsIn: [endDate, EventData.sharedInstance.eventId, AttendeeInfo.sharedInstance.speakerId])

            while results?.next() == true {

                let model = AgendaModel()
                model.activityId = (results?.string(forColumn: "ActivityId"))
                model.activityName = (results?.string(forColumn: "ActivityName"))
                model.startActivityDate =  (results?.string(forColumn: "ActivityStartDate"))
                model.endActivityDate =  (results?.string(forColumn: "ActivityEndDate"))
                model.speakerId = (results?.string(forColumn: "SpeakerId"))

                listArray.append(model)
            }
            database.close()
        }
        return listArray as NSArray
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    //Speaker Poll Questions

    func saveSpeakerPollActQuestionIntoDB(response: AnyObject) {

        if openDatabase() {
            let eventId = EventData.sharedInstance.eventId

            for item in response as! NSArray {
                do {
                    if item is NSDictionary {

                        let  dict = item as! NSDictionary

                        //                        let eventId = dict.value(forKey: "EventId") as! String!
                        let activityId = dict.value(forKey: "ActivityId") as! String!
                        let question = dict.value(forKey: "Questions") as! String!
                        let questionsId = dict.value(forKey: "Id") as! String!
                        let opt1 = dict.value(forKey: "Option1") as! String!
                        let opt2 = dict.value(forKey: "Option2") as! String!
                        let opt3 = dict.value(forKey: "Option3") as! String!
                        let opt4 = dict.value(forKey: "Option4") as! String!
                        let op1Id = dict.value(forKey: "Option1Id") as! String!
                        let opt2Id = dict.value(forKey: "Option2Id") as! String!
                        let opt3Id = dict.value(forKey: "Option3Id") as! String!
                        let opt4Id = dict.value(forKey: "Option4Id") as! String!

                        //Create  table
                        try database.executeUpdate("INSERT OR REPLACE INTO SpeakerPollQuestions (EventID, ActivityId,  Question, QuestionId, Option1, Option2, Option3, Option4, Op1Id, Op2Id, Op3Id, Op4Id) VALUES ( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", values: [eventId, activityId, question, questionsId, opt1, opt2, opt3, opt4, op1Id, opt2Id, opt3Id, opt4Id])

                    }

                } catch {
                    print("error = \(error)")
                }
            }
        }
    }


    func fetchSpeakerPollQuestions(activityId : String) -> NSArray {
        var listArray = [PollModel]()

        if openDatabase() {

            let querySQL = "Select * from SpeakerPollQuestions where  EventID = ? AND ActivityId = ?"
            let results:FMResultSet? = database.executeQuery(querySQL, withArgumentsIn: [EventData.sharedInstance.eventId, activityId])

            while results?.next() == true {

                let questionModel = PollModel()
                questionModel.eventId = (results?.string(forColumn: "EventID"))
                questionModel.activityId = (results?.string(forColumn: "ActivityId"))
                questionModel.questionText = (results?.string(forColumn: "Question"))
                questionModel.questionsId = (results?.string(forColumn: "QuestionId"))
                questionModel.opt1 = (results?.string(forColumn: "Option1"))
                questionModel.opt2 = (results?.string(forColumn: "Option2"))
                questionModel.opt3 = (results?.string(forColumn: "Option3"))
                questionModel.opt4 = (results?.string(forColumn: "Option4"))
                questionModel.op1Id = (results?.string(forColumn: "Op1Id"))
                questionModel.opt2Id = (results?.string(forColumn: "Op2Id"))
                questionModel.opt3Id = (results?.string(forColumn: "Op3Id"))
                questionModel.opt4Id = (results?.string(forColumn: "Op4Id"))

                listArray.append(questionModel)
            }
            database.close()
        }
        return listArray as NSArray
    }

    //Update Poll Questions - Speaker
    func updateSpeakerPollQuestionsDataIntoDB(question: String , opt1: String, opt2 : String, opt3 : String, opt4 : String, questionsId : String) {

        if openDatabase() {
            let eventId = EventData.sharedInstance.eventId

            do {
                try database.executeUpdate("UPDATE SpeakerPollQuestions SET Question = ?, Option1 = ?, Option2 = ?, Option3 = ?, Option4 = ?  WHERE QuestionId = ? AND EventID = ?", values: [question, opt1, opt2, opt3, opt4, questionsId, eventId])

            } catch {
                print("error = \(error)")
            }
        }

        database.close()
    }


    // MARK: - Question and Session methods
    
    func saveActiveSessionIntoDB(response: AnyObject) {
        
        if openDatabase() {
            database.beginTransaction()
            //Delete local data which is deleted from admin
            do {
                try database.executeUpdate("DELETE FROM QuestionActivities WHERE EventID = ?", values: [EventData.sharedInstance.eventId])
                
            } catch {
                print("error = \(error)")
            }

            var sqlQuery = ""
            for item in response as! NSArray {
                //do {
                    if item is NSDictionary {
                        
                        let  dict = item as! NSDictionary
                        // print("Dict ",dict)
                        let sessionId = dict.value(forKey: "Session") as! Int
                        let eventId = self.isNullString(str: dict.value(forKey: "EventId") as Any)
                        let activityId = dict.value(forKey: "ActivityId") as! String
                        let activitySessionId = String(format: "%@-%d", activityId, sessionId as CVarArg)

                        let speakerId = ""//self.isNullString(str: dict.value(forKey: "Designation") as Any)
                        let name = self.isNullString(str: dict.value(forKey: "ActivityName") as Any)
                        //Remove UTC - Change Shital on 15 Dec
                        //                        let startDate = CommonModel.sharedInstance.UTCToLocalDate(date: self.isNullString(str: dict.value(forKey: "StartDate") as Any))
                        //                        let endDate = CommonModel.sharedInstance.UTCToLocalDate(date: self.isNullString(str: dict.value(forKey: "EndDate") as Any))
                        //                        let startTime = CommonModel.sharedInstance.UTCToLocalDate(date:dict.value(forKey: "StartTime") as! String)
                        //                        let endTime = CommonModel.sharedInstance.UTCToLocalDate(date:dict.value(forKey: "EndTime") as! String)
                        let startTime = self.isNullString(str: dict.value(forKey: "StartTime") as Any)
                        let endTime = self.isNullString(str: dict.value(forKey: "EndTime") as Any)
                        let startDate = self.isNullString(str: dict.value(forKey: "StartDate") as Any)
                        let endDate = self.isNullString(str: dict.value(forKey: "EndDate") as Any)
                        let sortDate = self.isNullString(str: dict.value(forKey: "SortActivityDate") as Any)
                        let day = self.isNullString(str: dict.value(forKey: "Day") as Any)
                        let isActive = 0 //dict.value(forKey: "Description")
                        let agendaId = self.isNullString(str: dict.value(forKey: "AgendaId") as Any)
                        let agendaName = self.isNullString(str: dict.value(forKey: "AgendaName") as Any)
                        let location = self.isNullString(str: dict.value(forKey: "Location") as Any)
                        let count = dict.value(forKey: "QACount")

                        // try database.executeUpdate("INSERT OR REPLACE INTO QuestionActivities (EventID, SessionId, ActivitySessionId, ActivityId, SpeakerId, ActivityName,ActivityStartDate,ActivityEndDate, StartTime, EndTime,SortActivityDate, ActivityDay, isActive, AgendaId, AgendaName, Location,QuesCount) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", values: [eventId, sessionId, activitySessionId, activityId, speakerId,name, startDate, endDate, startTime , endTime,sortDate, day,isActive, agendaId, agendaName, location,count ?? 0])

                        sqlQuery += "INSERT OR REPLACE INTO QuestionActivities (EventID, SessionId, ActivitySessionId, ActivityId, SpeakerId, ActivityName,ActivityStartDate,ActivityEndDate, StartTime, EndTime,SortActivityDate, ActivityDay, isActive, AgendaId, AgendaName, Location,QuesCount) VALUES ('\(eventId)', '\(sessionId)', '\(activitySessionId)','\(activityId)','\(speakerId)', \"\(name)\",'\(startDate)', '\(endDate)','\(startTime)','\(endTime)','\(sortDate)','\(day)',\(isActive),'\(agendaId)', \"\(agendaName)\",\"\(location)\",'\(count ?? 0)');"
                    }

//                } catch {
//                    print("error = \(error)")
//                }
            }

            if !database.executeStatements(sqlQuery) {
               // print(database.lastError(), database.lastErrorMessage())
            }

            database.commit()
            self.database.close()
        }
    }
    
    func getCurrentTime() -> (dateStr : String, endDateStr : String) {
        //Fetch current date and time
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "dd-MM-yyyy"
        let dateStr = dateFormatter.string(from: Date())
//        dateFormatter.dateFormat = "HH:mm:ss"
//        let currentTime = dateFormatter.string(from: Date())
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let endDateStr = dateFormatter.string(from: Date())
        return(dateStr, endDateStr)
    }
    
    func fetchAllPastActivitiesDataFromDB() -> NSArray {
        var array = [SessionsModel]()
        
        if openDatabase() {
            
            //Fetch current date and time
            let (_, endDate) = self.getCurrentTime()
            let querySQL =  "Select * from QuestionActivities WHERE ActivityEndDate < ? AND EventID = ? ORDER BY SortActivityDate DESC"
            let results:FMResultSet? = database.executeQuery(querySQL, withArgumentsIn: [endDate, EventData.sharedInstance.eventId])
            
            while results?.next() == true {
                
                let model = SessionsModel()
                model.id = (results?.string(forColumn: "ID"))!
                model.eventId = results?.string(forColumn: "EventID")
                model.sessionId = results?.string(forColumn: "SessionId")
                model.activitySessionId = results?.string(forColumn: "ActivitySessionId")
                model.activityId = results?.string(forColumn: "ActivityId")
                model.activityName = results?.string(forColumn: "ActivityName")
                model.agendaId = results?.string(forColumn: "AgendaId")
                model.agendaName = results?.string(forColumn: "AgendaName")
                model.startActivityDate = results?.string(forColumn: "ActivityStartDate")
                model.endActivityDate = results?.string(forColumn: "ActivityEndDate")
                model.sortActivityDate = results?.string(forColumn: "SortActivityDate")
                model.day = results?.string(forColumn: "ActivityDay")
                model.location = results?.string(forColumn: "Location")
                model.startTime =  results?.string(forColumn: "StartTime")
                model.endTime =  results?.string(forColumn: "EndTime")
                model.isActive = (results?.bool(forColumn: "isActive"))!
                
                array.append(model)
            }
            database.close()
        }
        return array as NSArray
    }

    func saveSessionQuestionsIntoDB(response: AnyObject) {

        if openDatabase() {
            
           // do {
                var activityId = ""
                var sqlQuery = ""

                for item in response as! NSArray {
                    if item is NSDictionary {
                        
                        let  dict = item as! NSDictionary
                        
                        let queId = self.isNullString(str: dict.value(forKey: "Id") as Any)
                        let eventId = self.isNullString(str: dict.value(forKey: "EventId") as Any)
                        activityId = self.isNullString(str: dict.value(forKey: "ActivityId") as Any)
                        let sessionId = dict.value(forKey: "Session")
                        let attendeeId = self.isNullString(str: dict.value(forKey: "CreatedBy") as Any)
                        let name = self.isNullString(str: dict.value(forKey: "Name") as Any)
                        let question = self.isNullString(str: dict.value(forKey: "Question") as Any)
                        //Remove UTC - Change Shital on 15 Dec
                        // let date =  CommonModel.sharedInstance.UTCToLocalDate(date:dict.value(forKey: "CreatedDate") as! String)
                        let date =  self.isNullString(str: dict.value(forKey: "CreatedDate") as Any)
                        let isUserLike = dict.value(forKey: "isUserLike")
                        let count = dict.value(forKey: "Count")
                        
                        //Create Question table
                       // try database.executeUpdate("INSERT OR REPLACE INTO QAQuestions (EventID, QueId, ActivityId,SessionId, Question, AttendeeId, Name, QueCount, isUserLike, Time) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", values: [eventId,queId ,activityId, sessionId ?? 0 ,question , attendeeId, name, count ?? 0, isUserLike ?? false, date ])

                        sqlQuery += "INSERT OR REPLACE INTO QAQuestions (EventID, QueId, ActivityId,SessionId, Question, AttendeeId, Name, QueCount, isUserLike, Time) VALUES ('\(eventId)', '\(queId)', '\(activityId)','\(sessionId ?? 0)', '\(question)', '\(attendeeId)', '\(name)','\(count ?? 0)',\(isUserLike ?? false),'\(date)');"
                    }
                }
//            } catch {
//                print("error = \(error)")
//            }

            if !database.executeStatements(sqlQuery) {
                print(database.lastError(), database.lastErrorMessage())
            }

            self.database.commit()
            self.database.close()
        }
    }

    func fetchSessionQuestionsListFromDB(sessionId : String, activityId : String) -> NSMutableArray {
        let array:NSMutableArray = []

        if openDatabase() {
            self.database.beginTransaction()

            //Remove session id
//            let querySQL = "Select * from QAQuestions where ActivityId = ? AND SessionId = ? AND EventID = ? Order by QueCount DESC"
            let querySQL = "Select * from QAQuestions where ActivityId = ? AND EventID = ? Order by QueCount DESC, Time ASC"
            let results:FMResultSet? = database.executeQuery(querySQL, withArgumentsIn: [activityId, EventData.sharedInstance.eventId])
            
            while results?.next() == true {
                
                let model = Questions()
                model.queId = (results?.string(forColumn: "QueId"))!
                model.eventId = results?.string(forColumn: "EventID")
                model.queStr = results?.string(forColumn: "Question")
                model.queCount = Int((results?.string(forColumn: "QueCount"))!)!
                model.isUserLike = (results?.bool(forColumn: "isUserLike"))!
                model.timeStr = (results?.string(forColumn: "Time"))!
                model.activityId = results?.string(forColumn: "ActivityId")
                model.userId = (results?.string(forColumn: "AttendeeId"))!
                model.userNameStr = (results?.string(forColumn: "Name"))!
                
                array.add(model)
            }
            self.database.commit()
            database.close()
        }
        return array
    }
    
    func updateActivityQuestionsDataIntoDB(isLikes: Bool, questionCount:String, quesId : String, activityId : String) {
        
        if openDatabase() {
            let eventId = EventData.sharedInstance.eventId
            
            do {
                try database.executeUpdate("UPDATE QAQuestions SET isUserLike = ?, QueCount = ? WHERE QueId = ? AND ActivityId = ? AND EventID = ?", values: [isLikes, questionCount, quesId,activityId, eventId])
                
            } catch {
                print("error = \(error)")
            }
        }
        
        database.close()
    }
    
    func fetchCurrentActivity() -> NSArray {
        
        var array = [SessionsModel]()
        
        if openDatabase() {
            
            
            //Check activity status, currently activity is going on or not
            let results : FMResultSet = self.fetchActivityStatus()
            
            while results.next() == true {
                let model = SessionsModel()

                model.sessionId = results.string(forColumn: "SessionID")
                model.activitySessionId = results.string(forColumn: "ActivitySesssionId")
                model.activityId = results.string(forColumn: "ActivityID")
                model.activityName = results.string(forColumn: "ActivityName")
                model.agendaId = results.string(forColumn: "AgendaId")
                model.agendaName = results.string(forColumn: "AgendaName")
                model.startActivityDate = results.string(forColumn: "ActivityStartDate")
                model.endActivityDate = results.string(forColumn: "ActivityEndDate")
                model.sortActivityDate = results.string(forColumn: "SortActivityDate")
                model.location = results.string(forColumn: "Location")
                model.startTime = results.string(forColumn: "StartTime")
                model.endTime = results.string(forColumn: "EndTime")
                model.day = results.string(forColumn: "Day")
                model.isActive = true
                array.append(model)
            }
            database.close()
        }
        return array as NSArray
    }
    
    func fetchAllCurrentAndFutureActivity() -> NSArray {
        
        var array = [SessionsModel]()
        
        if openDatabase() {
            
            let (_, endDate) = self.getCurrentTime()
            //Check All current and future activity
            let sqlQuery = "Select * from Agenda WHERE ActivityEndDate > ? AND EventID = ? GROUP BY Activityid ORDER BY SortActivityDate DESC"
            let results : FMResultSet = database.executeQuery(sqlQuery, withArgumentsIn: [endDate, EventData.sharedInstance.eventId])
            
            while results.next() == true {
                let model = SessionsModel()
                
                model.sessionId = results.string(forColumn: "SessionID")
                model.activitySessionId = results.string(forColumn: "ActivitySesssionId")
                model.activityId = results.string(forColumn: "ActivityID")
                model.activityName = results.string(forColumn: "ActivityName")
                model.agendaId = results.string(forColumn: "AgendaId")
                model.agendaName = results.string(forColumn: "AgendaName")
                model.startActivityDate = results.string(forColumn: "ActivityStartDate")
                model.endActivityDate = results.string(forColumn: "ActivityEndDate")
                model.sortActivityDate = results.string(forColumn: "SortActivityDate")
                model.location = results.string(forColumn: "Location")
                model.startTime = results.string(forColumn: "StartTime")
                model.endTime = results.string(forColumn: "EndTime")
                model.day = results.string(forColumn: "Day")
                model.isActive = true
                array.append(model)
            }
            database.close()
        }
        return array as NSArray
    }
    
    func fetchActivityStatus() -> FMResultSet {
        let eventId = EventData.sharedInstance.eventId
        
        let (dateStr, endDate) = self.getCurrentTime()

       // let sqlQuery = "Select * from Agenda WHERE (StartTime <= ? AND EndTime >= ?) AND SortActivityDate = ? AND EventID = ? ORDER BY SortActivityDate DESC"
        let sqlQuery = "Select * from Agenda WHERE ActivityStartDate < ? AND ActivityEndDate > ? AND SortActivityDate = ? AND EventID = ? ORDER BY SortActivityDate DESC"
        return database.executeQuery(sqlQuery, withArgumentsIn: [endDate, endDate,dateStr, eventId])
    }

    func checkCurrentActivityStatus(activityId : String, isDBClose : Bool) -> Bool {
        let eventId = EventData.sharedInstance.eventId
        var resultFlag = false
        if openDatabase() {
            
            let (dateStr, endDate) = self.getCurrentTime()
            
            let sqlQuery = "Select * from Agenda WHERE ActivityStartDate < ? AND ActivityEndDate > ? AND SortActivityDate = ? AND ActivityID = ? AND EventID = ? ORDER BY SortActivityDate DESC"
            let results : FMResultSet = database.executeQuery(sqlQuery, withArgumentsIn: [endDate, endDate, dateStr, activityId, eventId])
            
            while results.next() == true {
                if activityId == results.string(forColumn: "ActivityID") {
                    resultFlag = true
                }
            }
            if isDBClose {
                database.close()
            }
        }

        return resultFlag
    }
    
    // MARK: - Attendees methods
    
    func saveAttendeesDataIntoDB(responce: AnyObject) {
        
        if openDatabase() {
            database.beginTransaction()
            let eventId = EventData.sharedInstance.eventId
            
            //Delete local data which is deleted from admin
            do {
                try database.executeUpdate("DELETE FROM Attendees WHERE EventID = ?", values: [eventId])
                
            } catch {
                print("error = \(error)")
            }
            
            var sqlQuery = ""
            
            for item in responce as! NSArray {
                
                let  dict = item as! NSDictionary
                let attendeeId = dict.value(forKey: "AttendeeId") as! String
                let name = self.isNullString(str: dict.value(forKey: "Name") as Any)
                let address = self.isNullString(str: dict.value(forKey: "Address") as Any)
                let designation = self.isNullString(str: dict.value(forKey: "Designation") as Any)
                //print("Attendee name :  , Profile :  , DND :  \n",name, dict.value(forKey: "IsVisible"),dict.value(forKey: "IsDND"))
                
                var pSetting = 1
                if (dict.value(forKey: "IsVisible") as? NSNull) == nil {
                    pSetting = dict.value(forKey: "IsVisible") as! Int
                }
                let phoneNo = self.isNullString(str: dict.value(forKey: "Mobile") as Any)
                // var iconurl = self.appendImagePath(path: dict.value(forKey: "ImgPath") as Any)
                let email = self.isNullString(str: dict.value(forKey: "Email") as Any)
                let description = self.isNullString(str: dict.value(forKey: "Description") as Any)
                
                var iconurl = ""
                if pSetting == 1 || attendeeId == AttendeeInfo.sharedInstance.attendeeId {
                    iconurl = self.appendImagePath(path: dict.value(forKey: "ImgPath") as Any)
                }
                var dndSetting = 0
                if (dict.value(forKey: "IsDND") as? NSNull) == nil {
                    dndSetting = dict.value(forKey: "IsDND") as! Int
                }
                
                sqlQuery += "INSERT OR REPLACE INTO Attendees (EventID, attendeeID, name, address, phoneNo, iconurl, designation, description, email, PrivacySetting, DNDSetting) VALUES ('\(eventId)', '\(attendeeId)', \"\(name)\", \"\(address)\", '\(phoneNo)','\(iconurl)', \"\(designation)\",\"\(description)\",'\(email)',\(pSetting),\(dndSetting));"
                
            }
            if !database.executeStatements(sqlQuery) {
               // print(database.lastError(), database.lastErrorMessage())
            }
            
            database.commit()
            database.close()
        }
    }
    
    func fetchAttendeesDataFromDB() -> NSArray {
        var array = [PersonModel]()
        
        if openDatabase() {
            database.beginTransaction()

            let querySQL = "Select * from Attendees where EventID = ? AND attendeeID NOT in ( ? )"
            let results:FMResultSet? = database.executeQuery(querySQL, withArgumentsIn: [EventData.sharedInstance.eventId, EventData.sharedInstance.attendeeId])
            
            while results?.next() == true {
                
                let model = PersonModel()
                model.personId = results?.string(forColumn: "attendeeID")
                model.name = results?.string(forColumn: "name")
                model.contactNo = results?.string(forColumn: "phoneNo")
                model.designation = results?.string(forColumn: "designation")
                model.bioInfo = results?.string(forColumn: "description")
                model.email = results?.string(forColumn: "email")
                model.address = results?.string(forColumn: "address")
                model.iconUrl = results?.string(forColumn: "iconUrl")
                model.privacySetting = (results?.bool(forColumn: "PrivacySetting"))!
                model.dndSetting = (results?.bool(forColumn: "DNDSetting"))!
                model.isSpeaker = false

                let sqlQ = "Select * from Speaker where EventID = ? AND AttendeeId = ?"
                let results1:FMResultSet? = database.executeQuery(sqlQ, withArgumentsIn: [EventData.sharedInstance.eventId, model.personId, model.name])
                
                while results1?.next() == true {
                   model.isSpeaker = true
                    model.speakerId = results1?.string(forColumn: "SpeakerId")
                }
                
                array.append(model)
            }
            database.commit()
            database.close()
        }
        return array as NSArray
    }
    
    
    func fetchAllContactDataFromDB() -> NSArray {
        
        var array:[ChatGroupModel] = []

        if openDatabase() {
            
            let querySQL = "Select * from Attendees where EventID = ? AND attendeeID NOT in ( ? ) AND DNDSetting = ?"
            let results:FMResultSet? = database.executeQuery(querySQL, withArgumentsIn: [EventData.sharedInstance.eventId, EventData.sharedInstance.attendeeId, false])
            
            while results?.next() == true {
                
                let model = ChatGroupModel()
                model.groupId = results?.string(forColumn: "attendeeID")
                model.fromId = results?.string(forColumn: "attendeeID")
                model.name = results?.string(forColumn: "name")
                model.iconUrl = results?.string(forColumn: "iconUrl")
                model.dndSetting = (results?.bool(forColumn: "DNDSetting"))!
                model.visibilitySetting = (results?.bool(forColumn: "PrivacySetting"))!
                model.isGroupChat = false
                array.append(model)
            }
            database.close()
        }
        return array as NSArray
    }
    
    func fetchAddNewMemberContactsDataFromDB(ids : String) -> NSArray {
        var array = [ChatGroupModel]()
        
        if openDatabase() {
            
            //            let querySQL = "Select * from Attendees where EventID = ? AND attendeeID NOT in ( ? ) "
            // let querySQL = "Select * from Attendees where EventID = ? AND attendeeID NOT in ( ? ) AND DNDSetting = ? ORDER BY name ASC"
            
            let querySQL = "Select * from Attendees where EventID = '\(EventData.sharedInstance.eventId)' AND attendeeID NOT in ( \(ids) ) AND DNDSetting = \(0) ORDER BY name ASC"
            
            let results:FMResultSet? = database.executeQuery(querySQL, withArgumentsIn: [])
            
            while results?.next() == true {
                
                let model = ChatGroupModel()
                model.groupId = results?.string(forColumn: "attendeeID")
                model.fromId = results?.string(forColumn: "attendeeID")
                model.name = results?.string(forColumn: "name")
                model.iconUrl = results?.string(forColumn: "iconUrl")
                model.dndSetting = (results?.bool(forColumn: "DNDSetting"))!
                model.isGroupChat = false
                array.append(model)
            }
            database.close()
        }
        return array as NSArray
    }
    // MARK: - Speakers methods

    func saveSpeakersDataIntoDB(responce: AnyObject) {
        
        if openDatabase() {
            self.database.beginTransaction()

            let eventId = EventData.sharedInstance.eventId
            //Delete local data which is deleted from admin
            do {
                try database.executeUpdate("DELETE FROM Speaker WHERE EventID = ?", values: [eventId])
                
            } catch {
                print("error = \(error)")
            }
            var sqlQuery = ""

            for item in responce as! NSArray {
                                let  dict = item as! NSDictionary
                let sId =  self.isNullString(str: dict.value(forKey: "Id") as Any).lowercased()
                let name = self.isNullString(str: dict.value(forKey: "Name") as Any)
                let attendeeId = self.isNullString(str: dict.value(forKey: "AttendeeId") as Any).lowercased()

                //                    let id = self.isNullString(str: dict.value(forKey: "SpeakerID") as Any)
                //                    let name = self.isNullString(str: dict.value(forKey: "Name") as Any)
                //                    let designation = self.isNullString(str: dict.value(forKey: "Designation") as Any)
                //                    let description = self.isNullString(str: dict.value(forKey: "Description") as Any)
                //                    let email = self.isNullString(str: dict.value(forKey: "SpeakerEmail") as Any)
                //                    let address = self.isNullString(str: dict.value(forKey: "SpeakerAddress") as Any)
                //                    let phoneNo = self.isNullString(str: dict.value(forKey: "ContactNo") as Any)
                //                    let iconurl = self.appendImagePath(path: dict.value(forKey: "ImgPath") as Any)
                //                    try database.executeUpdate("INSERT OR REPLACE INTO Speaker (EventID, id, Name, Description, Designation, Iconurl, ContactNo, Email, Address) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)", values: [eventId, id, name, description, designation, iconurl, phoneNo, email , address ])

                sqlQuery +=  "INSERT OR REPLACE INTO Speaker (EventID, SpeakerId, Name, AttendeeID) VALUES ('\(eventId)', '\(sId)', \"\(name)\",'\(attendeeId)');"
                // try database.executeUpdate(sqlQuery, values: [])
            }

            if !database.executeStatements(sqlQuery) {
              //  print(database.lastError(), database.lastErrorMessage())
            }

            database.commit()
            database.close()
        }
    }
    
    func saveSpeakersActivityDataIntoDB(responce: AnyObject) {
        
        if openDatabase() {
            if responce is NSDictionary {
                
                do {
                    let  dict = responce as! NSDictionary
                    let id = dict.value(forKey: "SpeakerID") as! String
                    
                    //Check Acivity list
                    let activityList = dict.value(forKey: "Activity")
                    if (activityList as? NSNull) == nil {
                        for item in activityList as! NSArray {
                            do {
                                let  dict = item as! NSDictionary
                                
                                //let sessionId = dict.value(forKey: "Id")
                                let activityId = dict.value(forKey: "ActivityId") as! String
                                
                                //Save speaker id and activity id together in AgendaSpeakerRelation Table
                                try database.executeUpdate("insert or replace into AgendaSpeakerRelation (EventID, ActivityId, SpeakerId) VALUES (?, ?, ?)", values: [EventData.sharedInstance.eventId, activityId, id ])
                            }
                        }
                    }
                } catch {
                    print("error = \(error)")
                }
            }
        }
        
        database.close()
    }

    func updateSpeakersDetailsIntoDB(responce: AnyObject) {
        
        if openDatabase() {
            let eventId = EventData.sharedInstance.eventId

            do {
                let  dict = responce as! NSDictionary
                let id = self.isNullString(str: dict.value(forKey: "SpeakerID") as Any)
                let name = self.isNullString(str: dict.value(forKey: "Name") as Any)
                let designation = self.isNullString(str: dict.value(forKey: "Designation") as Any)
                let description = self.isNullString(str: dict.value(forKey: "Description") as Any)
                let email = self.isNullString(str: dict.value(forKey: "SpeakerEmail") as Any)
                let address = self.isNullString(str: dict.value(forKey: "SpeakerAddress") as Any)
                let phoneNo = self.isNullString(str: dict.value(forKey: "ContactNo") as Any)
                let iconurl = self.appendImagePath(path:dict.value(forKey: "ImgPath")  as Any)

                try database.executeUpdate("UPDATE Speaker SET id = ?, Name = ?, Description = ?, Designation = ?, Iconurl = ?, ContactNo = ?, Email = ?, Address = ? WHERE id = ? AND EventID = ?", values: [id, name, description, designation, iconurl, phoneNo, email , address , eventId])
                
            } catch {
                print("error = \(error)")
            }
            database.close()
        }
    }
    
    func fetchAllSpeakersDataFromDB() -> NSArray {
        var array = [PersonModel]()
        
        if openDatabase() {
            //Check activity status, currently activity is going on or not
//            let activeSpeakers:FMResultSet = self.fetchActivityStatus()
//            var activityIdStr : String = ""
//            while activeSpeakers.next() == true {
//                activityIdStr = activityIdStr.appending(activeSpeakers.string(forColumn: "ActivityID"))
//            }
//
//            var speakers = [PersonModel]()
//            if activeSpeakers.next() == true {
//                //Fetch speakers list of activity
//                speakers = self.fetchSpeakersOfActivityDataFromDB(activityId: (activeSpeakers.string(forColumn: "ActivityID"))!) as! [PersonModel]
//            }

//            let querySQL = "Select * from Speaker where EventID = ?"
//            let results:FMResultSet? = database.executeQuery(querySQL, withArgumentsIn: [EventData.sharedInstance.eventId])
//            while results?.next() == true {
//                let model = PersonModel()
//                model.personId = results?.string(forColumn: "id")
//                model.name = results?.string(forColumn: "Name")
//                model.contactNo = results?.string(forColumn: "ContactNo")
//                model.designation = results?.string(forColumn: "Designation")
//                model.bioInfo = results?.string(forColumn: "Description")
//                model.email = results?.string(forColumn: "Email")
//                model.address = results?.string(forColumn: "Address")
//                model.iconUrl = results?.string(forColumn: "Iconurl")
//                model.isActiveSpeaker = false
//
//                let filteredArr = speaker.filter({( model1 : PersonModel) -> Bool in
//                    return model1.personId.contains(model.personId)
//                })
//                if filteredArr.count != 0 {
//                    model.isActiveSpeaker = true
//                }
//                array.append(model)
//            }
            
            
            //Fetch speaker id from speaker table and Fetch Speaker details from Attendee table
            let sqlQuery = "Select Attendees.* , Speaker.SpeakerId from Attendees JOIN Speaker ON Attendees.attendeeID = Speaker.AttendeeID  where Attendees.attendeeID in (Select Speaker.AttendeeID from Speaker where Speaker.EventID = \'\(EventData.sharedInstance.eventId)') AND Attendees.EventID = \'\(EventData.sharedInstance.eventId)' ORDER BY Attendees.name ASC"
            
            let results:FMResultSet? = database.executeQuery(sqlQuery, withArgumentsIn: nil)

            while results?.next() == true {
                let model = PersonModel()
                model.speakerId = results?.string(forColumn: "SpeakerId")
                model.personId = results?.string(forColumn: "attendeeID")
                model.name = results?.string(forColumn: "name")
                model.contactNo = results?.string(forColumn: "phoneNo")
                model.designation = results?.string(forColumn: "designation")
                model.bioInfo = results?.string(forColumn: "description")
                model.email = results?.string(forColumn: "email")
                model.address = results?.string(forColumn: "address")
                model.iconUrl = results?.string(forColumn: "iconUrl")
                model.privacySetting = (results?.bool(forColumn: "PrivacySetting"))!
                model.dndSetting = (results?.bool(forColumn: "DNDSetting"))!
                model.isActiveSpeaker = false
                
                let (dateStr, endDate) = self.getCurrentTime()
                
                let sqlQuery = "Select * from Agenda WHERE ActivityStartDate < ? AND ActivityEndDate > ? AND SortActivityDate = ? AND ActivityID in ( Select ActivityId from AgendaSpeakerRelation where SpeakerId = ? AND EventID = ? ) AND EventID = ? ORDER BY SortActivityDate DESC"
                let activityResults : FMResultSet? = database.executeQuery(sqlQuery, withArgumentsIn: [endDate, endDate, dateStr, model.speakerId, EventData.sharedInstance.eventId, EventData.sharedInstance.eventId])

//                let activitySqlQuery = "Select ActivityId from AgendaSpeakerRelation where SpeakerId = ? AND EventID = ?"
//                let activityResults:FMResultSet? = database.executeQuery(activitySqlQuery, withArgumentsIn: [model.speakerId, EventData.sharedInstance.eventId])
                while activityResults?.next() == true {
                        model.isActiveSpeaker = true

                    //model.isActiveSpeaker = self.checkCurrentActivityStatus(activityId: (activityResults.string(forColumn: "ActivityId"))!, isDBClose: false)
                }

                array.append(model)
            }
        }
        database.close()

        return array as NSArray
    }
    
    func fetchSpeakersDetailsFromDB(speakerId: String, attendeeId : String) -> PersonModel {
        let model = PersonModel()
        
        if openDatabase() {
            
            var querySQL = ""
            if attendeeId == "" {
                querySQL = "Select * from Attendees where attendeeID in (Select AttendeeId from Speaker where SpeakerId = '\(speakerId )' AND EventID = \'\(EventData.sharedInstance.eventId)') AND EventID = \'\(EventData.sharedInstance.eventId)'"
            }
            else {
                querySQL = "Select * from Attendees where attendeeID = '\(attendeeId )' AND EventID = \'\(EventData.sharedInstance.eventId)'"
            }
            
            let results:FMResultSet? = database.executeQuery(querySQL, withArgumentsIn: nil)

            while results?.next() == true {
                model.speakerId = speakerId
                model.personId = results?.string(forColumn: "attendeeID")
                model.name = results?.string(forColumn: "name")
                model.contactNo = results?.string(forColumn: "phoneNo")
                model.designation = results?.string(forColumn: "designation")
                model.bioInfo = results?.string(forColumn: "description")
                model.email = results?.string(forColumn: "email")
                model.address = results?.string(forColumn: "address")
                model.iconUrl = results?.string(forColumn: "iconUrl")
                model.privacySetting = (results?.bool(forColumn: "PrivacySetting"))!
                model.dndSetting = (results?.bool(forColumn: "DNDSetting"))!
                
                //Fetch activity associated with speakers
                model.activities = self.fetchActiviesOfSpeakerFromDB(speakerId: speakerId) as! [AgendaModel]
            }
            database.close()
        }
        return model
    }
    

    // MARK: - Agenda and Speaker Relation methods

    func fetchSpeakersOfActivityDataFromDB(activityId : String) -> NSArray {
        
        var array = [PersonModel]()
        
        if openDatabase() {
            
            let eventId = EventData.sharedInstance.eventId

            //Fetch speaker id
            let sqlQuery = "Select Attendees.* , Speaker.SpeakerId from Attendees JOIN Speaker ON Attendees.attendeeID = Speaker.AttendeeID  where Attendees.attendeeID in ( Select AttendeeID from Speaker where SpeakerId in (Select SpeakerId from AgendaSpeakerRelation where ActivityId = \'\(activityId)' AND EventID = \'\(EventData.sharedInstance.eventId)') AND EventID = \'\(eventId)') AND Attendees.EventID = \'\(EventData.sharedInstance.eventId)' ORDER BY Attendees.name ASC"
            let results:FMResultSet? = database.executeQuery(sqlQuery, withArgumentsIn: nil)
            
            while results?.next() == true {
                let model = PersonModel()
                model.speakerId = results?.string(forColumn: "SpeakerId")
                model.personId = results?.string(forColumn: "attendeeID")
                model.name = results?.string(forColumn: "name")
                model.contactNo = results?.string(forColumn: "phoneNo")
                model.designation = results?.string(forColumn: "designation")
                model.bioInfo = results?.string(forColumn: "description")
                model.email = results?.string(forColumn: "email")
                model.address = results?.string(forColumn: "address")
                model.iconUrl = results?.string(forColumn: "iconUrl")
                model.privacySetting = (results?.bool(forColumn: "PrivacySetting"))!
                model.dndSetting = (results?.bool(forColumn: "DNDSetting"))!
                model.isActiveSpeaker = false
                array.append(model)
            }
        }
        return array as NSArray
    }
    
    func fetchActiviesOfSpeakerFromDB(speakerId : String) -> NSArray {
        
        let array: NSMutableArray = []
        
        if openDatabase() {

            let sqlQuery = "Select * from Agenda where ActivityID in (Select ActivityId from AgendaSpeakerRelation where SpeakerId = \'\(speakerId)' AND EventID = \'\(EventData.sharedInstance.eventId)') AND EventID = \'\(EventData.sharedInstance.eventId)' GROUP BY ActivityID ORDER BY ActivityStartDate DESC"
            
            let results:FMResultSet? = database.executeQuery(sqlQuery, withArgumentsIn: nil)
            
            while results?.next() == true {
                
                let model = AgendaModel()
                model.sessionId = results?.string(forColumn: "SessionID")
                model.activitySessionId = results?.string(forColumn: "ActivitySessionId")
                model.activityId = results?.string(forColumn: "ActivityID")
                model.activityName = results?.string(forColumn: "ActivityName")
                model.agendaId = results?.string(forColumn: "AgendaId")
                model.agendaName = results?.string(forColumn: "AgendaName")
                model.startActivityDate = results?.string(forColumn: "ActivityStartDate")
                model.endActivityDate = results?.string(forColumn: "ActivityEndDate")
                model.sortStartDate = results?.string(forColumn: "SortStartDate")
                model.sortEndDate = results?.string(forColumn: "SortEndDate")
                model.sortDate = results?.string(forColumn: "SortActivityDate")
                model.location = results?.string(forColumn: "Location")
                model.startTime = results?.string(forColumn: "StartTime")
                model.endTime = results?.string(forColumn: "EndTime")
                model.day = results?.string(forColumn: "Day")
                model.isAddedToSchedule = (results?.bool(forColumn: "isUserSchedule"))!
                
                array.add(model)
            }
        }
        return array as NSArray
    }

    // MARK: - Agenda/MySchedule methods
    
    func saveAgendaDataIntoDB(responce: AnyObject) {

        if openDatabase() {
            
            database.beginTransaction()
            let eventId = EventData.sharedInstance.eventId
            //Delete local data which is deleted from admin
            do {
                try database.executeUpdate("DELETE FROM Agenda WHERE EventID = ?", values: [eventId])
                
            } catch {
                print("error = \(error)")
            }
            
            for item in responce as! NSArray {
                let  dict = item as! NSDictionary
                
                let activityId = dict.value(forKey: "ActivityId") as! String
                let sessionId = dict.value(forKey: "Session") as! Int
                let activitySessionId = String(format: "%@-%d", activityId, sessionId)
                
                let activityName = self.isNullString(str: dict.value(forKey: "ActivityName") as Any)
                //Remove UTC - Change Shital on 15 Dec
//                let startTime = CommonModel.sharedInstance.UTCToLocalDate(date: dict.value(forKey: "StartTime") as! String)
//                let endTime = CommonModel.sharedInstance.UTCToLocalDate(date: dict.value(forKey: "EndTime") as! String)
//                let endActivityDate = CommonModel.sharedInstance.UTCToLocalDate(date: dict.value(forKey: "EndDate") as! String)
//                let startDate =  CommonModel.sharedInstance.UTCToLocalDate(date:dict.value(forKey: "StartDate") as! String)
//                let endDate = CommonModel.sharedInstance.UTCToLocalDate(date: dict.value(forKey: "EndDate") as! String)
//                let sDate = String(format:"%@T%@",self.isNullString(str: dict.value(forKey: "ActivityStartDate") as Any),dict.value(forKey: "StartTime") as! CVarArg)
//                let sortStartDate = CommonModel.sharedInstance.UTCToLocalDate(date: sDate)
//                let eDate = String(format:"%@T%@",self.isNullString(str: dict.value(forKey: "ActivityStartDate") as Any),dict.value(forKey: "EndTime") as! CVarArg)
//                let sortEndDate = CommonModel.sharedInstance.UTCToLocalDate(date: eDate)
                
                let startTime = self.isNullString(str:dict.value(forKey: "StartTime") as Any)
                let endTime = self.isNullString(str:dict.value(forKey: "EndTime") as Any)
                let startActivityDate =  self.isNullString(str:dict.value(forKey: "StartDate") as Any)
                let endActivityDate = self.isNullString(str:dict.value(forKey: "EndDate") as Any)
               // let endDate = self.isNullString(str: dict.value(forKey: "EndDate") as Any)
                let agendaId = self.isNullString(str: dict.value(forKey: "AgendaId") as Any)
                let agendaName = self.isNullString(str: dict.value(forKey: "AgendaName") as Any)
                let location = self.isNullString(str: dict.value(forKey: "Location") as Any)
              //  let startActivityDate = self.isNullString(str: dict.value(forKey: "ActivityStartDate") as Any)
                let day = self.isNullString(str: dict.value(forKey: "Day") as Any)
                let description = self.isNullString(str: dict.value(forKey: "Description") as Any)
                let sortStartDate = String(format:"%@T%@",self.isNullString(str: dict.value(forKey: "SortActivityDate") as Any),dict.value(forKey: "StartTime") as! CVarArg)
                let sortEndDate = String(format:"%@T%@",self.isNullString(str: dict.value(forKey: "SortActivityDate") as Any),dict.value(forKey: "EndTime") as! CVarArg)
                let sortDate = self.isNullString(str: dict.value(forKey: "SortActivityDate") as Any)
                
                    if !self.database.executeUpdate("INSERT OR REPLACE INTO Agenda (EventID, SessionID, ActivitySessionId, ActivityID, ActivityName, AgendaId, AgendaName, Location, Day, Description, ActivityStartDate, ActivityEndDate, SortActivityDate, StartTime, EndTime, SortStartDate, SortEndDate) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", withArgumentsIn: [eventId, sessionId, activitySessionId, activityId, activityName, agendaId, (agendaName), location, day, description, startActivityDate, endActivityDate, sortDate, startTime, endTime, sortStartDate, sortEndDate]) {
                    print("Failed to insert initial data into the database.")
                    print(self.database.lastError(), self.database.lastErrorMessage())
                }
                
                //Save Speaker of the session into db
                let speakersList = dict.value(forKey: "Speakers")
                if (speakersList as? NSNull) == nil {
                    
                    //Remove exiting speakers of this activity then add new speaker list
                    do {
                        try database.executeUpdate("DELETE FROM AgendaSpeakerRelation WHERE EventID = ? AND ActivityId = ?", values: [eventId, activityId])
                        
                    } catch {
                        print("error = \(error)")
                    }
                    
                    if speakersList is Array<Any> {
                        for item in speakersList as! NSArray {
                            do {
                                if item is NSDictionary {
                                    let  dict = item as! NSDictionary
                                    let speakerId = self.isNullString(str: dict.value(forKey: "SpeakerID") as Any)
                                    try database.executeUpdate("insert or replace into AgendaSpeakerRelation (EventID, ActivityId, SpeakerId) VALUES (?, ?, ?)", values: [eventId, activityId, speakerId ])
                                }
                            } catch {
                                print("error = \(error)")
                            }
                        }
                    }
                }
            }
        }
        database.commit()
        database.close()
    }

    func fetchAllScheduleListFromDB(isAddedMySchedule: Bool) -> NSArray {
        
        let array: NSMutableArray = []
        
        if openDatabase() {
            database.beginTransaction()

            let results : FMResultSet!
            let eventId = EventData.sharedInstance.eventId
            let attendeeId = EventData.sharedInstance.attendeeId
            
            var sqlQuery = ""
            if isAddedMySchedule {
                sqlQuery = "Select * from Agenda where EventID = \'\(eventId)' AND ActivitySessionId in (Select ActivitySessionId from MySchedule where AttendeeId = \'\(attendeeId)' AND EventID = \'\(EventData.sharedInstance.eventId)' AND isUserSchedule = '1') ORDER BY ActivityStartDate ASC"

                results = database.executeQuery(sqlQuery, withArgumentsIn: [isAddedMySchedule, eventId])
            }
            else {
                sqlQuery = "Select * from Agenda where EventID = ? ORDER BY ActivityStartDate ASC"
                results = database.executeQuery(sqlQuery, withArgumentsIn: [eventId])
            }
            
            while results?.next() == true {
                
                let model = AgendaModel()
                model.sessionId = results.string(forColumn: "SessionID")
                model.activitySessionId = results.string(forColumn: "ActivitySessionId")
                model.activityId = results.string(forColumn: "ActivityID")
                model.activityName = results.string(forColumn: "ActivityName")
                model.agendaId = results.string(forColumn: "AgendaId")
                model.agendaName = results.string(forColumn: "AgendaName")
                model.startActivityDate = results.string(forColumn: "ActivityStartDate")
                model.endActivityDate = results.string(forColumn: "ActivityEndDate")
                model.sortDate = results.string(forColumn: "SortActivityDate")
                model.location = results.string(forColumn: "Location")
                model.startTime = results.string(forColumn: "StartTime")
                model.endTime = results.string(forColumn: "EndTime")
                model.day = results.string(forColumn: "Day")
                model.descText = results.string(forColumn: "Description")
                model.sortStartDate = results.string(forColumn: "SortStartDate")
                model.sortEndDate = results.string(forColumn: "SortEndDate")
//                model.isAddedToSchedule = results.bool(forColumn: "isUserSchedule")
                model.isAddedToSchedule = self.checkIsActivityAddeddInMySchedule(activitySessionId: model.activitySessionId)
                 model.activityStatus = false
                
                //Fetch speakers list of activity
                model.speakers = self.fetchSpeakersOfActivityDataFromDB(activityId: model.activityId) as! [PersonModel]

                //Check activity status, currently activity is going on or not
                //model.activityStatus = self.fetchActivityStatus().next() == true ? true : false
                let (dateStr, _) = self.getCurrentTime()
                
                let activityId = model.activityId as String
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm:ss"
                let currentTime = dateFormatter.string(from: Date())
                let sqlQuery = "Select * from Agenda WHERE (StartTime <= '\(currentTime)' AND EndTime >= '\(currentTime)' AND SortActivityDate = '\(dateStr)') AND ActivityID = '\(activityId)' AND EventID = '\(eventId)' ORDER BY SortActivityDate DESC"
                let results1 : FMResultSet = database.executeQuery(sqlQuery, withArgumentsIn: [])
                while results1.next() == true {
                    if results.string(forColumn: "SortActivityDate") == dateStr {
                        model.activityStatus = true
                    }
                }
                array.add(model)
            }
            database.commit()
            database.close()
        }
        return array as NSArray
    }
    
    
    func fetchActivityDetailsFromDB(activitySessionId: String) -> AgendaModel {
        
        let model = AgendaModel()

        if openDatabase() {
            let results : FMResultSet!
            
            let sqlQuery = "Select * from Agenda Where ActivitySessionId = ? AND EventID = ?"
            results = database.executeQuery(sqlQuery, withArgumentsIn: [activitySessionId, EventData.sharedInstance.eventId])
            
            while results?.next() == true {
                
                model.sessionId = results.string(forColumn: "SessionID")
                model.activitySessionId = results.string(forColumn: "ActivitySessionId")
                model.activityId = results.string(forColumn: "ActivityID")
                model.activityName = results.string(forColumn: "ActivityName")
                model.agendaId = results.string(forColumn: "AgendaId")
                model.agendaName = results.string(forColumn: "AgendaName")
                model.startActivityDate = results.string(forColumn: "ActivityStartDate")
                model.endActivityDate = results.string(forColumn: "ActivityEndDate")
                model.sortDate = results.string(forColumn: "SortActivityDate")
                model.location = results.string(forColumn: "Location")
                model.startTime = results.string(forColumn: "StartTime")
                model.endTime = results.string(forColumn: "EndTime")
                model.day = results.string(forColumn: "Day")
                model.descText = results.string(forColumn: "Description")
                model.sortStartDate = results.string(forColumn: "SortStartDate")
                model.sortEndDate = results.string(forColumn: "SortEndDate")
                model.isAddedToSchedule = self.checkIsActivityAddeddInMySchedule(activitySessionId: model.activitySessionId) //results.bool(forColumn: "isUserSchedule")
                
                //Check Current activities
                let activityId = model.activityId as String
                let (_, endDate) = self.getCurrentTime()
                let sqlQuery = "Select * from Agenda WHERE ActivityStartDate < '\(endDate)' AND ActivityEndDate > '\(endDate)' AND ActivityID = '\(activityId)' AND EventID = '\(EventData.sharedInstance.eventId)' ORDER BY SortActivityDate DESC"
                let results1 : FMResultSet = database.executeQuery(sqlQuery, withArgumentsIn: [])
                while results1.next() == true {
                    model.activityStatus = true
                    model.isFutureActivity = false
                }

                //Check future activities
                let sqlQuery1 = "Select * from Agenda WHERE ActivityStartDate > '\(endDate)' AND ActivityID = '\(activityId)' AND EventID = '\(EventData.sharedInstance.eventId)' ORDER BY SortActivityDate DESC"
                let results2 : FMResultSet = database.executeQuery(sqlQuery1, withArgumentsIn: [])
                while results2.next() == true {
                    model.isFutureActivity = true
                    model.activityStatus = false
                }
                
                //Fetch speakers list of activity
                model.speakers = self.fetchSpeakersOfActivityDataFromDB(activityId: model.activityId) as! [PersonModel]
                
            }
            database.close()
        }
        
        return model
    }

    func addToMyScheduleDataIntoDB(model: AgendaModel) {
        
        if openDatabase() {
            
            do {

                try database.executeUpdate("insert or replace into MySchedule (EventID, SessionID, ActivitySessionId, ActivityID,  AttendeeId, isUserSchedule) VALUES (?, ?, ?, ?, ?, ?)", values: [EventData.sharedInstance.eventId, model.sessionId,  model.activitySessionId, model.activityId,  EventData.sharedInstance.attendeeId,model.isAddedToSchedule] )
            } catch {
                print("error = \(error)")
            }
        }
        database.close()
    }
    
    func checkIsActivityAddeddInMySchedule(activitySessionId : String ) -> Bool {
        
        var querySQL = ""
        let results : FMResultSet!
        querySQL = "Select isUserSchedule from MySchedule WHERE ActivitySessionId = ? AND EventID = ? AND AttendeeId = ?"
        results = database.executeQuery(querySQL, withArgumentsIn: [activitySessionId, EventData.sharedInstance.eventId,EventData.sharedInstance.attendeeId])
        while results?.next() == true {
            return results.bool(forColumn: "isUserSchedule")
        }
        return false
    }

    func fetchMyScheduleListFromDB(sessionId: String, activitySessionId : String ) -> Bool {
        
        var querySQL = ""
        let results : FMResultSet!
        querySQL = "Select isUserSchedule from Agenda WHERE ActivitySessionId = ? AND EventID = ?"
        results = database.executeQuery(querySQL, withArgumentsIn: [sessionId, EventData.sharedInstance.eventId])
        while results?.next() == true {
            return results.bool(forColumn: "isUserSchedule")
        }
        return false
    }

    
    func fetchActivityNameFromDB(activityId: String) -> String {
        
        var activityName = ""
        if openDatabase() {
            let results : FMResultSet!
            
            let sqlQuery = "Select ActivityName from Agenda Where ActivityId = ? AND EventID = ?"
            results = database.executeQuery(sqlQuery, withArgumentsIn: [activityId, EventData.sharedInstance.eventId])
            
            while results?.next() == true {
                activityName = results.string(forColumn: "ActivityName")
            }
            database.close()
        }
        
        return activityName
    }
    
  /*  func fetchEventDatesFromDB() -> NSArray {
        let array: NSMutableArray = []
        
        if openDatabase() {
            
            var querySQL = ""
            let results : FMResultSet!
            querySQL = "Select distinct SortActivityDate from Agenda Where EventID = ? ORDER BY ActivityStartDate asc"
            //            results = database.executeQuery(querySQL, withArgumentsIn: [EventData.sharedInstance.eventId])
            //
            //            while results?.next() == true {
            //                array.add(results.string(forColumn: "SortActivityDate"))
            //            }
            // querySQL = "Select distinct SortActivityDate, SortStartDate from Agenda Where EventID = ? ORDER BY SortStartDate asc"
            results = database.executeQuery(querySQL, withArgumentsIn: [EventData.sharedInstance.eventId])
            
            while results?.next() == true {
                array.add(results.string(forColumn: "SortActivityDate"))
            }
        }
        database.close()
        
        return array
    }

    func fetchEventDayFromDB() -> NSArray {
        let array: NSMutableArray = []
        
        if openDatabase() {
            
            var querySQL = ""
            let results : FMResultSet!
            
            //querySQL = "Select distinct SortActivityDate, Day from Agenda Where EventID = ? ORDER BY StartDate asc"
            querySQL = "Select distinct SortActivityDate, Day from Agenda Where EventID = ? ORDER BY SortActivityDate asc"
            results = database.executeQuery(querySQL, withArgumentsIn: [EventData.sharedInstance.eventId])
            
            while results?.next() == true {
                array.add(results.string(forColumn: "Day"))
            }
        }
        database.close()
        
        return array
    }
    */
    
    func appendImagePath(path : Any) -> String {
        
        if (path as? NSNull) == nil {
            if path as! String == "" {
                return path as! String
            }
            return BASE_URL.appending(path as! String)

//            return BASE_URL.appending(path as! String).appendingFormat("&token=%@", EventData.sharedInstance.auth_token)
        }
        
        return ""
    }

    
//    func trimImagePath(path : Any) -> Any {
//        
//        if (path as? NSNull) == nil {
//            let pathStr = path as! String
//            return BASE_URL.appending(pathStr.replacingOccurrences(of: "../", with: "", options: .literal, range: nil))
//        }
//
//        return ""
//    }
    
    func isNullString(str : Any) -> String {
        
        if (str as? NSNull) == nil {
            return (str as? String)!
        }
        
        return ""
    }

}
