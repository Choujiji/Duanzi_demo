//
//  AppDelegate.h
//  Duanzi
//
//  Created by mac on 15/4/29.
//  Copyright (c) 2015年 jiji. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

/**
 *  需要刷新段子列表（进行了数据库操作）
 */
@property (nonatomic, assign) BOOL duanziListNeedRefresh;

/**
 *  需要刷新段子搜索结果列表（进行了数据库操作）
 */
@property (nonatomic, assign) BOOL duanziSearchListNeedRefresh;


@end

