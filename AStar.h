//
//  AStar.h
//  TagImageView
//
//  Created by apple on 13-10-26.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AStarItem.h"

@interface AStar : NSObject
{
    int curCol, curRow, aimCol, aimRow;
	int AimX, AimY, AimW, AimH;
//	CCTMXTiledMap* map;
    NSMutableArray *open;
    NSMutableArray *close;
    NSMutableArray *path;
}

@property (strong, nonatomic) NSMutableArray *allPointsArray;//所有路径点集合
@property (strong, nonatomic) NSMutableArray *relationArray;//所有路径点邻接点关系集合

- (int)getG:(int)col row:(int)row fid:(int)fid;
- (int)getH:(int)col row:(int)row;

- (void)fromOpenToClose;
- (void)removeFromOpen;
- (void)getPath;
//- (void)starSearch:(int)fid;
- (void)starSearch:(int)fid withPaths:(NSMutableArray *)paths;

- (void)resetSort:(int)last;
- (BOOL)checkClose:(int)col row:(int)row;
- (void)addToOpen:(int)col row:(int)row fid:(int)fid;
//- (bool)checkMap:(int)col row:(int)row;
- (BOOL)checkMap:(int)col row:(int)row withPaths:(NSMutableArray *)paths;
- (bool)checkOpen:(int)col row:(int)row fid:(int)fid;
//- (NSMutableArray *)findPath:(int)curX curY:(int)curY aimX:(int)aimX aimY:(int)aimY;
- (NSMutableArray *)findPath:(int)curX curY:(int)curY aimX:(int)aimX aimY:(int)aimY withPath:(NSMutableArray *)paths;


//new method
/**
 *  找出邻接点
 *
 *  @param item 该店的邻接点
 *
 *  @return 邻接点集合
 */
- (NSMutableArray *)findNeighborPoints:(AStarItem *const)item;

/**
 *  找出距离设施或人最近的点
 *
 */
- (AStarItem *)findNearestPoint:(int)col row:(int)row;

- (NSMutableArray *)findMinDisTancePoints:(AStarItem *const)item count:(int)count;
- (BOOL)isLinkedPointFrom:(AStarItem *const)from to:(AStarItem *)to;

@end
