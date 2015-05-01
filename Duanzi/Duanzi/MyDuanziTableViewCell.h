//
//  MyDuanziTableViewCell.h
//  Duanzi
//
//  Created by mac on 15/4/29.
//  Copyright (c) 2015年 jiji. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^pressDeleteBlock)(UIButton *button);


@interface MyDuanziTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

/**
 *  删除事件回调
 */
@property (nonatomic, strong) pressDeleteBlock deleteEventBlock;

@end
