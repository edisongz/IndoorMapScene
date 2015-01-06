//
//  MifHeader.h
//  WisdomMallAPP
//
//  Created by apple on 13-12-10.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MifHeader : NSObject

@property (copy, nonatomic) NSString *version;
@property (copy, nonatomic) NSString *charSet;
@property (copy, nonatomic) NSString *delemiter;
@property (copy, nonatomic) NSString *coordSys;
@property (assign, nonatomic) CGRect frame;

@end
