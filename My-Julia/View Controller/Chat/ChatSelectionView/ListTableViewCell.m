//
//  ListTableViewCell.m
//  selection_List
//
//  Created by NTMC_MacMini on 2017/6/19.
//  Copyright © 2017年 bruce. All rights reserved.
//

#import "ListTableViewCell.h"

@implementation ListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (IBAction)selectNameAction:(id)sender {
   
    UIButton *button = sender;

    if (button.selected != YES) {
        
    button.selected = YES;

    }else{
        
    button.selected = NO;
        
    }
    NSLog(@"%d",button.selected);
    [self.delegate ListTableDelegate:_indexRow isRemov:button.selected];

}

-(void)setIndexRow:(NSInteger)indexRow{

    _indexRow = indexRow;

}


@end
