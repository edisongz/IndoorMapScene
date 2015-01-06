//
//  Shop.h
//  WisdomMallAPP
//
//  Created by apple on 13-12-20.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Shop : NSObject

@property (copy, nonatomic) NSString *shopId;
@property (copy, nonatomic) NSString *shopName;
@property (copy, nonatomic) NSString *shopMainClass;
@property (copy, nonatomic) NSString *shopSubClass;

@property (copy, nonatomic) NSString *shopLogoImageThumbnail;
@property (copy, nonatomic) NSString *shopPublicityImage;
@property (copy, nonatomic) NSString *shopLogo;

@property (copy, nonatomic) NSString *shopFloor;
@property (copy, nonatomic) NSString *shopAddressNo;
@property (copy, nonatomic) NSString *shopPhone;

@property (copy, nonatomic) NSString *shopWebsite;
@property (copy, nonatomic) NSString *shopDescription;
@property (copy, nonatomic) NSString *shopContacts;
@property (copy, nonatomic) NSString *userEvaluation;
@property (copy, nonatomic) NSString *mallid;

@property (assign, nonatomic) BOOL isUserFavorite;

@property (copy, nonatomic) NSString *shopGroupPurch;
@property (copy, nonatomic) NSString *shopPromotion;
@property (copy, nonatomic) NSString *shopActivity;

@property (assign, nonatomic) int starNum;

@end
