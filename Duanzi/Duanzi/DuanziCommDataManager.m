//
//  DuanziCommDataManager.m
//  Duanzi
//
//  Created by mac on 15/4/30.
//  Copyright (c) 2015年 jiji. All rights reserved.
//

#import "DuanziCommDataManager.h"

@implementation DuanziCommDataManager

+ (void)updateDataWithDuanzi:(Duanzi *)duanzi
{
    //保存
    [[DuanziContentLoader duanziLoader] updateDuanziInfoWithDuanzi:duanzi];
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    if (!delegate.duanziListNeedRefresh)
    {
        delegate.duanziListNeedRefresh = YES;
    }
    
    if (!delegate.duanziSearchListNeedRefresh)
    {
        delegate.duanziSearchListNeedRefresh = YES;
    }
}

@end
