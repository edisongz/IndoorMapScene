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
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 10.0);
    UIBezierPath *p = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 2000, 1437)];
    
    [[UIColor blueColor] setStroke];
    BOOL isFirst = YES;
    if (data && [data count] > 0) {
        for (id obj in data) {
            if (isFirst) {
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
    
    UITouch *touch = [touches anyObject];
//    CGPoint point = [touch locationInView:self];
//    CGPoint point_ = [touch locationInView:_mapView];
    
    //    NSLog(@"point x = %f, point y = %f ", point.x, point.y);
    //    NSLog(@"point_ x = %f, point_ y = %f ", point_.x, point_.y);
}

- (void)performTouchTestArea:(NSValue *)inTouchPoint
{
    CGPoint     aTouchPoint     = [inTouchPoint CGPointValue];
    
    if ([testMapArea isAreaSelected:aTouchPoint])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"位置" message:@"百货商场" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
        [alert show];
    }
    //    for(MapArea *anArea in areaArray)
    //    {
    //        if([anArea isAreaSelected:aTouchPoint])
    //        {
    //            if(_delegate != nil
    //               && [_delegate conformsToProtocol:@protocol(MTImageMapDelegate)]
    //               && [_delegate
    //                   respondsToSelector:
    //                   @selector(imageMapView:didSelectMapArea:)])
    //            {
    //                [_delegate
    //                 imageMapView:self
    //                 didSelectMapArea:anArea.areaID];
    //            }
    //            break;
    //        }
    //    }
    
}


@end
