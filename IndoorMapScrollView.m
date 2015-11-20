//
//  IndoorMapScrollView.m
//  WisdomMallAPP
//
//  Created by apple on 13-12-17.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "IndoorMapScrollView.h"
#import "SVProgressHUD/SVProgressHUD.h"

#import "Constants.h"

#define kPop_width          150.0f
#define kPop_height         30.0f
#define kOffset_tag         100

@interface IndoorMapScrollView ()

@end

@implementation IndoorMapScrollView

#pragma mark - init
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor whiteColor]];
        self.delegate = self;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.clearsContextBeforeDrawing = YES;
        
        _mapViewNew = [[IndoorMapViewNew alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _mapViewNew.userInteractionEnabled = YES;
        _mapViewNew.delegate = self;
        [self addSubview:_mapViewNew];
        
        UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        [doubleTapGesture setNumberOfTapsRequired:2];
        [_mapViewNew addGestureRecognizer:doubleTapGesture];
        
        [self setMinimumZoomScale:1.f];
        [self setMaximumZoomScale:3.0f];
        [self setZoomScale:1.f];
        
        popover = [[MapPopView alloc] initWithFrame:CGRectMake(0, 0, kPop_width, kPop_height) showAtPoint:CGPointMake(0, 0) withTile:@"海雅缤纷城" subTitle:@"brief"];
        popover.hidden = YES;
        [self addSubview:popover];
        
        //iPhone 5
        _offset_y = OFFSET_Y;
        
    }
    return self;
}

/**
 *  寻找到我的位置最近的到目的地的 电梯（升降梯或扶手梯, 文件中带有P的）
 **/
- (void)findMinDistancePoint:(MyPositon *)position
{
    CGFloat min = FLT_MAX;
    if (pointsArray != nil && pointsArray.count > 0)
    {
        for (id obj in pointsArray)
        {
            if ([obj isKindOfClass:[FacilityPoints class]])
            {
                FacilityPoints *fPoints = obj;
                if (fPoints.isParking)//判断关键字中是否有parking标识
                {
                    CGFloat distance = (fPoints.point.x - position.point.x) * (fPoints.point.x - position.point.x) + (fPoints.point.y - position.point.y) * (fPoints.point.y - position.point.y);
                    if (distance < min)
                    {
                        min = distance;
                        minDistancePoint = fPoints;
                        _isFindingcar = YES;
                    }
                }
            }
        }
    }
}

- (FacilityPoints *)minFacilityPoint
{
    return minDistancePoint;
}

#pragma mark - draw something
/**
 *  画寻车指引
 **/
- (void)drawFindingCarPath
{
    if (_isFindingcar)//寻车状态下（不同floor）
    {
        if (_isStartMap)
        {
            [self drawPeople:_myPosition];
        }
        else
        {
            UIImage *image = [UIImage imageNamed:@"findcar_icon_car.png"];
            [self drawDestination:_endPositon image:image];
        }
    }
}

/**
 *  画人
 **/
- (void)drawPeople:(MyPositon *)position
{
    CGFloat scale = (self.zoomScale / self.minimumZoomScale);
    UIImage *image = [UIImage imageNamed:@"findcar_icon_person.png"];
    
    [[self viewWithTag:200] removeFromSuperview];
    UIImageView *personImageView = [[UIImageView alloc] initWithImage:image];
    personImageView.tag = 200;
    personImageView.center = CGPointMake((position.point.x - OFFSET_X) * RATIO * scale, (MAP_HEIGHT - position.point.y)* RATIO * scale + _offset_y * scale);
    [self addSubview:personImageView];
}

/**
 *  画目的地
 **/
- (void)drawDestination:(MyPositon *)position image:(UIImage *)image
{
    CGFloat scale = (self.zoomScale / self.minimumZoomScale);
    
    [[self viewWithTag:201] removeFromSuperview];
    UIImageView *desImageView = [[UIImageView alloc] initWithImage:image];
    desImageView.tag = 201;
    desImageView.center = CGPointMake((position.point.x - OFFSET_X) * RATIO * scale, (MAP_HEIGHT - position.point.y)* RATIO * scale + _offset_y * scale);
    [self addSubview:desImageView];
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _mapViewNew;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat scale = (self.zoomScale / self.minimumZoomScale);
    popover.center = CGPointMake(_touchPoint.x * scale, _touchPoint.y * scale - 20.0f);
    
    //控制设施图片的显示
    [self didDisplayPerson:scale];
    [self didDisplayDestination:scale];
    [self didDisplayPopoverView:_selectedPoint];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    [scrollView setZoomScale:scale animated:NO];
    [_mapViewNew setNeedsDisplay];
}

#pragma mark - control uiimage display
/**
 *  控制 人 图片的显示
 **/
- (void)didDisplayPerson:(float)scale
{
    UIImageView *imageView = (UIImageView *)[self viewWithTag:200];
    if (imageView)
    {
        imageView.center = CGPointMake((_myPosition.point.x - OFFSET_X) * RATIO * scale, (MAP_HEIGHT - _myPosition.point.y)* RATIO * scale + _offset_y * scale);
    }
}

