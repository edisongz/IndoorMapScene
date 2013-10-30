//
//  AStar.m
//  TagImageView
//
//  Created by apple on 13-10-26.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "AStar.h"
#import "AStarItem.h"
#import "Utils.h"

@implementation AStar

- (int)getG:(int)col row:(int)row fid:(int)fid
{
    //获得该点的g函数值
	int fx = [(AStarItem *)[close objectAtIndex:fid] id_col];
	int fy = [(AStarItem *)[close objectAtIndex:fid] id_row];
	int fg = [(AStarItem *)[close objectAtIndex:fid] id_g];
	if(fx - col != 0 && fy - row != 0){
        return fg + 14;
	}else{
        return fg + 10;
	}
}

- (int)getH:(int)col row:(int)row
{
	return abs(aimCol - col) * 10 + abs(aimRow - row) * 10;
}

- (void)fromOpenToClose
{
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
	if([path count] == 0)
    {
        [path addObject:[close objectAtIndex:[close count] - 1]];
	}
    else
    {
        [path insertObject:[close objectAtIndex:[close count] - 1] atIndex:[path count] - 1];
	}
	while(true)
    {
		if([(AStarItem *)[path objectAtIndex:0] id_g] == 0)
        {
            break;
		}
        [path insertObject:[close objectAtIndex:[(AStarItem *)[path objectAtIndex:0] id_fid]] atIndex:0];
	}
	curCol = aimCol;
	curRow = aimRow;
}

- (void)starSearch:(int)fid
{
    int col = [(AStarItem *)[close objectAtIndex:fid] id_col];
	int row = [(AStarItem *)[close objectAtIndex:fid] id_row];
    
    //搜索目前点的上下左右四个方向
	int mycol = col;
	int myrow = row - 5;
	if(myrow >= 0 && [self checkMap:mycol row:myrow]){
		if([self checkOpen:mycol row:myrow fid:fid] && [self checkClose:mycol row:myrow]){
            [self addToOpen:mycol row:myrow fid:fid];
		}
	}
	mycol = col - 5;
	myrow = row;
	if(mycol >= 0 && [self checkMap:mycol row:myrow]){
		if([self checkOpen:mycol row:myrow fid:fid] && [self checkClose:mycol row:myrow]){
            [self addToOpen:mycol row:myrow fid:fid];
		}
	}
	mycol = col;
	myrow = row + 5;
	if(myrow < 2000 && [self checkMap:mycol row:myrow]){
		if([self checkOpen:mycol row:myrow fid:fid] && [self checkClose:mycol row:myrow]){
            [self addToOpen:mycol row:myrow fid:fid];
		}
	}
	mycol = col + 5;
	myrow = row;
	if(mycol < 2000 && [self checkMap:mycol row:myrow]){
		if([self checkOpen:mycol row:myrow fid:fid] && [self checkClose:mycol row:myrow]){
            [self addToOpen:mycol row:myrow fid:fid];
		}
	}
}

- (void)resetSort:(int)last
{
    //根据步长排序，堆排序
	while(last > 1){
        int half = last / 2;
        
        if([(AStarItem *)[open objectAtIndex:half] id_f] <= [(AStarItem *)[open objectAtIndex:last] id_f])
            break;
        [open exchangeObjectAtIndex:half withObjectAtIndex:last];
        last = half;
	}
}

- (bool)checkClose:(int)col row:(int)row
{
    //检查close列表
	for(int i = [close count] - 1;i > 0;i --)
    {
        if([(AStarItem *)[close objectAtIndex:i] id_col] == col && [(AStarItem *)[close objectAtIndex:i] id_row] == row){
            return false;
		}
	}
    return YES;
}

