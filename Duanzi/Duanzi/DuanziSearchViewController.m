//
//  DuanziSearchViewController.m
//  Duanzi
//
//  Created by mac on 15/4/29.
//  Copyright (c) 2015年 jiji. All rights reserved.
//

#import "DuanziSearchViewController.h"
#import "DefaultDuanziTableViewCell.h"
#import "DZLoadResultTableView.h"

typedef NS_ENUM(NSUInteger, DuanziSearchList_ShowType) {
    DuanziSearchList_HotKey,//热词搜索
    DuanziSearchList_SearchHistory,//搜索历史
    DuanziSearchList_SearchResult,//搜索结果
};

@interface DuanziSearchViewController () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet DZLoadResultTableView *tableView;


/**
 *  用于计算高度的占位cell
 */
@property (nonatomic, strong) DefaultDuanziTableViewCell *placeHolderCell;

/**
 *  搜索结果数组
 */
@property (nonatomic, strong) NSArray *searchResultDuanziArray;

/**
 *  热门key数组
 */
@property (nonatomic, strong) NSArray *hotSearchKeyArray;

/**
 *  搜索历史数组
 */
@property (nonatomic, strong) NSMutableArray *searchHistoryArray;

/**
 *  搜索列表显示类型
 */
@property (nonatomic, assign) DuanziSearchList_ShowType listShowType;

/**
 *  读取搜索历史
 */
- (void)loadSearchHistory;

/**
 *  保存新搜索关键字
 *
 *  @param searchKey 关键字
 */
- (void)recordSearchHistoryWithSearchKey:(NSString *)searchKey;

/**
 *  删除指定搜索关键字
 *
 *  @param searchKey 关键字
 */
- (void)deleteSearchHistoryWithSearchKey:(NSString *)searchKey;

/**
 *  清除搜索历史
 */
- (void)cleanSearchHistory;

@end

@implementation DuanziSearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        self.title = @"找段子";
    }
    return self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    id searchBarAppearance = [UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil];
    
    [searchBarAppearance setTitleTextAttributes:@{NSForegroundColorAttributeName: COLOR(209, 157, 0, 1)} forState:UIControlStateNormal];
    [searchBarAppearance setTitle:@"搜索"];

    
    
    self.searchBar.delegate = self;
    
    //默认为热词搜素
    self.listShowType = DuanziSearchList_HotKey;
    
    
    self.hotSearchKeyArray = @[@"老师", @"妈妈", @"校长", @"老婆", @"考试"];
    
    self.searchResultDuanziArray = [NSArray new];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    
    //读取搜索历史
    [self loadSearchHistory];

}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    if (delegate.duanziSearchListNeedRefresh)
    {
        delegate.duanziSearchListNeedRefresh = NO;
        
        if (self.searchResultDuanziArray.count > 0 && self.searchBar.text.length > 0)//搜索过，需要重新搜索结果
        {
            [self searchBarSearchButtonClicked:self.searchBar];
        }
    }
}

#pragma mark - 搜索历史
- (void)loadSearchHistory
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.searchHistoryArray = [[userDefaults objectForKey:Duanzi_SearchHistory_Key] mutableCopy];
    if (!self.searchHistoryArray)
    {
        self.searchHistoryArray = [NSMutableArray new];
    }
}


- (void)recordSearchHistoryWithSearchKey:(NSString *)searchKey
{
    //有重复的，换到队首
    if ([self.searchHistoryArray containsObject:searchKey])
    {
        [self.searchHistoryArray removeObject:searchKey];
    }
    else
    {
        //超过10个，移除最后一个
        if (self.searchHistoryArray.count == 10)
        {
            [self.searchHistoryArray removeLastObject];
        }
    }
   
    [self.searchHistoryArray insertObject:searchKey atIndex:0];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.searchHistoryArray forKey:Duanzi_SearchHistory_Key];
    [defaults synchronize];
}

- (void)deleteSearchHistoryWithSearchKey:(NSString *)searchKey
{
    if (searchKey.length == 0)
    {
        return;
    }
    
    if (![self.searchHistoryArray containsObject:searchKey])
    {
        return;
    }
    
    [self.searchHistoryArray removeObject:searchKey];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.searchHistoryArray forKey:Duanzi_SearchHistory_Key];
    [defaults synchronize];
}

- (void)cleanSearchHistory
{
    self.searchHistoryArray = [NSMutableArray new];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.searchHistoryArray forKey:Duanzi_SearchHistory_Key];
    [defaults synchronize];
}


