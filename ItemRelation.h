//
//  ItemRelation.h
//  WisdomMallAPP
//
//  Created by apple on 14-5-7.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ItemPoint : NSObject

@property (nonatomic, assign) int col;
@property (nonatomic, assign) int row;

@end

@interface ItemRelation : NSObject

@property (nonatomic, strong) ItemPoint *point1;
@property (nonatomic, strong) ItemPoint *point2;

@end
