//
//  Constants.h
//  IndoorMapScene
//
//  Created by 蒋益杰 on 15/1/6.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#ifndef IndoorMapScene_Constants_h
#define IndoorMapScene_Constants_h

#define MRScreenWidth                                   CGRectGetWidth([UIScreen mainScreen].applicationFrame)
#define MRScreenHeight                                  CGRectGetHeight([UIScreen mainScreen].applicationFrame)

#define SHOP_TYPE_UNKNOWN                               0
#define SHOP_TYPE_MAIN                                  1
#define SHOP_TYPE_LIFE                                  2
#define SHOP_TYPE_FASHION                               3
#define SHOP_TYPE_CHILDREN                              4
#define SHOP_TYPE_FOOD                                  5

#define FACILITY_NO_NDB                                 1
#define FACILITY_NO_ESCALATOR                           2
#define FACILITY_NO_LIFT                                3
#define FACILITY_NO_TOILETS                             4
#define FACILITY_NO_DISABLED_TOILETS                    5
#define FACILITY_NO_MCR                                 6
#define FACILITY_NO_CASHIER                             7
#define FACILITY_NO_CSC                                 8
#define FACILITY_NO_PARKING                             9
#define FACILITY_NO_PAYMENT_CETENR                      10//缴费中心，新增2014-04-15

#pragma mark - uiimage

#define BACK_IMAGE_NORMAL                               [UIImage imageNamed:@"img_back.png"]
#define BACK_IMAGE_SELECTED                             [UIImage imageNamed:@"img_back.png"]
#define FACILITY_IMAGE_NDB                              [UIImage imageNamed:@"品牌导航.png"]
#define FACILITY_IMAGE_ESCALATOR                        [UIImage imageNamed:@"扶手电梯.png"]
#define FACILITY_IMAGE_LIFT                             [UIImage imageNamed:@"垂直电梯.png"]
#define FACILITY_IMAGE_TOILETS                          [UIImage imageNamed:@"洗手间.png"]
#define FACILITY_IMAGE_DISABLED_TOILETS                 [UIImage imageNamed:@"残障洗手间.png"]
#define FACILITY_IMAGE_MCR                              [UIImage imageNamed:@"母婴室.png"]
#define FACILITY_IMAGE_CASHIER                          [UIImage imageNamed:@"收银台.png"]
#define FACILITY_IMAGE_CSC                              [UIImage imageNamed:@"顾客服务中心.png"]
#define FACILITY_IMAGE_PARKING                          [UIImage imageNamed:@"停车场.png"]
#define FACILITY_IMAGE_PAYMENT_CENTER                   [UIImage imageNamed:@"收银台.png"]

#define OFFSET_X                                        .0f
#define OFFSET_Y                                        85.0f
#define RATIO                                           (320.0f / 12.0f) * 1.0f
#define MAP_HEIGHT                                      10.0f

#define RGBA(__r__, __g__, __b__, __a__)                [UIColor colorWithRed:__r__/255.0 green:__g__/255.0 blue:__b__/255.0 alpha:__a__]

#define COLOR_MAP_UNKNOWN                               [UIColor colorWithRed:202.0f/255.0f green:205.0f/255.0 blue:196.0f/255.0 alpha:1]
#define COLOR_MAP_MAIN                                  [UIColor colorWithRed:176.0f/255.0f green:118.0f/255.0 blue:166.0f/255.0 alpha:1]
#define COLOR_MAP_LIFE                                  [UIColor colorWithRed:186.0f/255.0f green:168.0f/255.0 blue:115.0f/255.0 alpha:1]
#define COLOR_MAP_FASHION                               [UIColor colorWithRed:102.0f/255.0f green:169.0f/255.0 blue:214.0f/255.0 alpha:1]
#define COLOR_MAP_CHILDREN                              [UIColor colorWithRed:138.0f/255.0f green:166.0f/255.0 blue:164.0f/255.0 alpha:1]
#define COLOR_MAP_FOOD                                  [UIColor colorWithRed:233.0f/255.0f green:153.0f/255.0 blue:144.0f/255.0 alpha:1]

#define COLOR_MAP_PARKING                               [UIColor colorWithRed:255.0f/255.0f green:251.0f/255.0 blue:214.0f/255.0 alpha:1]
#define COLOR_MAP_BUILDING                              [UIColor colorWithRed:199.0f/255.0f green:198.0f/255.0 blue:197.0f/255.0 alpha:1]
#define COLOR_MAP_FRAME                                 [UIColor colorWithRed:155.0f/255.0f green:155.0f/255.0 blue:155.0f/255.0 alpha:1]

#endif
