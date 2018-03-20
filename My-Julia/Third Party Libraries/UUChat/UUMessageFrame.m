//
//  UUMessageFrame.m
//  UUChatDemoForTextVoicePicture
//
//  Created by shake on 14-8-26.
//  Copyright (c) 2014年 uyiuyao. All rights reserved.
//

#import "UUMessageFrame.h"
#import "UUMessage.h"
#import <UIKit/UIKit.h>
#import "ACMacros.h"

@implementation UUMessageFrame

- (void)setMessage:(UUMessage *)message{
    
    _message = message;
    
    CGFloat screenW = self.screen_size.width; //Main_Screen_Width; //[UIScreen mainScreen].bounds.size.width;
    
    if (_showTime){
        CGFloat timeY = ChatMargin;
        CGSize timeSize;
        CGRect rect = [_message.strTime boundingRectWithSize:CGSizeMake(300, 100)
                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:@{NSFontAttributeName: ChatTimeFont}
                                                        context:nil];
        timeSize.width = ceil(rect.size.width);
        timeSize.height = ceil(rect.size.height);

        CGFloat timeX = (screenW - timeSize.width) / 2;
        _timeF = CGRectMake(timeX, timeY, timeSize.width + ChatTimeMarginW, timeSize.height + ChatTimeMarginH);
    }
    
    
    // 2、计算头像位置
    CGFloat iconX = ChatMargin;
    if (_message.from == UUMessageFromMe) {
        iconX = screenW - ChatMargin - ChatIconWH;
    }
    
    CGFloat iconY = CGRectGetMaxY(_timeF);
    
    if (_showTime) {
        _iconF = CGRectMake(iconX, iconY, ChatIconWH, ChatIconWH);
    }
    else {
        _iconF = CGRectMake(iconX, 0, ChatIconWH, 0);
    }
    _nameF = CGRectMake(iconX, CGRectGetMaxY(_iconF), 150, 0);

    CGFloat contentX = ChatMargin;
    CGFloat contentY = CGRectGetMaxY(_timeF) + 3;

    // 3、计算ID位置
    if (self.showName && _message.from == UUMessageFromOther) {
        _nameF.size.height =  20;
        contentY = CGRectGetMaxY(_nameF) + 6;
    }
    else {
        _nameF.size.height =  0;
    }
    
    // 4、计算内容位置
    
    //根据种类分
    CGSize contentSize;
    switch (_message.type) {
        case UUMessageTypeText:
            // contentSize = [_message.strContent sizeWithFont:ChatContentFont  constrainedToSize:CGSizeMake(ChatContentW, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
        {
            CGRect rect = [_message.strContent boundingRectWithSize:CGSizeMake(ChatContentW, CGFLOAT_MAX)
                                                            options:NSStringDrawingUsesLineFragmentOrigin
                                                         attributes:@{NSFontAttributeName: ChatContentFont}
                                                            context:nil];
            contentSize.width = ceil(rect.size.width);
            contentSize.height = ceil(rect.size.height);
        }
            break;
        case UUMessageTypePicture:
            contentSize = CGSizeMake(ChatPicWH, ChatPicWH);
            break;
        case UUMessageTypeVoice:
            contentSize = CGSizeMake(120, 20);
            break;
        default:
            break;
    }
    if (_message.from == UUMessageFromMe) {
        contentX = iconX - contentSize.width - ChatContentLeft - ChatContentRight - ChatMargin;
    }
    _contentF = CGRectMake(contentX, contentY, contentSize.width + ChatContentLeft + ChatContentRight , contentSize.height + ChatContentTop + ChatContentBottom);
    
    _contentTimeF = CGRectMake(contentX + _contentF.size.width - ChatTimeW, contentY + _contentF.size.height, ChatTimeW , 20);

    if (_message.from == UUMessageFromOther) {
        _contentTimeF = CGRectMake(ChatMargin + contentX + _contentF.size.width - ChatTimeW, contentY + _contentF.size.height + 3, ChatTimeW , 20);
        if (_contentTimeF.origin.x < 0) {
            _contentTimeF.origin.x = _nameF.origin.x;
        }
    }
    
    _cellHeight = MAX(CGRectGetMaxY(_contentTimeF), CGRectGetMaxY(_contentTimeF)) ;
    
    //Set deleted background image frame
     if (_showTime){
         _bgImageF = CGRectMake(0, _timeF.origin.y + _timeF.size.height + 1 , screenW , _cellHeight - (_timeF.origin.y + _timeF.size.height + 3));
     }
     else {
         _bgImageF = CGRectMake(0, 1 , screenW , _cellHeight - 3);
     }
    
    // 1、计算时间的位置
//    if (_showTime){
//        CGFloat timeY = ChatMargin;
//        CGSize timeSize = [_message.strTime sizeWithFont:ChatTimeFont constrainedToSize:CGSizeMake(300, 100) lineBreakMode:NSLineBreakByWordWrapping];
//
//        CGFloat timeX = (screenW - timeSize.width) / 2;
//        _timeF = CGRectMake(timeX, timeY, timeSize.width + ChatTimeMarginW, timeSize.height + ChatTimeMarginH);
//    }
//    
//    
//    // 2、计算头像位置
//    CGFloat iconX = ChatMargin;
//    if (_message.from == UUMessageFromMe) {
//        iconX = screenW - ChatMargin - ChatIconWH;
//    }
//    CGFloat iconY = CGRectGetMaxY(_timeF) + ChatMargin;
//    _iconF = CGRectMake(iconX, iconY, ChatIconWH, ChatIconWH);
//    
//    // 3、计算ID位置
//    _nameF = CGRectMake(iconX, iconY+ChatIconWH, ChatIconWH, 20);
//    
//    // 4、计算内容位置
//    CGFloat contentX = CGRectGetMaxX(_iconF)+ChatMargin;
//    CGFloat contentY = iconY;
//   
//    //根据种类分
//    CGSize contentSize;
//    switch (_message.type) {
//        case UUMessageTypeText:
//            contentSize = [_message.strContent sizeWithFont:ChatContentFont  constrainedToSize:CGSizeMake(ChatContentW, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
// 
//            break;
//        case UUMessageTypePicture:
//            contentSize = CGSizeMake(ChatPicWH, ChatPicWH);
//            break;
//        case UUMessageTypeVoice:
//            contentSize = CGSizeMake(120, 20);
//            break;
//        default:
//            break;
//    }
//    if (_message.from == UUMessageFromMe) {
//        contentX = iconX - contentSize.width - ChatContentLeft - ChatContentRight - ChatMargin;
//    }
//    _contentF = CGRectMake(contentX, contentY, contentSize.width + ChatContentLeft + ChatContentRight, contentSize.height + ChatContentTop + ChatContentBottom);
//    
//    _cellHeight = MAX(CGRectGetMaxY(_contentF), CGRectGetMaxY(_nameF))  + ChatMargin;
    
}

@end
