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
        
        float minScale = self.frame.size.width / _mapView.frame.size.width;
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
    float newScale = self.zoomScale * 1.5;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gesture locationInView:gesture.view]];
    [self zoomToRect:zoomRect animated:YES];
    
    AStar *astar = [[AStar alloc] init];
    data = [astar findPath:1505 curY:911 aimX:1784 aimY:661];
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(2000, 1437), NO, 0);
    
//    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 50.0);
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

@end
