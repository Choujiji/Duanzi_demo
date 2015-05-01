//
//  DefaultDuanziTableViewCell.m
//  Duanzi
//
//  Created by mac on 15/4/29.
//  Copyright (c) 2015年 jiji. All rights reserved.
//

#import "DefaultDuanziTableViewCell.h"

@implementation DefaultDuanziTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    [self.likeButton addTarget:self action:@selector(likeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.dislikeButton addTarget:self action:@selector(dislikeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.favouriteButton addTarget:self action:@selector(favouriteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - 按钮回调
- (void)likeButtonPressed:(id)sender
{
    if (self.likeEventBlock)
    {
        self.likeEventBlock((UIButton *)sender);
    }
    
}

- (void)dislikeButtonPressed:(id)sender
{
    if (self.dislikeEventBlock)
    {
        self.dislikeEventBlock((UIButton *)sender);
    }
    
}

- (void)favouriteButtonPressed:(id)sender
{
    if (self.favouriteEventBlock)
    {
        self.favouriteEventBlock((UIButton *)sender);
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setLikeStyle:(BOOL)like
{
    UIColor *textColor = like ? [UIColor redColor] : [UIColor darkGrayColor];
    
    [self.likeButton setTitleColor:textColor forState:UIControlStateNormal];
    self.likeButton.enabled = !like;
}

- (void)setFavouriteStyle:(BOOL)favourite
{
    UIColor *textColor = favourite ? [UIColor yellowColor] : [UIColor darkGrayColor];
    
    [self.favouriteButton setTitleColor:textColor forState:UIControlStateNormal];
}

- (void)setDislikeStyle:(BOOL)dislike
{
    UIColor *textColor = dislike ? [UIColor blueColor] : [UIColor darkGrayColor];
    
    [self.dislikeButton setTitleColor:textColor forState:UIControlStateNormal];
    self.dislikeButton.enabled = !dislike;
}


@end
