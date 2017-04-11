//
//  AStar.m
//  TagImageView
//
//  Created by apple on 13-10-26.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "AStar.h"

#import "Utils.h"
#import "IndoorMapPath.h"

#import "ItemRelation.h"

#define INCREMENT           10

@implementation AStar

- (instancetype)init
{
    self = [super init];
    if (self) {
        _relationArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (int)getG:(int)col row:(int)row fid:(int)fid
{
    //获得该点的g函数值
    AStarItem *item = (AStarItem *)[close objectAtIndex:fid];
    
    int fx = [item id_col];
    int fy = [item id_row];
    int fg = [item id_g];
    
    if(fx - col != 0 && fy - row != 0) {
        return fg + 14;
    }
    else {
        return fg + 10;
    }
}

- (int)getH:(int)col row:(int)row
{
    //    AStarItem *item_dest = [[AStarItem alloc] init];
    //    item_dest.id_col = aimCol;
    //    item_dest.id_row = aimRow;
    //
    //    AStarItem *item_curr = [[AStarItem alloc] init];
    //    item_curr.id_col = col;
    //    item_curr.id_row = row;
    return abs(aimCol - col) * 10 + abs(aimRow - row) * 10;
}

- (void)fromOpenToClose {
    //把open列表中的点放到close列表中
    AStarItem * temp = (AStarItem *)[open objectAtIndex:1];
    [close addObject:temp];
    [open removeObjectAtIndex:1];
}

- (void)removeFromOpen
{
    
}

- (void)getPath
{
    //从整个close数组中找出路径
    if([path count] == 0) {
        [path addObject:[close objectAtIndex:[close count] - 1]];
    }
    else {
        [path insertObject:[close objectAtIndex:[close count] - 1] atIndex:[path count] - 1];
    }
    
    while(true) {
        if([(AStarItem *)[path objectAtIndex:0] id_g] == 0) {
            break;
        }
        [path insertObject:[close objectAtIndex:[(AStarItem *)[path objectAtIndex:0] id_fid]] atIndex:0];
    }
    
    curCol = aimCol;
    curRow = aimRow;
}

/**
 *  starting search
 *
 *  @param fid   fid
 *  @param paths 路径点数据
 */
- (void)starSearch:(int)fid withPaths:(NSMutableArray *)paths
{
    AStarItem *lastValidItem = (AStarItem *)[close objectAtIndex:fid];
    NSMutableArray *points = [self findNeighborPoints:lastValidItem];
    
    for (AStarItem *item in points) {
        int mycol = item.id_col;
        int myrow = item.id_row;
        
        if([self checkOpen:mycol row:myrow fid:fid] &&
           [self checkClose:mycol row:myrow]) {
            //上一点
            [self addToOpen:mycol row:myrow fid:fid];
        }
    }
}

/**
 *  找到最近的路径点
 */
- (AStarItem *)findNearestPoint:(int)col row:(int)row {
    AStarItem *astar = [[AStarItem alloc] init];
    if (self.allPointsArray) {
        CGFloat min = FLT_MAX;
        for (AStarItem *item in self.allPointsArray) {
            CGFloat distance = sqrtf(pow((col - item.id_col), 2) + pow((row - item.id_row), 2));
            if (distance < min) {
                min = distance;
                astar = item;
            }
        }
    }
    
    return astar;
}

/**
 *  找出邻接点
 *
 *  @param item 该店的邻接点
 *
 *  @return 邻接点集合
 */
- (NSMutableArray *)findNeighborPoints:(AStarItem *const)item {
    NSMutableArray *points = [[NSMutableArray alloc] init];
    if (self.relationArray) {
        for (ItemRelation *relation in self.relationArray) {
            if (item.id_col == relation.point1.col && item.id_row == relation.point1.row) { //同一点
                //如果有一个相等，另一个就是邻接点
                AStarItem *item1 = [[AStarItem alloc] init];
                [item1 setPos:relation.point2.col row:relation.point2.row];
                [points addObject:item1];
                continue;
            }
            
            if (item.id_col == relation.point2.col && item.id_row == relation.point2.row) { //同一点
                //如果有一个相等，另一个就是邻接点
                AStarItem *item2 = [[AStarItem alloc] init];
                [item2 setPos:relation.point1.col row:relation.point1.row];
                [points addObject:item2];
                continue;
            }
        }
    }
    return points;
}

/**
 *  两点之间的距离
 */
- (CGFloat)distanceOfTwoPointsFrom:(AStarItem *)from to:(AStarItem *)to {
    return sqrtf(pow((from.id_col - to.id_col), 2) + pow((from.id_row - to.id_row), 2));
}

- (void)resetSort:(NSInteger)last {
    //根据步长排序，堆排序
    while(last > 1){
        NSInteger half = last / 2;
        
        if([(AStarItem *)[open objectAtIndex:half] id_f] <= [(AStarItem *)[open objectAtIndex:last] id_f])
            break;
        [open exchangeObjectAtIndex:half withObjectAtIndex:last];
        last = half;
    }
}

- (BOOL)checkClose:(int)col row:(int)row {
    //检查close列表
    NSInteger count = [close count];
    for(NSInteger i = count - 1;i >= 0;i --) {
        if([(AStarItem *)[close objectAtIndex:i] id_col] == col &&
           [(AStarItem *)[close objectAtIndex:i] id_row] == row){
            return NO;
        }
    }
    return YES;
}

- (void)addToOpen:(int)col row:(int)row fid:(int)fid {
    //向open列表中加入点
    AStarItem * temp = [[AStarItem alloc] init];
    [temp setPos:col row:row];
    [temp setId_fid:fid];
    
    int g = [self getG:col row:row fid:fid];
    int h = [self getH:col row:row];
    [temp setId_g:g];
    [temp setId_h:h];
    [temp setId_f:(g + h)];
    [open addObject:temp];
    [self resetSort:[open count] - 1];
}

- (BOOL)checkMap:(int)col row:(int)row withPaths:(NSMutableArray *)paths {
    if (paths == nil) {
        return NO;
    }
    BOOL result = YES;
    CGPoint point = CGPointMake(col, row);
    
    for (id obj in paths) {
        if ([obj isKindOfClass:[IndoorMapPath class]]) {
            IndoorMapPath *indoorPath = obj;
            if (CGPathContainsPoint(indoorPath.mapArea.CGPath, NULL, point, false)) {
                result = NO;
                continue;
            }
        }else{
            
            result = YES;
            break;
        }
    }
    return result;
}

- (bool)checkOpen:(int)col row:(int)row fid:(int)fid {
    //检查open列表中是否有更小的步长，并排序
    for(NSUInteger i = [open count] - 1;i > 0;i --) {
        if([(AStarItem *)[open objectAtIndex:i] id_col] == col && [(AStarItem *)[open objectAtIndex:i] id_row] == row){
            int tempG = [self getG:col row:row fid:fid];
            if(tempG < [(AStarItem *)[open objectAtIndex:i] id_g]) {
                [(AStarItem *)[open objectAtIndex:i] setId_g:tempG];
                [(AStarItem *)[open objectAtIndex:i] setId_fid:fid];
                [(AStarItem *)[open objectAtIndex:i] setId_f:(tempG + [(AStarItem *)[open objectAtIndex:i] id_h])];
                [self resetSort:i];
            }
            return NO;
        }
    }
    return YES;
}

- (NSMutableArray *)findPath:(int)curX curY:(int)curY
                        aimX:(int)aimX aimY:(int)aimY
                    withPath:(NSMutableArray *)paths {
    
    //参数以及记录路径数组初始化
    curCol = curX;
    curRow = curY;
    aimCol = aimX;
    aimRow = aimY;
    path = [[NSMutableArray alloc] init];
    open = [[NSMutableArray alloc] init];
    
    AStarItem *temp = [[AStarItem alloc] init];
    [open addObject:temp];
    AStarItem *temp1 = [[AStarItem alloc] init];
    [temp1 setPos:curCol row:curRow];
    [temp1 setId_g:0];
    int ag = [self getH:curCol row:curRow];
    [temp1 setId_h:ag];
    [temp1 setId_fid:0];
    [temp1 setId_f:ag];
    [open addObject:temp1];
    
    if (close == nil) {
        close = [[NSMutableArray alloc] init];
    }
    [close removeAllObjects];
    
    //遍历寻找路径
    while([open count] > 1) {
        [self fromOpenToClose];//open和close列表管理
        NSUInteger fatherid = [close count] - 1;
        
        if(abs(aimCol - [(AStarItem *)[close objectAtIndex:fatherid] id_col]) <= 3 &&
           abs(aimRow - [(AStarItem *)[close objectAtIndex:fatherid] id_row]) <= 3) {
            [self getPath];
            break;
        }
        else {
            //搜索
            [self starSearch:fatherid withPaths:paths];
        }
    }
    
    [open removeAllObjects];
    [close removeAllObjects];
    //获得路径
    if([path count] == 0) {
        return NULL;
    }
    else {
        if([(AStarItem *)[path lastObject] id_col] != aimCol || [(AStarItem *)[path lastObject] id_row] != aimRow) {
            AStarItem * temp = [[AStarItem alloc] init];
            [temp setPos:aimCol row:aimRow];
            [path addObject:temp];
        }
        return path;
    }
}
@end
