//
//  IndoorMapPath.h
//  WisdomMallAPP
//
//  Created by apple on 13-12-18.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PrimitivePoints.h"

@interface IndoorMapPath : NSObject
{
    UIBezierPath        *_mapArea;
}

@property (nonatomic, retain)   UIBezierPath        *mapArea;
@property (nonatomic, copy)     NSString            *areaLocation;

/**
 *  初始化多边形区域
 **/
-(id)initWithPrimitives:(NSMutableArray *)primitives
           areaLocation:(NSString *)areaLocation;

/**
 *  检测区域是否被点击
 **/
-(BOOL)isAreaSelected:(CGPoint)inPointTouch;

@end
