//
//  FavouriteDuanziListViewController.m
//  Duanzi
//
//  Created by mac on 15/4/30.
//  Copyright (c) 2015年 jiji. All rights reserved.
//

#import "FavouriteDuanziListViewController.h"
#import "DefaultDuanziTableViewCell.h"
#import "DZLoadResultTableView.h"

@interface FavouriteDuanziListViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet DZLoadResultTableView *tableView;

/**
 *  收藏段子数组
 */
@property (nonatomic, strong) NSMutableArray *resultDataArray;

/**
 *  用于计算高度的占位cell
 */
@property (nonatomic, strong) DefaultDuanziTableViewCell *placeHolderCell;


@end

@implementation FavouriteDuanziListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        self.title = @"我的收藏";
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    DuanziContentLoader *duanziManager = [DuanziContentLoader duanziLoader];
    [duanziManager queryMyFavouriteDuanziCompletion:^(NSArray *resultArray) {
        if (resultArray.count > 0)
        {
            self.resultDataArray = [[NSMutableArray alloc] initWithArray:resultArray];
            
            UINib *cellNib = [UINib nibWithNibName:@"DefaultDuanziTableViewCell" bundle:nil];
            [self.tableView registerNib:cellNib forCellReuseIdentifier:@"DefaultCell"];
            self.placeHolderCell = [cellNib instantiateWithOwner:nil options:nil][0];
            
            
            self.tableView.delegate = self;
            self.tableView.dataSource = self;
            [self.tableView reloadData];
        }
        else
        {
            [self.tableView showLoadResultViewWithText:@"您还没有收藏任何段子"];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configCell:(DefaultDuanziTableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger index = indexPath.row;
    Duanzi *duanzi = self.resultDataArray[index];
    
    cell.contentLabel.text = duanzi.content;
    cell.contentLabel.numberOfLines = 0;
    cell.contentLabel.preferredMaxLayoutWidth = LCD_W - 16 * 3;
    
    
    [cell setLikeStyle:duanzi.like];
    [cell setDislikeStyle:duanzi.dislike];
    [cell setFavouriteStyle:duanzi.favourite];
    
    //赞、踩、收藏回调
    __weak DefaultDuanziTableViewCell *weakCell = cell;
    cell.likeEventBlock = ^(UIButton *button){
        if (!duanzi.like && !duanzi.dislike)//未赞过也未踩过，则反选
        {
            duanzi.like = !duanzi.like;
        }
        else
        {
            duanzi.like = !duanzi.like;
            duanzi.dislike = !duanzi.dislike;
        }
        [weakCell setLikeStyle:duanzi.like];
        [weakCell setDislikeStyle:duanzi.dislike];
        
        [DuanziCommDataManager updateDataWithDuanzi:duanzi];
    };
    
    cell.dislikeEventBlock = ^(UIButton *button){
        
        if (!duanzi.like && !duanzi.dislike)//未赞过也未踩过，则反选
        {
            duanzi.dislike = !duanzi.dislike;
        }
        else
        {
            duanzi.like = !duanzi.like;
            duanzi.dislike = !duanzi.dislike;
        }
        [weakCell setLikeStyle:duanzi.like];
        [weakCell setDislikeStyle:duanzi.dislike];
        
        [DuanziCommDataManager updateDataWithDuanzi:duanzi];
    };
    
    cell.favouriteEventBlock = ^(UIButton *button){
        duanzi.favourite = !duanzi.favourite;
        [weakCell setFavouriteStyle:duanzi.favourite];
        
        [DuanziCommDataManager updateDataWithDuanzi:duanzi];
        
        if (!duanzi.favourite)
        {
            [self.resultDataArray removeObject:duanzi];
            [self.tableView reloadData];
            if (self.resultDataArray.count == 0)
            {
                [self.tableView showLoadResultViewWithText:@"您还没有收藏任何段子"];
            }
        }
    };

}

#pragma mark - tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.resultDataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self configCell:self.placeHolderCell withIndexPath:indexPath];
    
    [self.placeHolderCell layoutSubviews];
    
    CGFloat height = [self.placeHolderCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    
    return (height + 1);//cell比contentView的高度大1
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DefaultDuanziTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DefaultCell" forIndexPath:indexPath];
    [self configCell:cell withIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DZDetailViewController *detailVC = [[DZDetailViewController alloc] initWithDuanzi:self.resultDataArray[indexPath.row]];
    
    detailVC.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
}



@end
