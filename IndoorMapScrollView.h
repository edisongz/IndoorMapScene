//
//  IndoorMapScrollView.h
//  WisdomMallAPP
//
//  Created by apple on 13-12-17.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IndoorMapViewNew.h"
#import "MapPopView.h"

#import "MyPositon.h"
#import "Shop.h"
#import "PrimitivePoints.h"

typedef void(^AnimationCompletion)();

@interface IndoorMapScrollView : UIScrollView <UIScrollViewDelegate, IndoorMapViewNewDelegate>
{
    MapPopView *popover;
    CGPoint _touchPoint;
    
    NSMutableArray *pointsArray;
    NSMutableArray *facilitiesArray;

    //ios7
    CGFloat _offset_y;
    
    BOOL _isFindingcar;//寻车
    BOOL _isStartMap;//
    MyPositon *_myPosition;
    MyPositon *_endPositon;
    
    //最短距离的电梯口（能通往车库的）
    FacilityPoints *minDistancePoint;
    
    PrimitivePoints *_selectedPoint;
    BOOL _isSelectedPopover;
}

@property (strong, nonatomic) IndoorMapViewNew *mapViewNew;

- (void)zoomIn;
- (void)zoomOut;

- (void)showPopover;
- (void)hidePopover;
- (FacilityPoints *)minFacilityPoint;

/**
 *  寻找到我的位置最近的到目的地的 电梯（升降梯或扶手梯, 文件中带有P的）
 **/
- (void)findMinDistancePoint:(MyPositon *)position;

- (void)popupOfPosition:(MyPositon *)position;
- (void)setPopupTitleText:(NSString *)title subText:(NSString *)subStr;

/**
 *  两点之间最短距离
 */
- (void)findShortestPath:(CGPoint)start
                     end:(CGPoint)end
                filePath:(NSString *)filePath;

@end
