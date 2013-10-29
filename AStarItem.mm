//
//  AStarItem.m
//  TagImageView
//
//  Created by apple on 13-10-26.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "AStarItem.h"

@implementation AStarItem

@synthesize id_col,id_row, id_fid,id_f, id_g, id_h;

- (void)setPos:(int)col row:(int)row
{
    self.id_col = col;
    self.id_row = row;
}

@end
