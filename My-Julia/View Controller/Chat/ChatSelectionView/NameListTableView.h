//
//  NameListTableView.h
//  selection_List
//
//  Created by NTMC_MacMini on 2017/6/16.
//  Copyright © 2017年 bruce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderView.h"

typedef void(^HeaderBlock)(NSMutableArray *);
typedef void(^NewGroupBlock)(void);
typedef void(^NewContactSelectBlock)(id);


@interface NameListTableView : UITableView
//NOTE: 所有的数据
@property (nonatomic ,strong) NSMutableArray *allDataArr;
//NOTE: 默认的按钮
@property (nonatomic ,copy) NSArray *selectArr;
//NOTE: 回调
@property (nonatomic ,copy) HeaderBlock block;
//NOTE: 点击标签删除后的数组
@property (nonatomic ,copy) NSArray *BtnActionArr;

@property (nonatomic ,copy) NewGroupBlock newGropBlock;

@property (nonatomic ,copy) NewContactSelectBlock newContactSelectBlock;

@property (nonatomic ,assign) BOOL isGroupTable;
@property (nonatomic ,assign) BOOL isSearchTable;

@property (nonatomic ,strong) NSMutableArray *filteredDataArr;


- (void)setDelegates;

@end
