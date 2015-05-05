//
//  DZDetailViewController.m
//  Duanzi
//
//  Created by mac on 15/5/5.
//  Copyright (c) 2015年 jiji. All rights reserved.
//

#import "DZDetailViewController.h"
#import "DefaultDuanziTableViewCell.h"

@interface DZDetailViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

/**
 *  用于计算高度的占位cell
 */
@property (nonatomic, strong) DefaultDuanziTableViewCell *placeHolderCell;

/**
 *  段子对象
 */
@property (nonatomic, strong) Duanzi *duanzi;

@end

@implementation DZDetailViewController

- (id)initWithDuanzi:(Duanzi *)duanzi
{
    if (self = [super initWithNibName:@"DZDetailViewController" bundle:nil])
    {
        self.duanzi = duanzi;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [NSString stringWithFormat:@"段子%lu",  (unsigned long)self.duanzi.ID];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UINib *cellNib = [UINib nibWithNibName:@"DefaultDuanziTableViewCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:@"DefaultCell"];
    self.placeHolderCell = [cellNib instantiateWithOwner:nil options:nil][0];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configCell:(DefaultDuanziTableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath
{
    cell.contentLabel.text = self.duanzi.content;
    cell.contentLabel.numberOfLines = 0;
    cell.contentLabel.preferredMaxLayoutWidth = LCD_W - 16 * 3;

    [cell setLikeStyle:self.duanzi.like];
    [cell setDislikeStyle:self.duanzi.dislike];
    [cell setFavouriteStyle:self.duanzi.favourite];
    
    //收藏回调
    __weak DefaultDuanziTableViewCell *weakCell = cell;
    
    cell.favouriteEventBlock = ^(UIButton *button){
        self.duanzi.favourite = !self.duanzi.favourite;
        [weakCell setFavouriteStyle:self.duanzi.favourite];

        [DuanziCommDataManager updateDataWithDuanzi:self.duanzi];
    };
    
}

#pragma mark - tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
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
}

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
}

@end
