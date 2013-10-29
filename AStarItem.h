//
//  AStarItem.h
//  TagImageView
//
//  Created by apple on 13-10-26.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AStarItem : NSObject

@property (nonatomic, assign) int id_col;
@property (nonatomic, assign) int id_row;
@property (nonatomic, assign) int id_g;
@property (nonatomic, assign) int id_h;
@property (nonatomic, assign) int id_fid;
@property (nonatomic, assign) int id_f;

- (void)setPos:(int)col row:(int)row;

@end
