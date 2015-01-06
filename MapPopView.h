//
//  MapPopView.h
//  WisdomMallAPP
//
//  Created by apple on 14-1-20.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapPopView : UIView
{
    CGRect _frame;
    
    UIImageView *logoImageView;
    
    UILabel *titleLabel;
    UILabel *subTitleLabel;
}

- (id)initWithFrame:(CGRect)frame showAtPoint:(CGPoint)point withTile:(NSString *)title subTitle:(NSString *)subTitle;
- (void)setTitle:(NSString *)strTitle subTitle:(NSString *)subTitle;

@end
