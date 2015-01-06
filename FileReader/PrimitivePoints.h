//
//  PrimitivePoint.h
//  WisdomMallAPP
//
//  Created by apple on 13-12-10.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 *  点对象
 */
@interface MPoint : NSObject

@property (assign, nonatomic) CGFloat x;
@property (assign, nonatomic) CGFloat y;

@end

/*
 *  属性对象
 */
@interface MyProperty : NSObject

@property (copy, nonatomic) NSString *floorNo;
@property (copy, nonatomic) NSString *parkingNo;
@property (copy, nonatomic) NSString *propertyName;
@property (copy, nonatomic) NSString *propertyNo;

@end

@interface PrimitivePoints : NSObject

@property (copy, nonatomic) NSString *type;
@property (strong, nonatomic) NSMutableArray *pointArray;

@property (assign, nonatomic) BOOL hasProperty;
@property (strong, nonatomic) MyProperty *property;

@property (assign, nonatomic) CGPoint startPoint;
@property (assign, nonatomic) CGPoint endPoint;

@end