- (void)addToOpen:(int)col row:(int)row fid:(int)fid
{
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

- (bool)checkMap:(int)col row:(int)row
{
    CGPoint point = CGPointMake(col, row);
    
    NSString *obstacle00 = @"1524,901,1584,901,1583,1048,1552,1048,1551,955,1523,953";
    NSString *obstacle01 = @"1520,760,1583,760,1583,871,1520,871";
    NSString *obstacle02 = @"1609,763,1629,764,1630,865,1611,867";
    NSString *obstacle03 = @"1667,764,1749,764,1750,694,1776,695,1777,786,1698,786,1698,901,1668,901";
    NSString *obstacle04 = @"1610,670,1718,670,1718,729,1610,729";
    NSString *obstacle05 = @"1667,764,1749,764,1750,694,1776,695,1777,786,1698,786,1698,901,1668,901";
    NSString *obstacle06 = @"1497,700,1580,700,1580,740,1497,740";
    
    UIBezierPath  *path00 = [Utils bezierPathFromCoordinateString:obstacle00];
    UIBezierPath  *path01 = [Utils bezierPathFromCoordinateString:obstacle01];
    UIBezierPath  *path02 = [Utils bezierPathFromCoordinateString:obstacle02];
    UIBezierPath  *path03 = [Utils bezierPathFromCoordinateString:obstacle03];
    UIBezierPath  *path04 = [Utils bezierPathFromCoordinateString:obstacle04];
    UIBezierPath  *path05 = [Utils bezierPathFromCoordinateString:obstacle05];
    UIBezierPath  *path06 = [Utils bezierPathFromCoordinateString:obstacle06];
    
    if (CGPathContainsPoint(path00.CGPath,NULL,point,false))
    {
        return NO;
    }
    else if (CGPathContainsPoint(path01.CGPath,NULL,point,false))
    {
        return NO;
    }
    else if (CGPathContainsPoint(path02.CGPath,NULL,point,false))
    {
        return NO;
    }
    else if (CGPathContainsPoint(path03.CGPath,NULL,point,false))
    {
        return NO;
    }
    else if (CGPathContainsPoint(path04.CGPath,NULL,point,false))
    {
        return NO;
    }
    else if (CGPathContainsPoint(path05.CGPath,NULL,point,false))
    {
        return NO;
    }
    else if (CGPathContainsPoint(path06.CGPath,NULL,point,false))
    {
        return NO;
    }
    return YES;
}

- (bool)checkOpen:(int)col row:(int)row fid:(int)fid
{
    //检查open列表中是否有更小的步长，并排序
	for(int i = [open count] - 1;i > 0;i --)
    {
		if([(AStarItem *)[open objectAtIndex:i] id_col] == col && [(AStarItem *)[open objectAtIndex:i] id_row] == row){
		    int tempG = [self getG:col row:row fid:fid];
			if(tempG < [(AStarItem *)[open objectAtIndex:i] id_g])
            {
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

- (NSMutableArray *)findPath:(int)curX curY:(int)curY aimX:(int)aimX aimY:(int)aimY
{
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
    
    close = [[NSMutableArray alloc] init];
	
    //遍历寻找路径
	while([open count] > 1)
    {
        [self fromOpenToClose];//open和close列表管理
        int fatherid = [close count] - 1;
        
        if(abs(aimCol - [(AStarItem *)[close objectAtIndex:fatherid] id_col]) <= 10
		   && abs(aimRow - [(AStarItem *)[close objectAtIndex:fatherid] id_row]) <= 10)
        {
            [self getPath];
            break;
        }
        else
        {
            //搜索
            [self starSearch:fatherid];
        }
	}
    [open removeAllObjects];
    [close removeAllObjects];
    //获得路径
	if([path count] == 0)
    {
        return NULL;
	}
    else
    {
		if([(AStarItem *)[path lastObject] id_col] != aimCol || [(AStarItem *)[path lastObject] id_row] != aimRow){
            AStarItem * temp = [[AStarItem alloc] init];
            [temp setPos:aimCol row:aimRow];
            [path addObject:temp];
		}
		return path;
	}
}
@end
