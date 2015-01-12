//
//  IndoorMapViewNew.m
//  WisdomMallAPP
//
//  Created by apple on 14-1-13.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "IndoorMapViewNew.h"

#import "IndoorMapPath.h"
#import "IndoorMapPathView.h"
#import "AStar.h"
#import "AStarItem.h"
#import "ItemRelation.h"

#import "Constants.h"
#import "NSFileHandle+readLine.h"

#define IMAGE_SIZE      15.0f

@interface IndoorMapViewNew ()
{
    //路径搜索
    AStar *astar;
    
    //画路径
    NSMutableArray *newPath;
    IndoorMapPathView *pathView;
}

@end

@implementation IndoorMapViewNew

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = RGBA(235.0f, 235.0f, 226.0f, 1);
        
        UIImage *floorImage = [UIImage imageNamed:@"map1.png"];
        _mapView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _mapView.image = floorImage;
        _mapView.center = CGPointMake(frame.size.width * 0.5f, frame.size.height * 0.5f);
        _mapView.contentMode = UIViewContentModeScaleAspectFit;
        _mapView.userInteractionEnabled = YES;
        
        [self addSubview:_mapView];
        
        pathView = [[IndoorMapPathView alloc] initWithFrame:frame];
        [self addSubview:pathView];
        
        self.clearsContextBeforeDrawing = YES;
        
        pathArray = [[NSMutableArray alloc] init];
        
        sIndex = -1;
        _previousScale = 1;
        _animationFinished = YES;
        
        _offset_y = OFFSET_Y;
        
        //astar algorithm
        astar = [[AStar alloc] init];
        
    }
    return self;
}

- (void)setMapImage:(UIImage *)image
{
    _mapView.image = image;
}

#pragma mark - draw
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    if (pathArray != nil) {
        [pathArray removeAllObjects];
    }
    CGContextRef context = UIGraphicsGetCurrentContext();
    //抗锯齿
    CGContextSetAllowsAntialiasing(context, TRUE);
    CGContextSetShouldAntialias(context, true);
    
    int i = 0;
    
    for (id obj in _pointsArray) {
        
        if ([obj isKindOfClass:[PrimitivePoints class]])//商铺
        {
            PrimitivePoints *point = obj;
            
            if ([point.type isEqualToString:@"PLINE"])
            {
                //读取点集合
                NSMutableArray *regionPoints = point.pointArray;
                for (int i = 0; i < regionPoints.count; i++) {
                    MPoint *point = [regionPoints objectAtIndex:i];
                    
                    if (i == 0)
                    {
                        CGContextMoveToPoint(context, (point.x  - OFFSET_X) * RATIO, (MAP_HEIGHT - point.y) * RATIO + _offset_y);  // 开始坐标右边开始
                        continue;
                    }
                    
                    CGContextAddLineToPoint(context, (point.x - OFFSET_X) * RATIO, (MAP_HEIGHT - point.y) * RATIO + _offset_y);
                }
                
                //区分不同情况
                if (point.hasProperty)
                {
                    
                    if ([point.property.propertyNo intValue] == 20)//车位
                    {
                        //构建区域，用于点击操作
                        IndoorMapPath *mapPath = [[IndoorMapPath alloc] initWithPrimitives:regionPoints areaLocation:@""];
                        
                        //区域path, 同时也是障碍物path
                        [pathArray addObject:mapPath];
                        
                        CGContextSetLineWidth(context, 0.0f);
                        if (sIndex == i)
                        {
                            CGContextSetFillColorWithColor(context, COLOR_MAP_MAIN.CGColor);
                        }
                        else
                        {
                            CGContextSetFillColorWithColor(context, COLOR_MAP_PARKING.CGColor);
                        }
                        
                        CGContextClosePath(context);
                        CGContextDrawPath(context, kCGPathFillStroke); //根据坐标绘制路径
                        i++;
                    }
                    else if ([point.property.propertyNo intValue] == 22)//建筑
                    {
                        [pathArray addObject:[NSNull null]];
                        CGContextSetLineWidth(context, 0.0f);
                        //                        CGContextSetStrokeColorWithColor(context, COLOR_MAP_FRAME.CGColor);//线框颜色
                        CGContextSetFillColorWithColor(context, COLOR_MAP_BUILDING.CGColor);
                        CGContextClosePath(context);
                        CGContextDrawPath(context, kCGPathFillStroke); //根据坐标绘制路径
                    }
                    else if ([point.property.propertyNo intValue] == 40)//外框
                    {
                        [pathArray addObject:[NSNull null]];
                        CGContextSetLineWidth(context, 10.0f);
                        CGContextSetStrokeColorWithColor(context, COLOR_MAP_FRAME.CGColor);//线框颜色
                        CGContextClosePath(context);
                        CGContextDrawPath(context, kCGPathStroke); //根据坐标绘制路径
                    }
                    else
                    {
                        //构建区域，用于点击操作
                        IndoorMapPath *mapPath = [[IndoorMapPath alloc] initWithPrimitives:regionPoints areaLocation:@""];
                        
                        //区域path, 同时也是障碍物path
                        [pathArray addObject:mapPath];
                        
                        CGContextSetLineWidth(context, 0.0f);
                        CGContextSetFillColorWithColor(context, COLOR_MAP_BUILDING.CGColor);
                        CGContextClosePath(context);
                        CGContextDrawPath(context, kCGPathFillStroke);
                        i++;
                    }
                    
                }
                else
                {
                    //构建区域，用于点击操作
                    IndoorMapPath *mapPath = [[IndoorMapPath alloc] initWithPrimitives:regionPoints areaLocation:@""];
                    
                    //区域path, 同时也是障碍物path
                    [pathArray addObject:mapPath];
                    
                    CGContextSetLineWidth(context, 0.0f);
                    if (sIndex == i) {
                        CGContextSetFillColorWithColor(context, COLOR_MAP_FASHION.CGColor);
                    }else{
                        CGContextSetFillColorWithColor(context, COLOR_MAP_MAIN.CGColor);
                    }
                    //            CGContextSetStrokeColorWithColor(context, [UIColor yellowColor].CGColor);//线框颜色
                    CGContextClosePath(context);
                    CGContextDrawPath(context, kCGPathFillStroke); //根据坐标绘制路径
                    i++;
                }
                
            }
        }
        else if ([obj isKindOfClass:[FacilityPoints class]])//设施图标
        {
//            return;
//            if (isFindingcar) {
//                continue;
//            }
//            if (isSameFloor) {
//                continue;
//            }
        }
        
    }
    
}

