//
//  DefaultDuanziTableViewCell.h
//  Duanzi
//
//  Created by mac on 15/4/29.
//  Copyright (c) 2015年 jiji. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^pressLikeBlock)(UIButton *button);
typedef void(^pressDislikeBlock)(UIButton *button);
typedef void(^pressFavouriteBlock)(UIButton *button);


@interface DefaultDuanziTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *dislikeButton;
@property (weak, nonatomic) IBOutlet UIButton *favouriteButton;

@property (nonatomic, strong) pressLikeBlock likeEventBlock;
@property (nonatomic, strong) pressDislikeBlock dislikeEventBlock;
@property (nonatomic, strong) pressFavouriteBlock favouriteEventBlock;

/**
 *  设置点赞状态
 *
 *  @param like 赞？
 */
- (void)setLikeStyle:(BOOL)like;

/**
 *  设置收藏状态
 *
 *  @param like 收藏？
 */
- (void)setFavouriteStyle:(BOOL)favourite;

/**
 *  设置踩状态
 *
 *  @param like 踩？
 */
- (void)setDislikeStyle:(BOOL)dislike;

@end
