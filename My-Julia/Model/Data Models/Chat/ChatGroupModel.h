//
//  ChatGroupModel.h
//  My-Julia
//
//  Created by GCO on 8/31/17.
//  Copyright © 2017 GCO. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatGroupModel : NSObject

@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, strong) NSString *fromId;
@property (nonatomic, strong) NSString *dateStr;
@property (nonatomic, strong) NSString *modifiedDateStr;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *lastMessage;
@property (nonatomic, strong) NSString *iconUrl;
@property (nonatomic, strong) NSString *messageImgUrl;
@property (nonatomic) BOOL isGroupChat;
@property (nonatomic) BOOL dndSetting;
@property (nonatomic) BOOL visibilitySetting;
@property (nonatomic, strong) NSString *groupCreatedUserId;
@property (nonatomic) BOOL listStatus;
@property (nonatomic, assign) int unreadCount;

@end

