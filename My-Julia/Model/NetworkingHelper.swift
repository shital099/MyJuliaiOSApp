
//
//  AFNetworkingHelper.swift
//  My-Julia
//  n
//  Created by GCO on 4/11/17. 
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit

//BASE URL AND Auth Key
//let BASE_URL = "http://srv01:2300/" 

//let BASE_URL = "http://srv01.gcotechcenter.local:1400/"  //SRV 1
let BASE_URL = "http://srv01.gcotechcenter.local:2400/"     //SRV 2
//let BASE_URL = "https://apps.gcotechcenter.com/"

//let BASE_URL = "http://srv01.gcotechcenter.local:5400/"     //Production4

//TEST Enviorment
//let BASE_URL = "http://srv01.gcotechcenter.local:3400/"     //TEST Enviorment
//let BASE_URL = "https://ems2-test.gcoeurope.com:3000/"     //TEST Enviorment

//let BASE_URL = "https://apps.gcoeurope.com/Julia/"      //LIVE Enviorment
//let BASE_URL = "http://roshan.gcotechcenter.local:8000/"

/***** API'S *******/

//Timezone
let Update_Timezone = "api/AttendeeMaster/AttendeeTimeZone/"

/* Home */
let Search_Event_Url = "api/account/GetEventList"
let Event_Details_Url = "api/module/eventdetails/"
let Get_AuthToken_Url = "api/account/login"
let Get_ValidateOTP_Url = "api/account/ValidateOTP"
let Post_ResendOTP_Url = "api/account/ResendOTP"

let Home_url = "api/module/home/"
let Logout_Url = "api/account/logout"

//let Event_Details_Url = "api/module/AllDetails/"admin@123
let Get_Login_Details_Url = "api/module/SPGetAllDetails/"
let Get_TermsAndCondition_Url = "api/Event/GetTermsConditions/"
let Post_TermsAndCondition_Url = "api/Event/AddTermsConditions"
//let Get_AllModuleDetails_url = "api/Common/getAllEventDetails?"
let Get_AllModuleDetails_url = "api/Common/getEventAllDetailsSP?"

//All module Data
let Get_AllDetails_url = "GetAllData"


/* Agenda */
let Agenda_List_url = "api/Agenda/getAgendaByActivityId/"
let Agenda_Details_url = "api/SpeakerActivity/getActivityDetails/"

/* Attendee */
let Attendees_List_url = "Chat_Contacts" //"api/Chat/Contacts/"

/* Feedback */
let Feedback_List_url = "api/Feedback/getFeedbackByEventId/"
let Post_Feedback_Responce_url = "api/Feedback/AddMobilefeedback/"
let Check_User_Feedback_url = "api/Feedback/CheckFeedbackPost/"


/* Activity Feedback */
let Get_Activity_Feedback_List_url = "api/Feedback/getFeedbackByActivityId/"
let Post_Activity_Feedback_url = "api/Feedback/AddMobActivityFeedback"

/* Notification */
let Notification_List_url =  "Notifications_GetAll" //"api/Notifications/GetAll/"

/* Speakers */
//let Speakers_List_url = "api/Speaker/getSpeakers/"
let Speakers_Details_url = "api/SpeakerActivity/getSpeakerDetails/"

/* Sponsors */
//let Sponsors_List_url = "api/Sponsor/getByEvent/"

/* WiFi */
//let WiFi_List_url = "api/Wifi/WifiList/"

/* Local Info */
//let LocalInfo_List_url = "api/module/localinfo/"

/* Poll */
let GetPollActivities__url = "poll_GetPollActivities" //"api/poll/GetPollActivities/"
let GetPoll_Question_List_url =  "/api/Poll/GetActivityPollQuestions/"
let Post_Poll_Responce_url = "api/Poll/AddMobilePoll/"
let Get_Speaker_Activity_url = "api/poll/GetSpeackerActivity"
let Add_Poll_Speaker_Question = "api/Poll/AddPollQuestions"
let Post_Update_Poll_Question = "api/Poll/UpdatePoll"
let Get_Speaker_latest_Poll = "api/poll/GetSpeakerPollQuestions"

/* Map */
//let Map_List_url = "api/Map/getMapDetails/"

/* Activity Feed */
let ActivityFeed_List_url = "ActivityFeed_GetActivityFeeds" //"api/ActivityFeed/GetActivityFeeds/"
let Post_Activity_Feed_url = "api/ActivityFeed/AddMobActivityFeed/"
let Post_Activity_Comment_url = "api/ActivityFeed/PostComments/"
let Post_Activity_Like_url = "api/ActivityFeed/PostLikes/"
let Get_Comments_url = "api/ActivityFeed/GetComments/"
let Get_PostLikes_url = "api/ActivityFeed/GetActivityFeedLikes/"