#pragma mark - UITouch
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // cancel previous touch ended event
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
	CGPoint touchPoint  = [[touches anyObject] locationInView:self];
    NSValue *touchValue = [NSValue valueWithCGPoint:touchPoint];
    
    // perform new one
    [self performSelector:@selector(performTouchTestArea:)
               withObject:touchValue
               afterDelay:0.1];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"touch_ended" object:nil];
    
}

- (void)performTouchTestArea:(NSValue *)inTouchPoint
{
    CGPoint aTouchPoint = [inTouchPoint CGPointValue];
    
    BOOL isInArea = NO;
    if (pathArray != nil) {
        int i = 0;
        for (id obj in pathArray) {
            IndoorMapPath *path = obj;
            if (![obj isEqual:[NSNull null]] && [path isAreaSelected:aTouchPoint]) {
                sIndex = i;
                [self setNeedsDisplay];
                
                PrimitivePoints *content = [_pointsArray objectAtIndex:i];
                [_delegate touchPosition:CGPointMake(aTouchPoint.x, aTouchPoint.y) content:content];
                isInArea = YES;
            }
            i++;
        }
        
        if (!isInArea) {
            [_delegate touchPosition:CGPointMake(0, 0) content:nil];
        }
    }
}

#pragma mark - get path Point
/**
 *  获取路径点集合
 */
- (NSMutableArray *)fetchPathPoint:(NSString *)filePath
{
    NSMutableArray *results = [[NSMutableArray alloc] init];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"map1_path_data" ofType:@"txt"];
    
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
    
    NSData *lineData;
    
    while ((lineData = [fileHandle readLineWithDelimiter:@"\n"]))
    {
        NSString *lineString = [[NSString alloc] initWithData:lineData encoding:NSUTF8StringEncoding];
        
        //#号为注释
        if ([lineString characterAtIndex:0] == '#')
        {
            continue;
        }
        NSString *replaceStr = [lineString stringByReplacingOccurrencesOfString:@"(" withString:@"{"];
        NSString *replaceStr1 = [replaceStr stringByReplacingOccurrencesOfString:@")" withString:@"}"];
        
        //转换坐标系，跟障碍物区域
        CGPoint point = CGPointFromString(replaceStr1);
        point.x = point.x;
        point.y = (760 - point.y);
        
        point.x = (point.x / 100.0f  - OFFSET_X) * RATIO;
        point.y = (MAP_HEIGHT - point.y / 100.0f) * RATIO + _offset_y;
        
        AStarItem *item = [[AStarItem alloc] init];
        [item setPos:point.x row:point.y];
        [results addObject:item];
    }
    return results;
}

/**
 *  获取线段集合
 *
 *  @param filePath 路径
 *
 *  @return 线段集合
 */
