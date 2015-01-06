//
//  FacilityPoints.h
//  WisdomMallAPP
//
//  Created by apple on 13-12-24.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FacilityPoints : NSObject

@property (nonatomic, copy) NSString *fMark;
@property (nonatomic, assign) int fIndex;
@property (nonatomic, copy) NSString *fName;
@property (assign, nonatomic) CGPoint point;
@property (nonatomic, assign) BOOL isParking;

@end