/**
 *  控制 目的地 图片的显示
 **/
- (void)didDisplayDestination:(float)scale
{
    UIImageView *imageView = (UIImageView *)[self viewWithTag:201];
    if (imageView)
    {
        imageView.center = CGPointMake((_endPositon.point.x - OFFSET_X) * RATIO * scale, (MAP_HEIGHT - _endPositon.point.y)* RATIO * scale + _offset_y * scale);
    }
}

/**
 *  控制 地图弹出框 图片的显示, 找出多边形的准重心，让弹出框显示在上方
 **/
- (void)didDisplayPopoverView:(PrimitivePoints *)point
{
    if (_isSelectedPopover) {
        if (point.pointArray && point.pointArray.count > 0) {
            
            CGFloat minX = 320.0f;
            CGFloat minY = 480.0f;
            CGFloat maxX = 0.0f;
            CGFloat maxY = 0.0f;
            
            for (id obj in point.pointArray)
            {
                MPoint *mPoint = obj;
                
                CGFloat x = (mPoint.x - OFFSET_X) * RATIO;
                CGFloat y = (MAP_HEIGHT - mPoint.y) * RATIO + _offset_y;
                
                if (x < minX) {
                    minX = x;
                }
                if (y < minY) {
                    minY = y;
                }
                if (x > maxX) {
                    maxX = x;
                }
                if (y > maxY) {
                    maxY = y;
                }
            }
            
            //准重心
            CGPoint gravityPoint = CGPointMake((minX + maxX) * 0.5f, (minY + maxY) * 0.5f);
            CGFloat scale = (self.zoomScale / self.minimumZoomScale);
            
            popover.center = CGPointMake(gravityPoint.x * scale, gravityPoint.y * scale - 20.0f);
        }
    }
}

/**
 *  隐藏popover
 **/
- (void)hidePopover
{
    popover.hidden = YES;
}

/**
 *  显示popover
 **/
- (void)showPopover
{
    popover.hidden = NO;
}

#pragma mark - touch
- (void)touchPosition:(CGPoint)point content:(PrimitivePoints *)content
{
    _isSelectedPopover = NO;
    if (content == nil)
    {
        popover.hidden = YES;
        return;
    }
    if (point.x == 0 && point.y == 0)
    {
        popover.hidden = YES;
    }
    else
    {
        CGFloat scale = (self.zoomScale / self.minimumZoomScale);
        _touchPoint = point;
        
        popover.hidden = NO;
        [self bringSubviewToFront:popover];
        [popover setTitle:content.property.propertyName subTitle:content.property.parkingNo];
        popover.center = CGPointMake(point.x * scale, point.y * scale - 20.0f);
    }
}

#pragma mark - Zoom methods
- (void)handleDoubleTap:(UIGestureRecognizer *)gesture
{
    float newScale = self.zoomScale * 1.5;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gesture locationInView:gesture.view]];
    [self zoomToRect:zoomRect animated:YES];
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
{
    CGRect zoomRect;
    zoomRect.size.height = self.frame.size.height / scale;
    zoomRect.size.width  = self.frame.size.width  / scale;
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    return zoomRect;
}

- (void)zoomIn
{
    float newScale = self.zoomScale * 1.5;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:_mapViewNew.center];
    [self zoomToRect:zoomRect animated:YES];
}

- (void)zoomOut
{
    float newScale = self.zoomScale / 1.5f;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:_mapViewNew.center];
    [self zoomToRect:zoomRect animated:YES];
}

#pragma mark - popover delegate
- (void)onSelectMapView
{
    
}

#pragma mark - popup navi
/**
 *  弹出某个点的PopUpView
 */
- (void)popupOfPosition:(MyPositon *)position
{
//    CGFloat scale = (self.zoomScale / self.minimumZoomScale);
    //弹出pop，提示是缴费中心
    popover.hidden = NO;
    [self bringSubviewToFront:popover];
    [popover setTitle:@"起点" subTitle:@""];
    
    CGFloat x_ratio = 320 / 458.0f;
    CGFloat offset_y = OFFSET_Y;
    CGFloat h_ratio = 0.63;
    if (IS_IPHONE_5) {
        h_ratio = 0.52f;
        offset_y += 46.0f;
    }
    CGFloat y_ratio = MRScreenHeight / 404.f * h_ratio;
    popover.center = CGPointMake(position.point.x * x_ratio, position.point.y * y_ratio + offset_y);
    
    _touchPoint = position.point;
}

/**
 *  设置弹出pop的文字内容
 */
- (void)setPopupTitleText:(NSString *)title subText:(NSString *)subStr
{
    [popover setTitle:title subTitle:subStr];
}

- (void)findShortestPath:(CGPoint)start
                     end:(CGPoint)end
                filePath:(NSString *)filePath
{
    NSMutableArray *paths = [[NSMutableArray alloc] init];
    
    NSMutableArray *path1 = [_mapViewNew findPathStartX:start.x
                                                  statY:start.y
                                                   endX:end.x
                                                   endY:end.y
                                               filePath:filePath];
    [paths addObjectsFromArray:path1];
    
    [_mapViewNew drawPaths:paths];
}

@end
