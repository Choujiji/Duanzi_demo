//
//  DuanziCreateViewController.m
//  Duanzi
//
//  Created by mac on 15/4/29.
//  Copyright (c) 2015年 jiji. All rights reserved.
//

#import "DuanziCreateViewController.h"

#define Alert_MyDuanzi_Delete    1000
#define Alert_MyDuanzi_Save      1001

@interface DuanziCreateViewController () <UIAlertViewDelegate, UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *placeHolderLabel;


/**
 *  清除按钮回调
 *
 *  @param sender 按钮对象
 */
- (void)deleteContent:(id)sender;

/**
 *  保存按钮回调
 *
 *  @param sender 按钮对象
 */
- (void)saveNewDuanzi:(id)sender;


/**
 *  保存新段子
 *
 *  @param content 段子内容
 */
- (void)saveNewMyDuanziWithContent:(NSString *)content;

/**
 *  清除内容并检查删除草稿
 */
- (void)cleanSavedContentDraft;

/**
 *  保存草稿
 */
- (void)saveContentDraft;

/**
 *  读取草稿
 */
- (void)loadContentDraft;

@end

@implementation DuanziCreateViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        self.title = @"写段子";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *leftBbi = [[UIBarButtonItem alloc] initWithTitle:@"清除" style:UIBarButtonItemStylePlain target:self action:@selector(deleteContent:)];
    self.navigationItem.leftBarButtonItem = leftBbi;
    
    UIBarButtonItem *rightBbi = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(saveNewDuanzi:)];
    self.navigationItem.rightBarButtonItem = rightBbi;
    
    self.textView.delegate = self;
    
    //监听程序退出消息，保存草稿
    __weak DuanziCreateViewController *duanziCVC = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillTerminateNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        
        [duanziCVC saveContentDraft];
        
    }];
    
    //读取草稿
    [self loadContentDraft];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 按钮回调
- (void)deleteContent:(id)sender
{
    if (self.textView.text.length == 0)
    {
        return;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"清除编辑的段子？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"清除", nil];
    alert.tag = Alert_MyDuanzi_Delete;
    [alert show];
    
    [self.textView resignFirstResponder];
}

- (void)saveNewDuanzi:(id)sender
{
    if (self.textView.text.length == 0)
    {
        return;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"保存段子？" message:@"新段子可以在我的段子中查看" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"保存", nil];
    alert.tag = Alert_MyDuanzi_Save;
    [alert show];
    
    [self.textView resignFirstResponder];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == Alert_MyDuanzi_Save)
    {
        if (buttonIndex == 1)//保存
        {
            [self saveNewMyDuanziWithContent:self.textView.text];
            self.textView.text = nil;
            self.placeHolderLabel.hidden = NO;
        }
    }
    else if (alertView.tag == Alert_MyDuanzi_Delete)
    {
        if (buttonIndex == 1)//清除
        {
            [self cleanSavedContentDraft];
            self.textView.text = nil;
            self.placeHolderLabel.hidden = NO;
        }
    }
}

#pragma mark - textView delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    //模拟placeholder
    if (range.location == 0)
    {
        if (text.length == 0)
        {
            self.placeHolderLabel.hidden = NO;
        }
        else
        {
            self.placeHolderLabel.hidden = YES;
        }
    }
    
    //不允许换行
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}


#pragma mark - 保存与删除功能
- (void)saveNewMyDuanziWithContent:(NSString *)content
{
    if (content.length == 0)
    {
        return;
    }
    
    content = [self.textView.text copy];
    MyDuanzi *myDuanzi = [MyDuanzi new];
    myDuanzi.content = content;
    myDuanzi.createDate = [NSDate date];
    
    DuanziContentLoader *manager = [DuanziContentLoader duanziLoader];
    [manager saveNewMyDuanzi:myDuanzi];
}

- (void)cleanSavedContentDraft
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *draft = [defaults valueForKey:Duanzi_Draft_SaveKey];
    if (draft.length > 0)
    {
        draft = @"";
        
        [defaults setValue:draft forKey:Duanzi_Draft_SaveKey];
        [defaults synchronize];
    }
}

- (void)saveContentDraft
{
    if (self.textView.text.length == 0)
    {
        return;
    }
    
    NSString *draft = [self.textView.text copy];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:draft forKey:Duanzi_Draft_SaveKey];
    [defaults synchronize];
}

- (void)loadContentDraft
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *draft = [defaults valueForKey:Duanzi_Draft_SaveKey];
    if (draft.length > 0)
    {
        self.textView.text = draft;
    }
}



- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
}


@end
