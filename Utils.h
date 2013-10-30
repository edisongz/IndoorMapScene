//
//  Utils.h
//  IndoorMapScene
//
//  Created by apple on 13-10-29.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject

+ (UIBezierPath *)bezierPathFromCoordinateString:(NSString *)strCoordinate;
+ (NSString *)pathStringWithFrame:(CGRect)rect;
+ (CGPoint)gravityPointInRect:(CGRect)rect;

@end
