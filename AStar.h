//
//  AStar.h
//  TagImageView
//
//  Created by apple on 13-10-26.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AStar : NSObject
{
    int curCol, curRow, aimCol, aimRow;
	int AimX, AimY, AimW, AimH;
//	CCTMXTiledMap* map;
    NSMutableArray *open;
    NSMutableArray *close;
    NSMutableArray *path;
}

- (int)getG:(int)col row:(int)row fid:(int)fid;
- (int)getH:(int)col row:(int)row;
- (void)fromOpenToClose;
- (void)removeFromOpen;
- (void)getPath;
- (void)starSearch:(int)fid;
- (void)resetSort:(int)last;
- (bool)checkClose:(int)col row:(int)row;
- (void)addToOpen:(int)col row:(int)row fid:(int)fid;
- (bool)checkMap:(int)col row:(int)row;
- (bool)checkOpen:(int)col row:(int)row fid:(int)fid;
- (NSMutableArray *)findPath:(int)curX curY:(int)curY aimX:(int)aimX aimY:(int)aimY;

@end
