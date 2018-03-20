//
//  HeaderView.m
//  selection_List
//
//  Created by NTMC_MacMini on 2017/6/16.
//  Copyright © 2017年 bruce. All rights reserved.
//



#import "HeaderView.h"
//#import "EventApp-Swift.h"
#import "ChatGroupModel.h"
#import "UIImageView+WebCache.h"

#define Color(r, g, b) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1]
#define Spacing 12   //横向纵向间距都是10
#define SCREEN_BOUNDS [UIScreen mainScreen].bounds
#define SCREEN_WIDTH  CGRectGetWidth([UIScreen mainScreen].bounds)
#define SCREEN_HEIGHT  CGRectGetHeight([UIScreen mainScreen].bounds)

@implementation HeaderView

-(instancetype)initWithFrame:(CGRect)frame{


    self = [super initWithFrame:frame];
    
    if (self) {
        
    self.backgroundColor = Color(235, 235, 235);
        
    }

    return self;
}


-(void)setHeaderDataArr:(NSMutableArray *)headerDataArr{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _headerDataArr = headerDataArr;
    [self readNameBtn];
}

-(void)readNameBtn{
    CGFloat iconX = 10;
    CGFloat iconY = Spacing;
    CGFloat iconH = 60;
    CGFloat nameH = 20;

    for (int i = 0; i < _headerDataArr.count; i++) {
        
        UIImageView *userImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"user"]];
        [self addSubview:userImage];
        
        UIButton *iconBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        iconBtn.backgroundColor = [UIColor clearColor];
         iconBtn.frame = CGRectMake(iconX, iconY, iconH, iconH);
        //NOTE: 设置按钮的样式
        [iconBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        NSDictionary *dic = _headerDataArr[i];
      //  [titBtn setTitle:dic[@"USER_NAME"] forState:UIControlStateNormal];
        iconBtn.tag = 1000+i;
        [iconBtn addTarget:self action:@selector(titBtnClike:) forControlEvents:UIControlEventTouchUpInside];
        UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"cancel_button"]];
        iconBtn.imageEdgeInsets = UIEdgeInsetsMake(0, iconBtn.frame.size.height , iconBtn.frame.size.width, 0);
        imageView.frame = CGRectMake(iconBtn.frame.size.width-16, 0, 17, 17);
        [iconBtn addSubview:imageView];
        iconBtn.layer.cornerRadius = iconH/2;
     //   iconBtn.backgroundColor = [UIColor greenColor];
        

        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(iconX, iconY + iconH, iconH , nameH)];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.textColor = [UIColor grayColor];
      //  nameLabel.text = dic[@"USER_NAME"];
      //  nameLabel.text = @"Chat Message";
        ChatGroupModel *model = _headerDataArr[i];
        nameLabel.text = model.name;
        if (model.name != nil) {
            nameLabel.text = [model.name componentsSeparatedByString:@" "].firstObject;
        }
        nameLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:nameLabel];
        
        NSURL *url = [NSURL URLWithString:model.iconUrl];
        [userImage sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"user"]];
        userImage.layer.cornerRadius = iconH/2;
        userImage.frame = iconBtn.frame;
        userImage.clipsToBounds = YES;

//        @try {
//            [iconBtn setBackgroundImage:[UIImage imageWithData:[[NSData alloc] initWithContentsOfURL:url]] forState:UIControlStateNormal];
//        } @catch (NSException *exception) {
//        } @finally {
//        }

        //NOTE: 计算文字大小
//        CGSize titleSize = [dic[@"USER_NAME"] boundingRectWithSize:CGSizeMake(MAXFLOAT,iconH) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:userIconBtn.titleLabel.font} context:nil].size;
        CGFloat titBtnW = iconH + 2 * Spacing; //按钮的长度加间距
//        //NOTE: 判断按钮是否超过屏幕的宽
        
        //NOTE: 设置按钮的位置
     //   userIconBtn.frame = CGRectMake(iconX, iconY, iconH, iconH);
 
        iconX += iconH + Spacing + 5;
        
        self.frame = CGRectMake(0, 0, self.frame.size.width, iconY + iconH + nameH );
        
        if ((iconX + titBtnW) > self.frame.size.width) {
            iconX = 10;
            iconY += iconH + Spacing + nameH + 5;
        }

        [self addSubview:iconBtn];
    }
    
    if (_headerDataArr.count == 0) {
        self.frame = CGRectMake(0, 0, self.frame.size.width, 0);
    }
}


-(void)titBtnClike:(UIButton *)sender{
   
    [_headerDataArr removeObjectAtIndex:sender.tag - 1000];
    [self.delegate BtnActionDelegate:_headerDataArr];

}


@end
