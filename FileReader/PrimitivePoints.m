//
//  PrimitivePoint.m
//  WisdomMallAPP
//
//  Created by apple on 13-12-10.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PrimitivePoints.h"

//对象Point
@implementation MPoint



@end

//属性对象
@implementation MyProperty



@end

@implementation PrimitivePoints

- (id)init
{
    self = [super init];
    if (self) {
        _pointArray = [[NSMutableArray alloc] init];
        _property = [[MyProperty alloc] init];
        _hasProperty = NO;
    }
    return self;
}

@end
