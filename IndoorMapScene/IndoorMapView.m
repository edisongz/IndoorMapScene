//
//  IndoorMapView.m
//  IndoorMapScene
//
//  Created by apple on 13-10-29.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "IndoorMapView.h"
#import "MapArea.h"

#import "AStarItem.h"
#import "AStar.h"

#import "Utils.h"
#import <QuartzCore/QuartzCore.h>
#import "CATransform3DPerspect.h"

#import "UIImageView+Effects.h"

#define SIZE_RATIO         4.0f
#define MRScreenWidth      CGRectGetWidth([UIScreen mainScreen].applicationFrame)
#define MRScreenHeight     CGRectGetHeight([UIScreen mainScreen].applicationFrame)

@implementation IndoorMapView
{
    MapArea *testMapArea;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.delegate = self;
        [self setBackgroundColor:[UIColor whiteColor]];
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.frame = CGRectMake(0, 0, MRScreenWidth, MRScreenHeight);
        
        UIImage *map = [UIImage imageNamed:@"floor1.jpg"];
        UIImage *tag = [UIImage imageNamed:@"tag.png"];
        
        //地图图片
        _mapView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, map.size.width, map.size.height)];
        
        _mapView.contentMode = UIViewContentModeScaleAspectFit;
        _mapView.image = map;
        _mapView.userInteractionEnabled = YES;
        
        _tagImageView = [[UIImageView alloc] init];
        _tagImageView.contentMode = UIViewContentModeScaleAspectFit;
        _tagImageView.image = tag;
        
        [self addSubview:_mapView];
        [_mapView addSubview:_tagImageView];
        
        UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        [doubleTapGesture setNumberOfTapsRequired:2];
        [_mapView addGestureRecognizer:doubleTapGesture];
        
        minScale = self.frame.size.width / _mapView.frame.size.width;
        [self setMinimumZoomScale:minScale];
        [self setZoomScale:minScale];
        
        [_tagImageView setFrame:CGRectMake(190 * SIZE_RATIO, 225 * SIZE_RATIO, tag.size.width, tag.size.height)];
        
        testMapArea = [[MapArea alloc] initWithCoordinate:@"" areaID:1];
        
        _pathImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 2000, 1437)];
        [_mapView addSubview:_pathImageView];
        
        _startImageView = [[UIImageView alloc] initWithFrame:CGRectMake(1505 - tag.size.width/2, 911 - tag.size.height, tag.size.width, tag.size.height)];
        _endImageView = [[UIImageView alloc] initWithFrame:CGRectMake(1784 - tag.size.width/2, 661 - tag.size.height, tag.size.width, tag.size.height)];
        _startImageView.image = tag;
        _endImageView.image = tag;
        
        [_mapView addSubview:_startImageView];
        [_mapView addSubview:_endImageView];
        
        //测试3d效果按钮，还未完成（可屏蔽此段）
        UIButton *btTest3d = [[UIButton alloc] initWithFrame:CGRectMake(20, 420, 49, 30)];
        [btTest3d setTitle:@"测试3d" forState:UIControlStateNormal];
        [btTest3d addTarget:self action:@selector(on3DSettingClick) forControlEvents:UIControlEventTouchUpInside];
        [btTest3d setBackgroundColor:[UIColor orangeColor]];
        [self addSubview:btTest3d];
        
        is3DSettingRunning = NO;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    UIImage *tag = [UIImage imageNamed:@"tag.png"];
    [_tagImageView setFrame:CGRectMake(190 * SIZE_RATIO - (tag.size.width / (self.zoomScale*2)), 225 * SIZE_RATIO - (tag.size.width / (self.zoomScale)), tag.size.width / self.zoomScale, tag.size.height / self.zoomScale)];
    
    //起点，终点两个tag图标
    [_startImageView setFrame:CGRectMake(1505 - (tag.size.width / (self.zoomScale*2)), 911 - (tag.size.width / (self.zoomScale)), tag.size.width / self.zoomScale, tag.size.height / self.zoomScale)];
    [_endImageView setFrame:CGRectMake(1784 - (tag.size.width / (self.zoomScale*2)), 661 - (tag.size.width / (self.zoomScale)), tag.size.width / self.zoomScale, tag.size.height / self.zoomScale)];
    
    _pathImageView.image = pathImg;
}

