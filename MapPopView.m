//
//  MapPopView.m
//  WisdomMallAPP
//
//  Created by apple on 14-1-20.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "MapPopView.h"
#import "Constants.h"

#define CORNER_RADIUS                                   2.0f

@implementation MapPopView

- (id)initWithFrame:(CGRect)frame showAtPoint:(CGPoint)point withTile:(NSString *)title subTitle:(NSString *)subTitle
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _frame = frame;
        
        self.layer.cornerRadius = CORNER_RADIUS;
        self.backgroundColor = [UIColor clearColor];
        
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height - 5.0f)];
        contentView.layer.cornerRadius = CORNER_RADIUS;
        contentView.backgroundColor = RGBA(225, 225, 225, 1);
        [self addSubview:contentView];
        
        UIImage *image = [UIImage imageNamed:@"shop.png"];
        logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0f, (frame.size.height - 5.0f - image.size.height) * 0.5f, image.size.width, image.size.height)];
        logoImageView.image = image;
        [contentView addSubview:logoImageView];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(image.size.width + 20.0f, 2, 110.0f, 12.0f)];
        titleLabel.adjustsFontSizeToFitWidth = YES;
        titleLabel.minimumFontSize = 8.0f;
        titleLabel.text = title;
        titleLabel.font = FONT_HELVETICALNEUE_BOLD_SETTING(10.0f);
        titleLabel.textColor = RGBA(236, 66, 79, 1);//[UIColor colorWithRed:236/255 green:66/255 blue:79/255 alpha:1];;
        [contentView addSubview:titleLabel];
        
        subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(image.size.width + 20.0f, 15.0f, 110.0f, 10.0f)];
        subTitleLabel.text = subTitle;
        subTitleLabel.font = FONT_HELVETICALNEUE_SETTING(8.0f);
        [contentView addSubview:subTitleLabel];
        
        UIControl *control = [[UIControl alloc] initWithFrame:frame];
        [control addTarget:self action:@selector(onSelectShop) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:control];
    }
    return self;
}

- (void)setTitle:(NSString *)strTitle subTitle:(NSString *)subTitle
{
    titleLabel.text = strTitle;
    subTitleLabel.text = subTitle;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);//设置当前笔头颜色
    CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 1.0f);
    CGPoint addLines[] =
    {
        CGPointMake(_frame.size.width * 0.5f - 5.0f, _frame.size.height - 5.0f),
        CGPointMake(_frame.size.width * 0.5f, _frame.size.height),
        CGPointMake(_frame.size.width * 0.5f + 5.0f, _frame.size.height - 5.0f),
    };
    CGContextAddLines(context, addLines, sizeof(addLines)/sizeof(addLines[0]));
    
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFillStroke);
    
}

#pragma mark - select
- (void)onSelectShop
{
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"push2shopdetail" object:subTitleLabel.text];
}

@end
