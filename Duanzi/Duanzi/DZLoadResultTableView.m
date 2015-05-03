//
//  DZLoadResultTableView.m
//  Duanzi
//
//  Created by mac on 15/5/4.
//  Copyright (c) 2015年 jiji. All rights reserved.
//

#import "DZLoadResultTableView.h"

@interface DZLoadResultTableView ()

/**
 *  显示加载结果的view
 */
@property (nonatomic, strong) UIView *resultView;

/**
 *  加载视图
 *
 *  @return 文字label
 */
- (UILabel *)loadResultView;

/**
 *  隐藏resultView
 */
- (void)hideLoadResultView;

@end

@implementation DZLoadResultTableView

- (DZLoadResultTableView *)showLoadResultViewWithText:(NSString *)text
{
    UILabel *label = [self loadResultView];
    label.text = text;
    
    self.resultView.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        self.resultView.alpha = 1;
    } completion:^(BOOL finished) {
        [self hideLoadResultView];
    }];
    
    
    return self;
}

- (UILabel *)loadResultView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, LCD_W, 30)];
    view.backgroundColor = [UIColor yellowColor];
    self.resultView = view;
    [self addSubview:view];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, LCD_W - 5 * 2, 30)];
    label.numberOfLines = 1;
    label.adjustsFontSizeToFitWidth = YES;
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    [view addSubview:label];
    
    return label;
}

- (void)hideLoadResultView
{
    [UIView animateWithDuration:0.3 delay:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.resultView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.resultView removeFromSuperview];
    }];
}

@end