/* Photo Gallery */
let PhotoGallery_List_url = "ImageGallery_Gallery" // "api/ImageGallery/Gallery/"

/* Emergency */
//let Emergency_List_url = "api/Emergency/EmergencyNos/"

/* Documents */
let Documents_List_url = "Document_GetAll"

/* Email */
let Email_List_url = "Email_GetEmails" //"api/Email/GetEmails/"

/* Website */
let Website_List_url = "Website_getByEventId" //"api/Website/getByEventId/"

/* User Profile */
//let Profile_List_url = "api/Profile/getUserProfile/"
let Post_Visiblity_url = "api/Profile/UpdateUserProfile"

/* Questions */
let GetQuestionActivities_url = "QA_GetQAActivities" //"api/QA/GetQAActivities/"
let GetQuestions_List_url = "api/QA/GetQuestions/"
let Get_Latest_Questions_List_url = "api/QA/GetQuestionsLatest"
let PostQuestion_List_url = "api/QA/add/"
let LikeQuestion_List_url = "api/QA/like/"

/* Chat */
let Chat_Contact_List = "Chat_ChatContacts" //"api/Chat/ChatContacts?"
let Chat_History = "api/chat/GetChatHistory"
let Chat_Group_History = "api/chat/GetGroupChatHistory"
let Chat_Post_Message = "api/chat/PostChatMessage/"
let Chat_Refresh_Chat_history = "api/chat/GetChatHistoryOnTime"
//let Chat_All_Contact_List = "api/Chat/Contacts/"
let Chat_Create_Group = "api/chat/CreateGroup"
let Chat_Update_Group = "api/chat/UpdateGroup/"
let Chat_Add_Group_Members = "api/chat/AddMembers/"
let Chat_Get_Group_Members = "api/chat/GetGroupMembers/"
let Chat_Delete_Conversession = "api/Chat/DeleteConversation"
let Chat_Delete_Messages = "api/Chat/DeleteMessages"

//Update read WiFi, Document, Activity Feed and Map module status
let UpdateReadStatus = "api/Notifications/UpdateReadFlag?"
let Update_WiFi_List = "Wifi"
let Update_Map_List = "Map"
let Update_Documents_List = "Documents"
let Update_Activity_Feeds_List = "Activity Feeds"
let Update_Chat_List = "Chat"
let Update_Broadcast_List = "Broadcast"
let Update_SideMenu_List = "All Module"

/***** END *******/


class NetworkingHelper: NSObject {
    
    class func postData(urlString: String, param: AnyObject, withHeader: Bool, isAlertShow:Bool, controller:UIViewController, callback: @escaping (_ response: AnyObject) -> (), errorBack:@escaping (_ error: NSError) -> ()) {

        //Check internet connection
        AFNetworkReachabilityManager.shared().setReachabilityStatusChange { (status: AFNetworkReachabilityStatus) -> Void in

//            switch status {
//            case .unknown:
//                print("Unknown")
//            case .notReachable:
//                print("notReachable")
//            case .reachableViaWWAN:
//                print("reachableViaWWAN")
//            case .reachableViaWiFi:
//                print("reachableViaWiFi")
//            }

            if status == .notReachable {
                if isAlertShow {
                    CommonModel.sharedInstance.dissmissActitvityIndicator()
                    CommonModel.sharedInstance.showAlertWithStatus(title: "Error", message: Internet_Error_Message, vc: controller)
                }
                return
            }
        }
        AFNetworkReachabilityManager.shared().startMonitoring()

//        if AFNetworkReachabilityManager.shared().isReachable == false{
//            print("Network not found..")
//            CommonModel.sharedInstance.dissmissActitvityIndicator()
//            CommonModel.sharedInstance.showAlertWithStatus(title: "Error", message: Internet_Error_Message, vc: controller)
//            return
//        }

        let url = BASE_URL + urlString
        let manager = AFHTTPSessionManager()
        manager.requestSerializer = AFJSONRequestSerializer()

        if urlString != Get_AuthToken_Url {
            manager.requestSerializer.setValue("Basic ".appending(EventData.sharedInstance.auth_token), forHTTPHeaderField: "Authorization")
        }
        manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Content-Type")
        manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Accept")
        
