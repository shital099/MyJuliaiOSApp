//
//  UUMessage.m
//  UUChatDemoForTextVoicePicture
//
//  Created by shake on 14-8-26.
//  Copyright (c) 2014年 uyiuyao. All rights reserved.
//

#import "UUMessage.h"
#import "NSDate+Utils.h"
#import "CryptLib.h"

@implementation UUMessage

- (void)setWithDict:(NSDictionary *)dict{
    
    self.chatId = [self isEmptyString:dict[@"ChatId"]];
    self.strIcon = [self isEmptyString:dict[@"FromIconUrl"]];
    self.strName = [self isEmptyString:dict[@"FromName"]];
    self.strId = [self isEmptyString:dict[@"FromId"]];
    self.strTime = [self changeTheDateString:dict[@"CreatedDate"]];
    self.messageTime = [self changeTheTimeString:dict[@"CreatedDate"]];
    self.messageDate = dict[@"CreatedDate"];

    NSInteger type;
    if ([dict[@"ImageUrl"] isKindOfClass:[NSNull class]]) {
        type = 0;
    }
    else {
        type = 1;
    }
    
    switch (type) {
        
        case 0: {
            self.type = UUMessageTypeText;
            NSString *decryptedString = [[CryptLib sharedManager] decryptCipherTextWith:dict[@"Message"]];
            self.strContent = decryptedString;
        }
            break;
        case 1:
            self.type = UUMessageTypePicture;
          //  self.pictureString = dict[@"ImageUrl"];
            break;
        
        case 2:
            self.type = UUMessageTypeVoice;
            self.voice = dict[@"voice"];
            self.strVoiceTime = dict[@"strVoiceTime"];
            break;
            
        default:
            break;
    }
}

- (MessageType)setMessageType:(NSInteger)type {
    
    switch (type) {
            
        case 0: {
            self.type = UUMessageTypeText;
        }
            break;
        case 1:
            self.type = UUMessageTypePicture;
            break;
            
        case 2:
            self.type = UUMessageTypeVoice;
            break;
            
        default:
            break;
    }
    return self.type;
}

- (NSString *)isEmptyString:(NSString *)Str {
    
    if (![Str isKindOfClass:[NSNull class]]) {
        return Str;
    }
    
    return @" ";
}

//"08-10 晚上08:09:41.0" ->
//"昨天 上午10:09"或者"2012-08-10 凌晨07:09"
- (NSString *)changeTheDateString:(NSString *)Str
{
    //NSLog(@"date str : %@",Str);
    
   // NSString *subString = [Str substringWithRange:NSMakeRange(0, 19)];
    NSDate *lastDate = [NSDate dateFromString:Str withFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
   // NSDate *lastDate = [NSDate dateFromDate:[NSDate dateFromString:Str withFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"] withFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS" withNewFormat:@"yyyy-MM-dd"] ;
    
    /*NSString *startDate = @"2017-11-28T12:19:29.787";
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
    NSDate *date = [inputFormatter dateFromString:startDate];

	NSTimeZone *zone = [NSTimeZone systemTimeZone];
	NSInteger interval = [zone secondsFromGMTForDate:lastDate];
	lastDate = [lastDate dateByAddingTimeInterval:interval];
    */
    
    NSString *dateStr;  //年月日
    if ([lastDate year]==[[NSDate date] year]) {
        NSInteger days = [NSDate daysOffsetBetweenStartDate:lastDate endDate:[NSDate date]];
        if (days <= 2) {
            dateStr = [lastDate stringYearMonthDayCompareToday:days];
        }else{
            dateStr = [lastDate stringYearMonthDay];
        }
    }else{
        dateStr = [lastDate stringYearMonthDay];
    }

   // NSLog(@"Date Str : %@", dateStr);

//    if ([lastDate year]==[[NSDate date] year]) {
//        NSInteger days = [NSDate daysOffsetBetweenStartDate:lastDate endDate:[NSDate date]];
//        if (days <= 2) {
//            dateStr = [lastDate stringYearMonthDayCompareToday];
//        }else{
//            dateStr = [lastDate stringMonthDay];
//        }
//    }else{
//        dateStr = [lastDate stringYearMonthDay];
//    }
    
//    if ([lastDate hour]>=5 && [lastDate hour]<12) {
//        period = @"AM";
//        hour = [NSString stringWithFormat:@"%02d",(int)[lastDate hour]];
//    }else if ([lastDate hour]>=12 && [lastDate hour]<=18){
//        period = @"PM";
//        hour = [NSString stringWithFormat:@"%02d",(int)[lastDate hour]-12];
//    }else if ([lastDate hour]>18 && [lastDate hour]<=23){
//        period = @"Night";
//        hour = [NSString stringWithFormat:@"%02d",(int)[lastDate hour]-12];
//    }else{
//        period = @"Dawn";
//        hour = [NSString stringWithFormat:@"%02d",(int)[lastDate hour]];
//    }
//    return [NSString stringWithFormat:@"%@ %@ %@:%02d",dateStr,period,hour,(int)[lastDate minute]];
    return [NSString stringWithFormat:@"%@",dateStr];
}

- (NSString *)changeTheTimeString:(NSString *)Str
{
  //  NSString *subString = [Str substringWithRange:NSMakeRange(0, 19)];
    NSDate *lastDate = [NSDate dateFromString:Str withFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
    NSString *time = [NSDate timeFromDate:lastDate withFormat:@"hh:mm aa"];
    return time;
}

- (void)minuteOffSetStart:(NSString *)start end:(NSString *)end
{
    if (!start) {
        self.showDateLabel = YES;
        return;
    }
    
    //NSString *subStart = [start substringWithRange:NSMakeRange(0, 19)];
    NSDate *startDate = [NSDate dateFromString:start withFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
    
    //NSString *subEnd = [end substringWithRange:NSMakeRange(0, 19)];
    NSDate *endDate = [NSDate dateFromString:end withFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
    
    //这个是相隔的秒数
    NSTimeInterval timeInterval = [startDate timeIntervalSinceDate:endDate];
    
    //相距5分钟显示时间Label
    if (fabs (timeInterval) > 60 * 60 * 24) {
        self.showDateLabel = YES;
    }else{
        self.showDateLabel = NO;
    }
    
}
@end