#pragma mark - searchBar delegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    
    //显示历史列表
    self.listShowType = DuanziSearchList_SearchHistory;
    [self.tableView reloadData];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [searchBar resignFirstResponder];
    
    //记录搜索结果
    [self recordSearchHistoryWithSearchKey:searchBar.text];
    
    DuanziContentLoader *duanziManager = [DuanziContentLoader duanziLoader];
    [duanziManager queryDuanziWithKeyString:searchBar.text completion:^(NSArray *resultArray) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];

        NSString *searchResult = [NSString stringWithFormat:@"共找到%ld个结果", (unsigned long)resultArray.count];
        [self.tableView showLoadResultViewWithText:searchResult];

        if (resultArray.count > 0)
        {
            UINib *cellNib = [UINib nibWithNibName:@"DefaultDuanziTableViewCell" bundle:nil];
            [self.tableView registerNib:cellNib forCellReuseIdentifier:@"DefaultCell"];
            self.placeHolderCell = [cellNib instantiateWithOwner:nil options:nil][0];
            
            self.searchResultDuanziArray = resultArray;
            
            self.listShowType = DuanziSearchList_SearchResult;
            [self.tableView reloadData];
        }
        
    }];
}


- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];

    [searchBar resignFirstResponder];
    
    if (self.searchBar.text.length > 0)//若有搜索结果，还原回上次搜索
    {
        self.listShowType = DuanziSearchList_SearchResult;
        
        [self.tableView reloadData];
    }
    else//恢复热词状态
    {
        self.searchBar.text = nil;
        
        self.searchResultDuanziArray = [NSArray new];
        self.listShowType = DuanziSearchList_HotKey;
        
        [self.tableView reloadData];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length == 0)//点clear
    {
        
    }
}

#pragma mark - 配置cell


- (void)configCell:(DefaultDuanziTableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger index = indexPath.row;
    Duanzi *duanzi = self.searchResultDuanziArray[index];
    
    cell.contentLabel.text = duanzi.content;
    cell.contentLabel.numberOfLines = 0;
    cell.contentLabel.preferredMaxLayoutWidth = LCD_W - 8 * 2;
    
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
    };
}

#pragma mark - tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    switch (self.listShowType)
    {
        case DuanziSearchList_HotKey:
            count = self.hotSearchKeyArray.count + 1;//加1为提示语
            break;
        case DuanziSearchList_SearchHistory:
        {
            if (self.searchHistoryArray.count == 0)
            {
                count = 0;
            }
            else
            {
                count = self.searchHistoryArray. count + 1;
            }
        }
            break;
        case DuanziSearchList_SearchResult:
            count = self.searchResultDuanziArray.count;
        default:
            break;
    }
    
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.listShowType == DuanziSearchList_SearchHistory || self.listShowType == DuanziSearchList_HotKey)
    {
        return 44;
    }
    
    //搜索结果高度自定
    [self configCell:self.placeHolderCell withIndexPath:indexPath];
    
    [self.placeHolderCell layoutSubviews];
    
    CGFloat height = [self.placeHolderCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    
    return (height + 1);//cell比contentView的高度大1
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.listShowType == DuanziSearchList_HotKey)
    {
        static NSString *identifier = @"hotKeyCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        
        if (indexPath.row == 0)
        {
            cell.textLabel.text = @"热门搜索：";
        }
        else
        {
            cell.textLabel.text = self.hotSearchKeyArray[(indexPath.row - 1)];
        }
        return cell;
    }
    else if (self.listShowType == DuanziSearchList_SearchHistory )
    {
        static NSString *identifier = @"SearchHistoryCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        
        if ((indexPath.row > 0) && (indexPath.row == self.searchHistoryArray.count))//最后一个，显示清除历史记录
        {
            cell.textLabel.text = @"清除搜索记录";
        }
        else
        {
            cell.textLabel.text = self.searchHistoryArray[indexPath.row];
        }
        return cell;
    }
    
    //段子cell
    DefaultDuanziTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DefaultCell" forIndexPath:indexPath];
    [self configCell:cell withIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.listShowType == DuanziSearchList_HotKey)
    {
        if (indexPath.row >= 1)
        {
            self.searchBar.text = self.hotSearchKeyArray[(indexPath.row - 1)];//第一个是提示语
            [self searchBarSearchButtonClicked:self.searchBar];
        }
    }
    else if (self.listShowType == DuanziSearchList_SearchHistory)
    {
        if (indexPath.row == self.searchHistoryArray.count)//点击，清除历史记录
        {
            [self cleanSearchHistory];
            
            self.searchBar.text = nil;
            [self.searchBar becomeFirstResponder];
            
            [self.tableView reloadData];
        }
        else
        {
            self.searchBar.text = self.searchHistoryArray[indexPath.row];
            [self searchBarSearchButtonClicked:self.searchBar];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    //只有搜索历史列表可以编辑
    if (self.listShowType == DuanziSearchList_SearchHistory && indexPath.row < self.searchHistoryArray.count)
    {
        return YES;
    }
    
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //只有搜索历史列表可以编辑
    if (self.listShowType != DuanziSearchList_SearchHistory)
    {
        return;
    }
    
    
    if (editingStyle == UITableViewCellEditingStyleDelete && indexPath.row < self.searchHistoryArray.count)
    {
        NSString *deleteSearchKey = self.searchHistoryArray[indexPath.row];
        [self deleteSearchHistoryWithSearchKey:deleteSearchKey];
        if (self.searchHistoryArray.count == 0)
        {
            
        }
        [self.tableView reloadData];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    self.tableView = nil;
}

- (void)dealloc
{
    self.searchBar.delegate = nil;
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
}


@end
