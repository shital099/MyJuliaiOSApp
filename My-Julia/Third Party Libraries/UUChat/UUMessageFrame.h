//
//  UUMessageFrame.h
//  UUChatDemoForTextVoicePicture
//
//  Created by shake on 14-8-26.
//  Copyright (c) 2014年 uyiuyao. All rights reserved.
//

#define ChatMargin 10       //间隔
#define ChatIconWH 10       //头像宽高height、width
#define ChatPicWH 200       //图片宽高
#define ChatContentW 220    //内容宽度
#define ChatTimeW 60    //内容宽度

#define ChatTimeMarginW 10  //时间文本与边框间隔宽度方向
#define ChatTimeMarginH 10  //时间文本与边框间隔高度方向

#define ChatContentTop 5   //文本内容与按钮上边缘间隔
#define ChatContentLeft 15  //文本内容与按钮左边缘间隔
#define ChatContentBottom 8 //文本内容与按钮下边缘间隔
#define ChatContentRight 10 //文本内容与按钮右边缘间隔

#define ChatTimeFont [UIFont systemFontOfSize:10]   //时间字体
#define ChatContentFont [UIFont systemFontOfSize:13]//内容字体
#define ChatMessageTimeFont [UIFont systemFontOfSize:8]   //时间字体

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class UUMessage;

@interface UUMessageFrame : NSObject

@property (nonatomic, assign, readonly) CGRect nameF;
@property (nonatomic, assign, readonly) CGRect iconF;
@property (nonatomic, assign, readonly) CGRect timeF;
@property (nonatomic, assign, readonly) CGRect contentF;
@property (nonatomic, assign, readonly) CGRect contentTimeF;
@property (nonatomic, assign, readonly) CGRect bgImageF;

@property (nonatomic, assign, readonly) CGFloat cellHeight;
@property (nonatomic, strong) UUMessage *message;
@property (nonatomic, assign) BOOL showTime;
@property (nonatomic, assign) CGSize screen_size;
@property (nonatomic, assign) BOOL showName;

@end
