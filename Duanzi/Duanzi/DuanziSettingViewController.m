//
//  DuanziSettingViewController.m
//  Duanzi
//
//  Created by mac on 15/4/29.
//  Copyright (c) 2015年 jiji. All rights reserved.
//

#import "DuanziSettingViewController.h"
#import "FavouriteDuanziListViewController.h"
#import "MyDuanziListViewController.h"
#import "DZAboutUsViewController.h"

@interface DuanziSettingViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *settingItemArray;

@end

@implementation DuanziSettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        self.title = @"设置";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.settingItemArray = @[@"我的收藏", @"我的段子", @"关于我们"];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    switch (section)
    {
        case 0:
            count = 2;
            break;
        case 1:
            count = 1;
            break;
            
        default:
            break;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"settingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    
    NSString *itemTitle = nil;
    switch (indexPath.section)
    {
        case 0:
            itemTitle = self.settingItemArray[indexPath.row];
            break;
        case 1:
            itemTitle = self.settingItemArray[indexPath.row + 2];
            break;
            
        default:
            itemTitle = @"";
            break;
    }

    cell.textLabel.text = itemTitle;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    //收藏、段子、反馈、关于
    UIViewController *vc = nil;

    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)//收藏
        {
            vc = [[FavouriteDuanziListViewController alloc] initWithNibName:@"FavouriteDuanziListViewController" bundle:nil];
        }
        else if (indexPath.row == 1)//段子
        {
            vc = [[MyDuanziListViewController alloc] initWithNibName:@"MyDuanziListViewController" bundle:nil];
        }
        
    }
    else if (indexPath.section == 1)//关于
    {
        vc = [[DZAboutUsViewController alloc] initWithNibName:@"DZAboutUsViewController" bundle:nil];
    }
    
    if (vc)
    {
        vc.hidesBottomBarWhenPushed = YES;//当指定的vc将要被push进时，自动隐藏bottomBar（由于self的默认为NO，所以返回的时候bottomBar还会在）
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
}

@end
