//
//  IndoorMapView.h
//  IndoorMapScene
//
//  Created by apple on 13-10-29.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopoverView.h"

@interface IndoorMapView : UIScrollView<UIScrollViewDelegate, PopoverViewDelegate>
{
    NSMutableArray *data;
    UIImage *pathImg;
    
    UIPopoverController *pop;
    
    float minScale;
    BOOL is3DSettingRunning;
}

@property (nonatomic, strong) UIImageView *mapView;
@property (nonatomic, strong) UIImageView *tagImageView;

@property (nonatomic, strong) UIImageView *startImageView;
@property (nonatomic, strong) UIImageView *endImageView;
@property (nonatomic, strong) UIImageView *pathImageView;

@end
