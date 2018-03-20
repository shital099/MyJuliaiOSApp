//
//  ListTableViewCell.h
//  selection_List
//
//  Created by NTMC_MacMini on 2017/6/19.
//  Copyright © 2017年 bruce. All rights reserved.
//



#import <UIKit/UIKit.h>
/*
 **
 * indexRow NOTE:cell的下标
 * is_remove NOTE:按钮的选中状态
 */
@protocol ListTableDelegate <NSObject>

-(void) ListTableDelegate:(NSInteger )indexRow isRemov:(BOOL) is_remove;

@end

@interface ListTableViewCell : UITableViewCell
//NOTE: 名字
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
//NOTE: 当前下标
@property (nonatomic ,assign) NSInteger indexRow;
//NOTE: 名字按钮
@property (weak, nonatomic) IBOutlet UIImageView *seleImg;

@property (weak, nonatomic) IBOutlet UIImageView *userImgView;

@property (nonatomic ,assign) id<ListTableDelegate> delegate;

@end