        manager.responseSerializer = AFJSONResponseSerializer()
       // print("Post URL : ",urlString)

        manager.post(url, parameters: param, progress: nil, success: { (task: URLSessionDataTask, responseObject: Any) in
            
            if urlString == Get_Latest_Questions_List_url {
                //Add Question Activity List in database
                DBManager.sharedInstance.saveSessionQuestionsIntoDB(response: responseObject as AnyObject)
                callback(responseObject as AnyObject)
            }
            else if urlString == Chat_Refresh_Chat_history {
                //Add Question Activity List in database
                DBManager.sharedInstance.saveChatHistory(response: responseObject as AnyObject)
                callback(responseObject as AnyObject)
            }
            else if urlString == Get_Speaker_Activity_url {
                //Add Poll Speaker Activity List in database
                DBManager.sharedInstance.saveSpeakerPollActListIntoDB(response: responseObject as AnyObject)
                callback(responseObject as AnyObject)
            }
            else if urlString == Get_Speaker_latest_Poll {
                //Add Poll Speaker Question List in database
                DBManager.sharedInstance.saveSpeakerPollActQuestionIntoDB(response: responseObject as AnyObject)
                callback(responseObject as AnyObject)
            }
            else if urlString == Chat_History {
                // DBManager.sharedInstance.deleteChatHistory()
                DBManager.sharedInstance.saveChatHistory(response: responseObject as AnyObject)
                callback(responseObject as AnyObject)
            }
            else if urlString == Chat_Group_History {
                DBManager.sharedInstance.saveChatGroupHistory(response: responseObject as AnyObject)
                callback(responseObject as AnyObject)
            }
            else {
                callback(responseObject as AnyObject)
            }
        }, failure: { (task: URLSessionDataTask?, error: Error) in
  
            if urlString == Get_Latest_Questions_List_url {
            }
            else if urlString == Chat_Refresh_Chat_history {
            }
            else {
                CommonModel.sharedInstance.dissmissActitvityIndicator()
                CommonModel.sharedInstance.showAlertWithStatus(title: Server_Error_Message, message: ServerConnection_Error_Message, vc: controller)
            }
            // Invoke the supplied callback block to inform the caller that the request finished
            errorBack(error as NSError)
        })
    }
    
    /*class func getChatRequestFromUrl(name: String, param: AnyObject, urlString: String, callback: @escaping (_ response: AnyObject) -> (), errorBack:@escaping (_ error: NSError) -> ()) {
        
        let manager = AFHTTPSessionManager()
        manager.requestSerializer.setValue("Basic ".appending(EventData.sharedInstance.auth_token), forHTTPHeaderField: "Authorization")
        
        let url = BASE_URL + urlString
        manager.get(url, parameters: param, progress: nil, success: { (task: URLSessionTask!, responseObject: Any?) in
            callback(responseObject as AnyObject)
        },
                    failure: { (task: URLSessionTask?, error: Error!) in
                        
                        callback(error as AnyObject)
        })
    }*/
    
    
    //After Api merge
    class func getRequestFromUrl(name: String, urlString: String, callback: @escaping (_ response: AnyObject) -> (), errorBack:@escaping (_ error: NSError) -> ()) {

        //Check internet connection
        AFNetworkReachabilityManager.shared().setReachabilityStatusChange { (status: AFNetworkReachabilityStatus) -> Void in

            if status == .notReachable {
                print("Network not found..")
                return
            }
        }
        AFNetworkReachabilityManager.shared().startMonitoring()

//        //Check internet connection
//        if !AFNetworkReachabilityManager.shared().isReachable {
//        }

        weak var manager = AFHTTPSessionManager()
        if urlString != Search_Event_Url {
            manager?.requestSerializer.setValue("Basic ".appending(EventData.sharedInstance.auth_token), forHTTPHeaderField: "Authorization")
        }

        let url = BASE_URL + urlString
       // print("GET URL : ",urlString)