#pragma mark - Zoom methods
- (void)handleDoubleTap:(UIGestureRecognizer *)gesture
{
    _pathImageView.image = nil;
    
    if (is3DSettingRunning) {
        [self recoveryNormalModeFrom3D];
        is3DSettingRunning = NO;
    }
    
    float newScale = self.zoomScale * 1.5;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gesture locationInView:gesture.view]];
    [self zoomToRect:zoomRect animated:YES];
    
    AStar *astar = [[AStar alloc] init];
    data = [astar findPath:1505 curY:911 aimX:1784 aimY:661];
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(2000, 1437), NO, 0);
    
    UIBezierPath *p = [UIBezierPath new];
    [[UIColor blueColor] setStroke];
    [p setLineWidth:8.0f];
    [p setLineJoinStyle:kCGLineJoinRound];
    [p setLineCapStyle:kCGLineCapRound];
    BOOL isFirst = YES;
    if (data && [data count] > 0)
    {
        for (id obj in data)
        {
            if (isFirst)
            {
                isFirst = NO;
                [p moveToPoint:CGPointMake([obj id_col], [obj id_row])];
            }
            
            [p addLineToPoint:CGPointMake([obj id_col], [obj id_row])];
        }
    }
    [p stroke];
    pathImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self setNeedsDisplay];
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

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    [self setNeedsDisplay];
    return _mapView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    [scrollView setZoomScale:scale animated:NO];
    [self setNeedsDisplay];
}

#pragma mark - UITouch
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // cancel previous touch ended event
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
	CGPoint touchPoint  = [[touches anyObject] locationInView:_mapView];
    NSValue *touchValue = [NSValue valueWithCGPoint:touchPoint];
    
    // perform new one
    [self performSelector:@selector(performTouchTestArea:)
               withObject:touchValue
               afterDelay:0.1];
    
    [self performSelector:@selector(performTouchTag:) withObject:touchValue afterDelay:0.1];
}

- (void)performTouchTestArea:(NSValue *)inTouchPoint
{
    CGPoint aTouchPoint = [inTouchPoint CGPointValue];
    
    if ([testMapArea isAreaSelected:aTouchPoint])
    {
        [PopoverView showPopoverAtPoint:aTouchPoint inView:_mapView withText:@"百货商场" delegate:self];
    }
}

- (void)performTouchTag:(NSValue *)touchPoint
{
    CGPoint aTouchPoint = [touchPoint CGPointValue];
    
    UIImage *tag = [UIImage imageNamed:@"tag.png"];
    
    CGRect tagRect = CGRectMake(1505 - (tag.size.width / (self.zoomScale*2)), 911 - (tag.size.width / (self.zoomScale)), tag.size.width / self.zoomScale, tag.size.height / self.zoomScale);
    NSString *strTagPath = [Utils pathStringWithFrame:tagRect];
    
    UIBezierPath *tagPath = [Utils bezierPathFromCoordinateString:strTagPath];
    if (CGPathContainsPoint(tagPath.CGPath,NULL,aTouchPoint,false))
    {
        [PopoverView showPopoverAtPoint:[Utils gravityPointInRect:tagRect] inView:_mapView withText:@"起点" delegate:self];
    }
}

#pragma mark - 3d setting
- (void)on3DSettingClick
{
    CATransform3D rotate = CATransform3DMakeRotation(M_PI/6, 1, 0, 0);
    _mapView.layer.transform = CATransform3DPerspect(rotate, CGPointMake(0, 0), 150);
    [_mapView setFrame:CGRectMake(0, 0, 320, 230)];
    
    //设置此时标签的显示位置
    UIImage *map = [UIImage imageNamed:@"floor1.jpg"];
    UIImage *tag = [UIImage imageNamed:@"tag.png"];
    CGFloat currentScale = map.size.width / MRScreenWidth;
    [_tagImageView setFrame:CGRectMake(190 * SIZE_RATIO / currentScale - tag.size.width * 0.5, 225 * SIZE_RATIO/ currentScale - tag.size.height, tag.size.width, tag.size.height)];
    [_startImageView setFrame:CGRectMake(1505 / currentScale - tag.size.width/2, 911 / currentScale - tag.size.height, tag.size.width, tag.size.height)];
    [_endImageView setFrame:CGRectMake(1784 / currentScale - tag.size.width/2, 661 / currentScale- tag.size.height, tag.size.width, tag.size.height)];
    
    is3DSettingRunning = YES;
}

//从3d复原成普通模式
- (void)recoveryNormalModeFrom3D
{
    _mapView.layer.transform = CATransform3DIdentity;
    
    UIImage *map = [UIImage imageNamed:@"floor1.jpg"];
    UIImage *tag = [UIImage imageNamed:@"tag.png"];
    [_mapView setFrame:CGRectMake(0, 0, map.size.width, map.size.height)];
    [_tagImageView setFrame:CGRectMake(190 * SIZE_RATIO, 225 * SIZE_RATIO, tag.size.width, tag.size.height)];
    
    [_startImageView setFrame:CGRectMake(1505 - tag.size.width/2, 911 - tag.size.height, tag.size.width, tag.size.height)];
    [_endImageView setFrame:CGRectMake(1784 - tag.size.width/2, 661 - tag.size.height, tag.size.width, tag.size.height)];
    
    [self setZoomScale:minScale];
}

@end
