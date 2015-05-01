//
//  MyDuanziTableViewCell.m
//  Duanzi
//
//  Created by mac on 15/4/29.
//  Copyright (c) 2015年 jiji. All rights reserved.
//

#import "MyDuanziTableViewCell.h"

@implementation MyDuanziTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    [self.deleteButton addTarget:self action:@selector(deleteDuanzi:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)deleteDuanzi:(id)sender
{
    if (self.deleteEventBlock)
    {
        self.deleteEventBlock((UIButton *)sender);
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
