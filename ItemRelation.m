//
//  ItemRelation.m
//  WisdomMallAPP
//
//  Created by apple on 14-5-7.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "ItemRelation.h"

@implementation ItemPoint



@end

@implementation ItemRelation

- (instancetype)init
{
    self = [super init];
    if (self) {
        _point1 = [[ItemPoint alloc] init];
        _point2 = [[ItemPoint alloc] init];
    }
    return self;
}

@end
