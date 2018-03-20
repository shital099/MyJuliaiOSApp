//
//  HeaderView.h
//  selection_List
//
//  Created by NTMC_MacMini on 2017/6/16.
//  Copyright © 2017年 bruce. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol headerDelegate <NSObject>
//NOTE: arr为要展示的数组
-(void)BtnActionDelegate:(NSMutableArray *)arr;

@end

@interface HeaderView : UIView

//NOTE:表头的数据
@property (nonatomic ,strong) NSMutableArray *headerDataArr;

@property (nonatomic ,assign) id<headerDelegate> delegate;

@end