        manager?.get(url, parameters: nil, progress: nil, success: { (task: URLSessionTask!, responseObject: Any?) in

            //All event Details
            if name == Get_Login_Details_Url {
                DBManager.sharedInstance.saveLoginEventDataIntoDB(response: responseObject as AnyObject)
                callback(responseObject as AnyObject)
            }
            else  if name == Get_AllModuleDetails_url {
              //  DispatchQueue.global(qos: .background).async {
                print("Get Event Module data : ",CommonModel.sharedInstance.getCurrentDateInMM())

                    DBManager.sharedInstance.saveAllEventDataIntoDB(response: responseObject as AnyObject, apiNname: name)
               // }
                callback(responseObject as AnyObject)
            }
            else if name == Speakers_Details_url {
                //Add All Speakers data in database
                DBManager.sharedInstance.saveSpeakersActivityDataIntoDB(responce: responseObject as AnyObject)
                callback(responseObject as AnyObject)
            }
            else  if name == GetQuestionActivities_url {
                DBManager.sharedInstance.saveAllEventDataIntoDB(response: responseObject as AnyObject, apiNname: name)
                callback(responseObject as AnyObject)
            }
            else  if name == GetPollActivities__url {
                DBManager.sharedInstance.saveAllEventDataIntoDB(response: responseObject as AnyObject, apiNname: name)
                callback(responseObject as AnyObject)
            }
            else  if name == Notification_List_url {
                DBManager.sharedInstance.saveAllEventDataIntoDB(response: responseObject as AnyObject, apiNname: name)
                callback(responseObject as AnyObject)
            }
            else  if name == Attendees_List_url {
                DBManager.sharedInstance.saveAllEventDataIntoDB(response: responseObject as AnyObject, apiNname: name)
                callback(responseObject as AnyObject)
            }
            else  if name == Website_List_url {
                DBManager.sharedInstance.saveAllEventDataIntoDB(response: responseObject as AnyObject, apiNname: name)
                callback(responseObject as AnyObject)
            }
            else  if name == Email_List_url {
                DBManager.sharedInstance.saveAllEventDataIntoDB(response: responseObject as AnyObject, apiNname: name)
                callback(responseObject as AnyObject)
            }
            else if name == GetQuestions_List_url {
                //Add Question Activity List in database
                DBManager.sharedInstance.saveSessionQuestionsIntoDB(response: responseObject as AnyObject)
                callback(responseObject as AnyObject)
            }
            else if name == GetPoll_Question_List_url {
                //Add Poll activity Question List in database
                DBManager.sharedInstance.savePollActivityQuestionsIntoDB(response: responseObject as AnyObject)
                callback(responseObject as AnyObject)
            }
            else  if name == ActivityFeed_List_url {
                DBManager.sharedInstance.saveAllEventDataIntoDB(response: responseObject as AnyObject, apiNname: name)
                callback(responseObject as AnyObject)
            }
            else  if name == Get_Comments_url {
                DBManager.sharedInstance.saveActivityFeedCommentsDataIntoDB(response: responseObject as AnyObject)
                callback(responseObject as AnyObject)
            }
            else  if name == PhotoGallery_List_url {
                DBManager.sharedInstance.saveAllEventDataIntoDB(response: responseObject as AnyObject, apiNname: name)
                callback(responseObject as AnyObject)
            }
            else  if name == Get_Activity_Feedback_List_url {
                DBManager.sharedInstance.saveActivityFeedbackDataIntoDB(responce: responseObject as AnyObject)
                callback(responseObject as AnyObject)
            }
            else  if name == Chat_Contact_List {
                DBManager.sharedInstance.saveAllEventDataIntoDB(response: responseObject as AnyObject, apiNname: name)
                callback(responseObject as AnyObject)
            }
            else  if name == Documents_List_url {
                DBManager.sharedInstance.saveAllEventDataIntoDB(response: responseObject as AnyObject, apiNname: name)
                callback(responseObject as AnyObject)
            }
            else {
                callback(responseObject as AnyObject)
            }
        },
                    failure: { (task: URLSessionTask?, error: Error!) in
                        
                        callback(error as AnyObject)
        })
    }
   
    
   /* class func getRequestFromUrl(name: String, urlString: String, callback: @escaping (_ response: AnyObject) -> (), errorBack:@escaping (_ error: NSError) -> ()) {
        
        let manager = AFHTTPSessionManager()
        manager.requestSerializer.setValue("Basic ".appending(EventData.sharedInstance.auth_token), forHTTPHeaderField: "Authorization")
        
        let url = BASE_URL + urlString
        manager.get(url, parameters: nil, progress: nil, success: { (task: URLSessionTask!, responseObject: Any?) in
            
                //Save Event Details data in database
            if name == Event_Details_Url {
                DBManager.sharedInstance.saveEventDetailsDataIntoDB(responce: responseObject as AnyObject)
                callback(responseObject as AnyObject)
            }
            else if name == Profile_List_url {
                //Add All Profile data in database
                DBManager.sharedInstance.saveProfileDataIntoDB(response: responseObject as AnyObject)
                callback(responseObject as AnyObject)
            }
                //Module List and Application theme data
            else if name == Home_url {
                if responseObject is NSDictionary {
                    let dict = responseObject as! NSDictionary
                    if (dict.value(forKey:"CommonForAll") as? NSNull) == nil {
                        
                        let themeDict = dict.value(forKey:"CommonForAll") as! NSDictionary
                        DBManager.sharedInstance.insertApplicationThemeDataIntoDB(themeDict: themeDict)
                        
                        DBManager.sharedInstance.insertApplicationModulesDataIntoDB(responce: responseObject as AnyObject)
                    }
                }
                
                callback(responseObject as AnyObject)
            }
            else if name == Agenda_List_url {
                //Add All Agenda/Activities list data in database
                DBManager.sharedInstance.saveAgendaDataIntoDB(responce: responseObject as AnyObject)
                callback(responseObject as AnyObject)
            }
            else if name == Attendees_List_url {
                //Add All attendees data in database
                DBManager.sharedInstance.saveAttendeesDataIntoDB(responce: responseObject as AnyObject)
                callback(responseObject as AnyObject)
            }
            else if name == Map_List_url {
                //Add All Map data in database
                DBManager.sharedInstance.saveMapDataIntoDB(responce: responseObject as AnyObject)
                callback(responseObject as AnyObject)
            }
            else if name == Feedback_List_url {
                //Add All Feedback data in database
                DBManager.sharedInstance.saveFeedbackDataIntoDB(responce: responseObject as AnyObject)
                callback(responseObject as AnyObject)
            }
            else if name == PhotoGallery_List_url {
                //Add All Photo Gallery data in database
                DBManager.sharedInstance.saveGalleryDataIntoDB(responce: responseObject as AnyObject)
                callback(responseObject as AnyObject)
            }
            else if name == Speakers_List_url {
                //Add All Speakers data in database
                DBManager.sharedInstance.saveSpeakersDataIntoDB(responce: responseObject as AnyObject)
                callback(responseObject as AnyObject)
            }
            else if name == Speakers_Details_url {
                //Add All Speakers data in database
                DBManager.sharedInstance.saveSpeakersActivityDataIntoDB(responce: responseObject as AnyObject)
                callback(responseObject as AnyObject)
            }
                
            else if name == Sponsors_List_url {
                //Add All Sponsors data in database
                DBManager.sharedInstance.saveSponsorsDataIntoDB(responce: responseObject as AnyObject)
                callback(responseObject as AnyObject)
            }
            else if name == Email_List_url {
                //Add All Email data in database
                DBManager.sharedInstance.saveEmailDataIntoDB(responce: responseObject as AnyObject)
                callback(responseObject as AnyObject)
            }
            else if name == WiFi_List_url {
                //Add All Email data in database
                DBManager.sharedInstance.saveWifiDataIntoDB(response: responseObject as AnyObject)
                callback(responseObject as AnyObject)
            }
            else if name == Emergency_List_url {
                //Add All Emergency data in database
                DBManager.sharedInstance.saveEmergencyDataIntoDB(responce: responseObject as AnyObject)
                callback(responseObject as AnyObject)
            }
            else if name == Documents_List_url {
                //Add Documents List in database
                DBManager.sharedInstance.saveDocumentsDataIntoDB(response: responseObject as AnyObject)
                callback(responseObject as AnyObject)
            }
            else if name == GetQuestionActivities_url {
                //Add Sessions List in database
                DBManager.sharedInstance.saveActiveSessionIntoDB(response: responseObject as AnyObject)
                callback(responseObject as AnyObject)
            }
            else if name == GetQuestions_List_url {
                //Add Sessions Question List in database
                DBManager.sharedInstance.saveSessionQuestionsIntoDB(response: responseObject as AnyObject)
                callback(responseObject as AnyObject)
            }
            else if name == GetPollActivities__url {
                //Add Poll Sessions List in database
                DBManager.sharedInstance.savePollActivitySessionsIntoDB(response: responseObject as AnyObject)
                callback(responseObject as AnyObject)
            }
            else if name == GetPoll_Question_List_url {
                //Add Poll Sessions Question List in database
                DBManager.sharedInstance.savePollActivityQuestionsIntoDB(response: responseObject as AnyObject)
                callback(responseObject as AnyObject)
            }
            else {
                callback(responseObject as AnyObject)
            }
        },
                    failure: { (task: URLSessionTask?, error: Error!) in
                        
                        callback(error as AnyObject)
        })
    }*/
    
   

}
