//
//  DuanziListViewController.m
//  Duanzi
//
//  Created by mac on 15/4/29.
//  Copyright (c) 2015年 jiji. All rights reserved.
//

#import "DuanziListViewController.h"
#import "DefaultDuanziTableViewCell.h"

@interface DuanziListViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

/**
 *  用于计算高度的占位cell
 */
@property (nonatomic, strong) DefaultDuanziTableViewCell *placeHolderCell;

/**
 *  展示的段子数组
 */
@property (nonatomic, strong) NSArray *duanziDataArray;

@end

@implementation DuanziListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        self.title = @"看段子";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    DuanziContentLoader *duanziManager = [DuanziContentLoader duanziLoader];
    [duanziManager queryDuanziWithKeyString:nil completion:^(NSArray *resultArray) {
        
        if (resultArray.count > 0)
        {
            self.duanziDataArray = resultArray;


            UINib *cellNib = [UINib nibWithNibName:@"DefaultDuanziTableViewCell" bundle:nil];
            [self.tableView registerNib:cellNib forCellReuseIdentifier:@"DefaultCell"];
            self.placeHolderCell = [cellNib instantiateWithOwner:nil options:nil][0];
            
            self.tableView.delegate = self;
            self.tableView.dataSource = self;
            [self.tableView reloadData];
        }
    }];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    if (delegate.duanziListNeedRefresh)
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        delegate.duanziListNeedRefresh = NO;
        
        //刷新列表（这里太耗性能了。。。）
        DuanziContentLoader *duanziManager = [DuanziContentLoader duanziLoader];
        [duanziManager queryDuanziWithKeyString:nil completion:^(NSArray *resultArray) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];

            if (resultArray.count > 0)
            {
                self.duanziDataArray = resultArray;
                [self.tableView reloadData];
            }
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configCell:(DefaultDuanziTableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger index = indexPath.row;
    Duanzi *duanzi = self.duanziDataArray[index];
    
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
        
        //保存
        [[DuanziContentLoader duanziLoader] updateDuanziInfoWithDuanzi:duanzi];
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
        
        //保存
        [[DuanziContentLoader duanziLoader] updateDuanziInfoWithDuanzi:duanzi];
    };
    
    cell.favouriteEventBlock = ^(UIButton *button){
        duanzi.favourite = !duanzi.favourite;
        [weakCell setFavouriteStyle:duanzi.favourite];
        
        //保存
        [[DuanziContentLoader duanziLoader] updateDuanziInfoWithDuanzi:duanzi];
    };
}

#pragma mark - tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.duanziDataArray.count;
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
    
    DZDetailViewController *detailVC = [[DZDetailViewController alloc] initWithDuanzi:self.duanziDataArray[indexPath.row]];
    
    detailVC.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
}

@end
