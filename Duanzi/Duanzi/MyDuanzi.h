//
//  MyDuanzi.h
//  Duanzi
//
//  Created by mac on 15/4/29.
//  Copyright (c) 2015年 jiji. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyDuanzi : NSObject

/**
 *  段子ID
 */
@property (nonatomic, assign) NSUInteger ID;
/**
 *  创建时间
 */
@property (nonatomic, strong) NSDate *createDate;

/**
 *  段子内容
 */
@property (nonatomic, strong) NSString *content;

@end
