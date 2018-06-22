//
//  ActivityFeedModelController.swift
//  My-Julia
//
//  Created by GCO on 16/02/2018.
//  Copyright © 2018 GCO. All rights reserved.
//

import UIKit

class ActivityFeedViewModelController: NSObject {

    fileprivate var pageNo = 0
    fileprivate var isLastPage = false
    fileprivate var viewModels:NSMutableArray = []
    var moduleIndex = 0


    func retrieveFirstPage()  {
        // Remove first page load data
        self.pageNo = 0
        self.isLastPage = false
    }

    func initializeModuleIndex(index : Int)  {
        // Remove first page load data
        self.moduleIndex = index
    }

    // MARK: - Webservice Methods

    func retrieveActivityFeeds(_ completionBlock: @escaping (_ success: Bool, _ error: NSError?) -> ()) {


        // Move to a background thread to do some long running work
        DispatchQueue.global(qos: .background).async {
            let urlStr = Get_AllModuleDetails_url.appendingFormat("Flag=%@&PageNo=%d",ActivityFeed_List_url,self.pageNo)

            print("Actiivity feeds url : ",urlStr)

            NetworkingHelper.getRequestFromUrl(name:ActivityFeed_List_url,  urlString:urlStr, callback: { [weak self] response in

               // print("Actiivity feeds data : ",response)
//                //Change notification count in side menu
//                let userDict:[String: Bool] = ["isClickOnNotification": false]
//                NotificationCenter.default.post(name: BroadcastNotification, object: "", userInfo: userDict)

                // Remove first page load data
                if self?.pageNo == 0 {
                    self?.pageNo = 0
                    self?.isLastPage = false

                    if self?.viewModels.count != 0 {
                        self?.viewModels.removeAllObjects()
                    }
                }
                //Load data from db
                self?.loadItem()

                DispatchQueue.main.async {
                    //  self.sortData()
                }
                completionBlock(true, nil)

            }, errorBack: { error in
                NSLog("error : %@", error)
                //Load data from db
                self.loadItem()
                completionBlock(false, error)
            })
        }
    }

    func postActivityFeedsLikeStatus(index: Int, status: Bool, view : UIViewController, completionBlock: @escaping (_ success: Bool, _ error: NSError?) -> ()) {

        // Move to a background thread to do some long running work
        CommonModel.sharedInstance.showActitvityIndicator()
        let model : ActivityFeedsModel = self.viewModel(at: index)!
        let likeStatus : Int = status == true ? 1 : 0

        let paramDict = ["ActivityFeedId": model.id, "Like":likeStatus, "AttendeeId":AttendeeInfo.sharedInstance.attendeeId] as [String : Any]

        NetworkingHelper.postData(urlString:Post_Activity_Like_url, param:paramDict as AnyObject, withHeader: false, isAlertShow: true, controller:view, callback: { [weak self] response in

            model.isUserLike = status

            //dissmiss Indicator
            CommonModel.sharedInstance.dissmissActitvityIndicator()
            if likeStatus == 1 {
                model.likesCount = String(Int(model.likesCount)! + 1)
            }
            else {
                model.likesCount = String(Int(model.likesCount)! - 1)
            }
            self?.viewModels.replaceObject(at: index, with: model)

            _ = self?.updateLikesStatusDB(at: index)

            completionBlock(true, nil)

        }, errorBack: { error in
                NSLog("error : %@", error)
                completionBlock(false, error)
            })
    }

    // MARK: - Data handling Methods

    func loadItem()  {
        //Calculate page offset offset
        let offset = self.pageNo * Activity_Page_Limit
        //Load data from db
        let array = DBManager.sharedInstance.fetchActivityFeedsDataFromDB(limit: Activity_Page_Limit, offset: offset).mutableCopy() as! NSMutableArray
        if array.count < Activity_Page_Limit {
            self.isLastPage = true
        }
        self.viewModels.addObjects(from: array as! [ActivityFeedsModel])

//        //Update activity feed read status
//         DBManager.sharedInstance.updateActivityFeedNotificationStatus()

        print("Activity feed Module index : ",self.moduleIndex)

        //Update actiivty read/unread data count in side menu bar
        let dataDict:[String: Any] = ["Order": moduleIndex, "Flag":Update_Activity_Feeds_List]
        NotificationCenter.default.post(name: UpdateNotificationCount, object: nil, userInfo: dataDict)
        // print("After load Data array count : ", self.dataArray.count)
    }

    var viewFeedsModelsCount: Int {
        return viewModels.count
    }

    func viewModel(at index: Int) -> ActivityFeedsModel? {
        guard index >= 0 && index < viewFeedsModelsCount else { return nil }
        return viewModels[index] as? ActivityFeedsModel
    }

    func checkLoadMoreViewModel(at index: Int) -> Bool {
        // print(" index : ", index)
        // more items to fetch - search last cell
        if index == viewFeedsModelsCount - 1 && isLastPage == false {
            self.pageNo += 1
            return true
        }
        else {
            return false
        }
    }

    // MARK: - Database Methods

    func updateCommentIntoDB(at index: Int , count : String) -> ActivityFeedsModel?  {
        guard index >= 0 && index < viewFeedsModelsCount else { return nil }

        let model : ActivityFeedsModel = self.viewModel(at: index)!
        model.commentsCount = count
        self.viewModels.replaceObject(at: index, with: model)
        DBManager.sharedInstance.updateActivityFeedsDataIntoDB(likesCount: model.likesCount, commentsCount: model.commentsCount, activityFeedId: model.id)
        return model
    }

    func updateLikesStatusDB(at index: Int)  {
        let model : ActivityFeedsModel = self.viewModel(at: index)!
        self.viewModels.replaceObject(at: index, with: model)
        DBManager.sharedInstance.updateActivityLikeDataIntoDB(userLike: model.isUserLike, activityId: model.id)
        DBManager.sharedInstance.updateActivityFeedsDataIntoDB(likesCount: model.likesCount, commentsCount: model.commentsCount, activityFeedId: model.id)
    }
}
