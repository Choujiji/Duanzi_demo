//
//  MyDuanziListViewController.m
//  Duanzi
//
//  Created by mac on 15/4/30.
//  Copyright (c) 2015年 jiji. All rights reserved.
//

#import "MyDuanziListViewController.h"
#import "MyDuanziTableViewCell.h"
#import "DZLoadResultTableView.h"

static NSDateFormatter *dateFormatter = nil;

@interface MyDuanziListViewController () <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet DZLoadResultTableView *tableView;


/**
 *  我的段子数组
 */
@property (nonatomic, strong) NSMutableArray *resultDataArray;

/**
 *  用于计算高度的占位cell
 */
@property (nonatomic, strong) MyDuanziTableViewCell *placeHolderCell;

/**
 *  即将删除的段子引用
 */
@property (nonatomic, strong) MyDuanzi *delDuanzi;

@end

@implementation MyDuanziListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        self.title = @"我的段子";
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    DuanziContentLoader *duanziManager = [DuanziContentLoader duanziLoader];
    [duanziManager getAllMyDuanziWithCompletion:^(NSArray *resultArray) {
        if (resultArray.count > 0)
        {
            self.resultDataArray = [[NSMutableArray alloc] initWithArray:resultArray];
            
            UINib *cellNib = [UINib nibWithNibName:@"MyDuanziTableViewCell" bundle:nil];
            [self.tableView registerNib:cellNib forCellReuseIdentifier:@"MyDuanziCell"];
            self.placeHolderCell = [cellNib instantiateWithOwner:nil options:nil][0];
            
            
            self.tableView.delegate = self;
            self.tableView.dataSource = self;
            [self.tableView reloadData];
        }
        else
        {
            [self.tableView showLoadResultViewWithText:@"您还没有创造段子，赶快开始吧~~"];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)configCell:(MyDuanziTableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger index = indexPath.row;
    MyDuanzi *duanzi = self.resultDataArray[index];
    
    cell.contentLabel.text = duanzi.content;
    cell.contentLabel.numberOfLines = 0;
    cell.contentLabel.preferredMaxLayoutWidth = LCD_W - 8 * 2;
    
    
    if (!dateFormatter)
    {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMM dd HH:MM"];
        [dateFormatter setLocale:[NSLocale currentLocale]];
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    }
    
    cell.timeLabel.text = [dateFormatter stringFromDate:duanzi.createDate];
    
    __weak MyDuanziListViewController *duanziListVC = self;
    cell.deleteEventBlock = ^(UIButton *button){
        
        duanziListVC.delDuanzi = duanzi;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"删除我的段子？" message:nil delegate:duanziListVC cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
    };
}

#pragma mark - alert delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
    }
    else
    {
        [self.resultDataArray removeObject:self.delDuanzi];
        [self.tableView reloadData];
        
        //存储数据
        [[DuanziContentLoader duanziLoader] deleteMyDuanzi:self.delDuanzi];
        
        if (self.resultDataArray.count == 0)
        {
            [self.tableView showLoadResultViewWithText:@"您还没有创造段子，赶快开始吧~~"];
        }
    }
    
    
    self.delDuanzi = nil;
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
    MyDuanziTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyDuanziCell" forIndexPath:indexPath];
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
