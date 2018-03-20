//
//  UUMessage.h
//  UUChatDemoForTextVoicePicture
//
//  Created by shake on 14-8-26.
//  Copyright (c) 2014年 uyiuyao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MessageType) {
    UUMessageTypeText     = 0 , // 文字
    UUMessageTypePicture  = 1 , // 图片
    UUMessageTypeVoice    = 2   // 语音
};


typedef NS_ENUM(NSInteger, MessageFrom) {
    UUMessageFromMe    = 0,   // 自己发的
    UUMessageFromOther = 1    // 别人发得
};


@interface UUMessage : NSObject

@property (nonatomic, copy) NSString *chatId;
@property (nonatomic, copy) NSString *strIcon;
@property (nonatomic, copy) NSString *strId;
@property (nonatomic, copy) NSString *strTime;
@property (nonatomic, copy) NSString *strName;
@property (nonatomic, copy) NSString *messageTime;
@property (nonatomic, copy) NSString *messageDate;
@property (nonatomic, copy) NSString *createdBy;

@property (nonatomic, copy) NSString *toUserIcon;
@property (nonatomic, copy) NSString *toUserName;

@property (nonatomic, copy) NSString *strContent;
@property (nonatomic, copy) UIImage  *picture;
@property (nonatomic, copy) NSString  *pictureString;
@property (nonatomic, copy) NSData   *voice;
@property (nonatomic, copy) NSString *strVoiceTime;

@property (nonatomic, assign) MessageType type;
@property (nonatomic, assign) MessageFrom from;

@property (nonatomic, assign) BOOL showDateLabel;

- (void)setWithDict:(NSDictionary *)dict;

- (void)minuteOffSetStart:(NSString *)start end:(NSString *)end;
- (NSString *)changeTheDateString:(NSString *)Str;
- (NSString *)changeTheTimeString:(NSString *)Str;
- (NSString *)isEmptyString:(NSString *)Str;
- (MessageType)setMessageType:(NSInteger)type;

@end