- (NSMutableArray *)fetchPathPairPoint:(NSString *)filePath
{
    NSMutableArray *results = [[NSMutableArray alloc] init];
    NSString *path = [[NSBundle mainBundle] pathForResource:filePath ofType:@"txt"];
    
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
    
    NSData *lineData;
    
    NSMutableArray *points = [[NSMutableArray alloc] init];
    while ((lineData = [fileHandle readLineWithDelimiter:@"\n"]))
    {
        NSString *lineString = [[NSString alloc] initWithData:lineData encoding:NSUTF8StringEncoding];
        
        //#号为注释
        if ([lineString characterAtIndex:0] == '#')
        {
            continue;
        }
        NSString *replaceStr = [lineString stringByReplacingOccurrencesOfString:@"(" withString:@"{"];
        NSString *replaceStr1 = [replaceStr stringByReplacingOccurrencesOfString:@")" withString:@"}"];
        
        NSArray *array = [replaceStr1 componentsSeparatedByString:@"-"];
        if (array) {
            
            ItemRelation *relation = [[ItemRelation alloc] init];
            
            for (int i = 0; i < array.count; i++) {
                
                NSString *pointStr = [array objectAtIndex:i];
                pointStr = [pointStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                pointStr = [pointStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
                
                if (![points containsObject:pointStr])
                {
                    [points addObject:pointStr];
                }
                
                CGPoint point = CGPointFromString(pointStr);
                
                //转换坐标系
//                point.y = 760 - point.y;
//                
//                point.x = (point.x / 100.0f  - OFFSET_X) * RATIO;
//                point.y = (MAP_HEIGHT - point.y / 100.0f) * RATIO + _offset_y;
                
                if (i == 0)
                {
                    relation.point1.col = point.x;
                    relation.point1.row = point.y;
                }
                else
                {
                    relation.point2.col = point.x;
                    relation.point2.row = point.y;
                }
                
                
            }
            //关系点集合
            [astar.relationArray addObject:relation];
        }
        
    }
    
    for (NSString *pointStr in points) {
        
        AStarItem *item = [[AStarItem alloc] init];
        
        
        CGPoint point = CGPointFromString(pointStr);
        
        //转换坐标系
//        point.y = 760 - point.y;
//        
//        point.x = (point.x / 100.0f  - OFFSET_X) * RATIO;
//        point.y = (MAP_HEIGHT - point.y / 100.0f) * RATIO + _offset_y;
        
        [item setPos:point.x row:point.y];
        
        //结点集合
        [results addObject:item];
    }
    return results;
}

/**
 *  画商场地图路径
 */
- (NSMutableArray *)findPathStartX:(CGFloat)startX
                             statY:(CGFloat)startY
                              endX:(CGFloat)endX
                              endY:(CGFloat)endY
                          filePath:(NSString *)filePath
{

    NSMutableArray *points = [self fetchPathPairPoint:filePath];
    astar.allPointsArray = [points mutableCopy];
    
    NSMutableArray *pathsArray = [[NSMutableArray alloc] init];
    
    //转换成与路径点相同的坐标系
    CGFloat x_start = startX;
    CGFloat y_start = startY;
    CGFloat x_end = endX;
    CGFloat y_end = endY;
    
    //图片大小458*404
    //转化成可绘制坐标
//    CGFloat x_ratio = 320 / 458.0f;
//    CGFloat y_ratio = _mapView.frame.size.height / 404.f;
//    x_start = x_start * x_ratio;
//    y_start = y_start * y_ratio;// + _offset_y;
//    x_end = x_end * x_ratio;
//    y_end = y_end * y_ratio;// + _offset_y;
    
//    NSLog(@"start----->(%f, %f)", x_start, y_start);
    
    AStarItem *item_start_nearest = [astar findNearestPoint:x_start row:y_start];
    
    AStarItem *item_end_nearest = [astar findNearestPoint:x_end row:y_end];

    newPath = [astar findPath:item_start_nearest.id_col
                         curY:item_start_nearest.id_row
                         aimX:item_end_nearest.id_col
                         aimY:item_end_nearest.id_row
                     withPath:nil];
    
    //添加起点，终点两头
    AStarItem *itemStart = [[AStarItem alloc] init];
    itemStart.id_col = x_start;
    itemStart.id_row = y_start;
    
    AStarItem *itemEnd = [[AStarItem alloc] init];
    itemEnd.id_col = x_end;
    itemEnd.id_row = y_end;
    [newPath insertObject:itemStart atIndex:0];
    [newPath addObject:itemEnd];
    
    pathsArray = [newPath mutableCopy];
    return pathsArray;
    
}

- (void)drawPaths:(NSMutableArray *)path
{
    //绘制路线
    [pathView drawPathWithPoints:path];
}

@end
