//
//  Duanzi.h
//  Duanzi
//
//  Created by mac on 15/4/29.
//  Copyright (c) 2015年 jiji. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, Duanzi_Like_Type) {
    Duanzi_Like_None,
    Duanzi_Like_Like,
    Duanzi_Like_Hate
};

@interface Duanzi : NSObject

/**
 *  段子ID
 */
@property (nonatomic, assign) NSUInteger ID;
/**
 *  段子内容
 */
@property (nonatomic, strong) NSString *content;
/**
 *  点赞（NO--未选择，YES--赞）
 */
@property (nonatomic, assign) BOOL like;

/**
 *  点踩（NO--未选择，YES--踩）
 */
@property (nonatomic, assign) BOOL dislike;

/**
 *  是否已收藏
 */
@property (nonatomic, assign) BOOL favourite;

@end
