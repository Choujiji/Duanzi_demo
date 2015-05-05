//
//  DuanziContentLoader.h
//  Duanzi
//
//  Created by mac on 15/4/29.
//  Copyright (c) 2015年 jiji. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Duanzi;
@class MyDuanzi;

@interface DuanziContentLoader : NSObject

#pragma mark - 初始化方法
/**
 *  单例创建方法
 *
 *  @return 单例对象
 */
+ (DuanziContentLoader *)duanziLoader;

/**
 *  创建数据库并存储所有初始数据
 */
- (void)createDatabaseAndSaveDefaultData;


#pragma mark - 系统默认段子功能

/**
 *  检查加载新数据
 */
- (void)loadNewDefaultData;

/**
 *  使用关键字查询数据库
 *
 *  @param keyString  关键字（nil为返回所有数据）
 *  @param completion 查询结果block
 */
- (void)queryDuanziWithKeyString:(NSString *)keyString completion:(void(^)(NSArray *resultArray))completion;

/**
 *  获取收藏的段子列表
 *
 *  @param completion 查询结果block
 */
- (void)queryMyFavouriteDuanziCompletion:(void(^)(NSArray *resultArray))completion;

/**
 *  更新段子对象，保存数据库
 *
 *  @param duanzi 段子对象
 */
- (void)updateDuanziInfoWithDuanzi:(Duanzi *)duanzi;

#pragma mark - 个人创建段子功能
/**
 *  保存新创建的段子
 *
 *  @param myDuanzi 新段子对象
 */
- (void)saveNewMyDuanzi:(MyDuanzi *)myDuanzi;

/**
 *  删除自己创建的段子
 *
 *  @param myDuanzi 自己创建的段子对象
 */
- (void)deleteMyDuanzi:(MyDuanzi *)myDuanzi;

/**
 *  获取所有个人段子数据
 *
 *  @param completion 查询结果block
 */
- (void)getAllMyDuanziWithCompletion:(void(^)(NSArray *resultArray))completion;

@end
