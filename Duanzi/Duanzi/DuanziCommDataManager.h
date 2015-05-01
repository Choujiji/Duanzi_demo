//
//  DuanziCommDataManager.h
//  Duanzi
//
//  Created by mac on 15/4/30.
//  Copyright (c) 2015年 jiji. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DuanziCommDataManager : NSObject

/**
 *  保存数据
 *
 *  @param duanzi 段子对象
 */
+ (void)updateDataWithDuanzi:(Duanzi *)duanzi;

@end
