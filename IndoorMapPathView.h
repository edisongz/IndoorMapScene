//
//  IndoorMapPathView.h
//  WisdomMallAPP
//
//  Created by apple on 14-4-15.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyPositon.h"

@interface IndoorMapPathView : UIView

/**
 *  画路线的图层View
 */
- (void)drawPathWithPoints:(NSMutableArray *const)paths;

@end
