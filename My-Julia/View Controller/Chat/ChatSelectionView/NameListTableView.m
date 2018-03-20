//
//  NameListTableView.m
//  selection_List
//
//  Created by NTMC_MacMini on 2017/6/16.
//  Copyright © 2017年 bruce. All rights reserved.
//

#import "NameListTableView.h"

#import "ListTableViewCell.h"
#import "ChatGroupModel.h"
#import "UIImageView+WebCache.h"


@interface NameListTableView ()<UITableViewDelegate,
                              UITableViewDataSource,
                                  ListTableDelegate, UISearchResultsUpdating, UISearchBarDelegate>

@property(nonatomic ,strong) NSMutableArray *deleteArry;//要显示的数组
@property(nonatomic ,strong) UISearchController *searchController;//要显示的数组

@end

@implementation NameListTableView


-(instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{

    self = [super initWithFrame:frame style:style];
    if (self) {

    self.dataSource = self;
    self.delegate = self;
    }
    return self;
}

- (void)setDelegates
{
    self.dataSource = self;
    self.delegate = self;
    
    // Setup the Search Controller
    _searchController = [[UISearchController alloc] init];
    _searchController.searchResultsUpdater = self;
    _searchController.searchBar.delegate = self;
    //definesPresentationContext = true
    _searchController.dimsBackgroundDuringPresentation = false;
    
    self.backgroundColor = [UIColor clearColor];
    // Setup the Scope Bar
    self.tableHeaderView = _searchController.searchBar;
}

//NOTE: 默认选中的人物,在这里赋值
-(void)setSelectArr:(NSArray *)selectArr{
    
    [self.deleteArry removeAllObjects];
    [self.deleteArry addObjectsFromArray:selectArr];
    self.block(self.deleteArry);

}
//NOTE: 点击按钮刷新列表数据
-(void)setBtnActionArr:(NSArray *)BtnActionArr{

    [self.deleteArry removeAllObjects];
    [self.deleteArry addObjectsFromArray:BtnActionArr];
    [self reloadData];

}
#pragma mark ============== tableView 代理方法 ====================
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 65;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    if (self.isGroupTable) {
        return _allDataArr.count;
    }
    else {
        if (self.isSearchTable == true) {
            return _allDataArr.count;
        }
        else {
            return _allDataArr.count + 1;
        }
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ListTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"ListTableViewCell" owner:nil options:nil ]lastObject];
    }
    
    cell.backgroundColor = [UIColor clearColor];

    NSInteger index = indexPath.row;
    cell.userImgView.layer.cornerRadius = cell.userImgView.frame.size.height/2;
    cell.userImgView.clipsToBounds = YES;

    if (self.isGroupTable == false && self.isSearchTable == false) {
        index -= 1;
        
        if (indexPath.row == 0 ) {
            cell.seleImg.hidden = YES;
            cell.nameLab.text = @"New group";
            cell.nameLab.font = [UIFont boldSystemFontOfSize:15.0];
            cell.userImgView.image =  [UIImage imageNamed:@"create_group"]; //[ imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            cell.userImgView.backgroundColor = self.tintColor;
            
//            cell.userImgView.layer.cornerRadius = (cell.userImgView.frame.size.height)/2;
//            cell.userImgView.backgroundColor = [AppTheme.sharedInstance.backgroundColor darkerBy:30];
            return  cell;
        }
    }
  
    ChatGroupModel *model = self.allDataArr[index];
    cell.nameLab.text = model.name;
    cell.nameLab.font = [UIFont systemFontOfSize:15.0];

    if (model.iconUrl != nil) {
        NSURL *url = [NSURL URLWithString:model.iconUrl];
        [cell.userImgView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"user"]];
        [cell.userImgView.layer setBorderColor:[UIColor grayColor].CGColor];
        [cell.userImgView.layer setBorderWidth:1.0];
    }

    // NSDictionary *dic = _allDataArr[indexPath.row];
    // cell.nameLab.text = dic[@"USER_NAME"];
    cell.indexRow = indexPath.row;
    cell.delegate = self;
    NSLog(@"%@",self.deleteArry);
    //NOTE: 默认选中的人物,在此打对勾
    
    if ([self.deleteArry containsObject: model]){
        cell.seleImg.hidden = NO;
    }else{
        cell.seleImg.hidden = YES;
    }
    
    return cell;
}

//NOTE: 处理cell的点击
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if (self.isGroupTable ) {
        ListTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell.seleImg.hidden != YES) {
            //NOTE: 删除
            cell.seleImg.hidden = YES;
            [self.deleteArry removeObject:_allDataArr[indexPath.row]];
        }else{
            //NOTE: 添加
            [self.deleteArry addObject:_allDataArr[indexPath.row]];
            cell.seleImg.hidden = NO;
        }
        self.block(self.deleteArry);
    }
    else {
        if (self.isGroupTable == false && self.isSearchTable == false) {
            
            if (indexPath.row == 0) {
                self.newGropBlock();
            }
            else {
                self.newContactSelectBlock(self.allDataArr[indexPath.row - 1]);
            }
        }
        else {
            self.newContactSelectBlock(self.allDataArr[indexPath.row ]);
        }
    }
}

#pragma mark ========== 代理方法传进来点击的cell的下标和按钮的选中状态 ============
-(void) ListTableDelegate:(NSInteger )indexRow isRemov:(BOOL) is_remove{

    if (is_remove == YES) {
    
//NOTE: 删除
        [self.deleteArry removeObject:_allDataArr[indexRow]];

    }else{
//NOTE: 添加
        [self.deleteArry addObject:_allDataArr[indexRow]];

    }
    
    self.block(self.deleteArry);

}


-(NSMutableArray *)deleteArry{
    
    if (!_deleteArry) {
        _deleteArry = [NSMutableArray array];
    }
    return _deleteArry;

}


//func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
//    filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
//}

-(BOOL)searchBarIsEmpty {
    // Returns true if the text is empty or nil
    return _searchController.searchBar.text.length == 0 ? true : false;
}


- (void) filterContentForSearchText:(NSString*) searchText {
    
    NSPredicate *bPredicate = [NSPredicate predicateWithFormat:@"ChatGroupModel.name contains[cd] %@",searchText];
    self.filteredDataArr = [self.allDataArr filteredArrayUsingPredicate:bPredicate].mutableCopy;
    //NSLog(@"HERE %@",self.filteredArray);
    
    [self reloadData];
}

@end
