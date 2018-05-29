//
//  NotificationViewModelController.swift
//  My-Julia
//
//  Created by GCO on 16/02/2018.
//  Copyright © 2018 GCO. All rights reserved.
//

import UIKit

class NotificationViewModelController: NSObject {

   // fileprivate var viewModels: [NotificationsModel?] = []
    fileprivate var pageNo = 0
    fileprivate var isLastPage = false
    fileprivate var viewModels:NSMutableArray = []
    var moduleIndex = 0

    func initializeModuleIndex(index : Int)  {
        // Remove first page load data
        self.moduleIndex = index
    }
    
    func retrieveFirstPage()  {
        // Remove first page load data
        self.pageNo = 0
        self.isLastPage = false
    }

    func retrieveNotifications(_ completionBlock: @escaping (_ success: Bool, _ error: NSError?) -> ()) {

        // Move to a background thread to do some long running work
        DispatchQueue.global(qos: .background).async {
            let urlStr = Get_AllModuleDetails_url.appendingFormat("Flag=%@&PageNo=%d",Notification_List_url,self.pageNo)
            NetworkingHelper.getRequestFromUrl(name:Notification_List_url,  urlString:urlStr, callback: { [weak self] response in

                // Remove first page load data
                if self?.pageNo == 0 {
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

    func loadItem()  {

        //Calculate page offset offset
        let offset = self.pageNo * Activity_Page_Limit
        //Load data from db
        let array = DBManager.sharedInstance.fetchNotificationDataFromDB(limit: Activity_Page_Limit, offset: offset).mutableCopy() as! NSMutableArray
        if array.count < Activity_Page_Limit {
            self.isLastPage = true
        }

       self.viewModels.addObjects(from: array as! [NotificationsModel])

        // print("After load Data array count : ", self.dataArray.count)

        print("Module index : ",self.moduleIndex)

        //Update actiivty read/unread data count in side menu bar
        let dataDict:[String: Any] = ["Order": moduleIndex, "Flag":Update_Broadcast_List]
        NotificationCenter.default.post(name: UpdateNotificationCount, object: nil, userInfo: dataDict)
    }

  //  task.resume()

//    func retrieveUsers(_ completionBlock: @escaping (_ success: Bool, _ error: NSError?) -> ()) {
//        let urlString = ... // Users Web Service URL
//        let session = URLSession.shared
//
//        guard let url = URL(string: urlString) else {
//            completionBlock(false, nil)
//            return
//        }
//        let task = session.dataTask(with: url) { [weak self] (data, response, error) in
//            guard let strongSelf = self else { return }
//            guard let data = data else {
//                completionBlock(false, error as NSError?)
//                return
//            }
//            let error = ... // Define a NSError for failed parsing
//            if let jsonData = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String: AnyObject]] {
//                guard let jsonData = jsonData else {
//                    completionBlock(false,  error)
//                    return
//                }
//                var users = [User?]()
//                for json in jsonData {
//                    if let user = UserViewModelController.parse(json) {
//                        users.append(user)
//                    }
//                }
//
//                strongSelf.viewModels = UserViewModelController.initViewModels(users)
//                completionBlock(true, nil)
//            } else {
//                completionBlock(false, error)
//            }
//        }
//        task.resume()
//    }

    var viewModelsCount: Int {
        return viewModels.count
    }

    func viewModel(at index: Int) -> NotificationsModel? {
        guard index >= 0 && index < viewModelsCount else { return nil }
        return viewModels[index] as? NotificationsModel
    }

    func checkLoadMoreViewModel(at index: Int) -> Bool {
       // print(" index : ", index)
        // more items to fetch - search last cell
        if index == viewModelsCount - 1 && isLastPage == false {
            self.pageNo += 1
            return true
        }
        else {
            return false
        }
    }
}
