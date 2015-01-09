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
    int sIndex;
    int _facilityType;
    
    NSMutableArray *pointsArray;
    NSMutableArray *facilitiesArray;

    //ios7
    CGFloat _offset_y;
    
    BOOL _isFindingcar;//寻车
    BOOL _isStartMap;//
    BOOL _isSameFloor;
    MyPositon *_myPosition;
    MyPositon *_endPositon;
    
    //最短距离的电梯口（能通往车库的）
    FacilityPoints *minDistancePoint;
    
    //animation
    UIImageView *_pImageView;
    
    PrimitivePoints *_selectedPoint;
    BOOL _isSelectedPopover;
}

@property (assign, nonatomic) BOOL animationFinished;
@property (strong, nonatomic) IndoorMapViewNew *mapViewNew;
@property (assign, nonatomic) int facilityType;
@property (strong, nonatomic) MyPositon *paymentPostion;

- (void)zoomIn;
- (void)zoomOut;
- (void)reDrawFacilities:(int)type;

- (void)showPopover;
- (void)hidePopover;
- (FacilityPoints *)minFacilityPoint;

#pragma mark - load v2.0
- (void)loadMapInfoFile:(NSString *)path shop:(Shop *)shop;
- (void)loadMapViewByPos:(MyPositon *)position
                 isStart:(BOOL)isStart;

- (void)loadMapViewByStartPos:(MyPositon *)startPos
                       endPos:(MyPositon *)endPos
                      isStart:(BOOL)isStart;

- (void)loadMapForSameFloor:(MyPositon *)startPos
                     endPos:(MyPositon *)endPos;

- (void)loadMapViewByFloor:(NSString *)floorNo
             paymentCenter:(MyPositon *)pPosition;

- (void)loadMapForSameFloorWithElevator:(MyPositon *)startPos
                                 endPos:(MyPositon *)endPos
                          paymentCenter:(MyPositon *)pPosition;

#pragma mark - load v2.1
- (void)loadMapViewByPos:(MyPositon *)position
           paymentCenter:(MyPositon *)pPosition
                 isStart:(BOOL)isStart;

- (void)loadMapViewByStartPos:(MyPositon *)startPos
                       endPos:(MyPositon *)endPos
                paymentCenter:(MyPositon *)pPosition
                      isStart:(BOOL)isStart;

/**
 *  寻找到我的位置最近的到目的地的 电梯（升降梯或扶手梯, 文件中带有P的）
 **/
- (void)findMinDistancePoint:(MyPositon *)position;

- (void)doPathAnimation;
- (void)doDestinationAnimation:(AnimationCompletion)completionHandler;
- (void)doSameFloorAnimation:(AnimationCompletion)completionHandler;

- (void)drawFacility:(FacilityPoints *)facility tag:(int)tag;
- (void)drawPaymentCenter:(MyPositon *)position image:(UIImage *)image;

- (void)popupOfPosition:(MyPositon *)position;
- (void)setPopupTitleText:(NSString *)title subText:(NSString *)subStr;

- (void)findPathTest:(NSString *)filePath;

/**
 *  两点之间最短距离
 */
- (void)findShortestPath:(CGPoint)start
                     end:(CGPoint)end
                filePath:(NSString *)filePath;

/**
 *  人，车，缴费中心同一层，获取路径
 */
- (void)findPathSameFloor:(CGPoint)start
                  payment:(CGPoint)payment
                      end:(CGPoint)end
                 filePath:(NSString *)filePath;

/**
 *  普通两或三点之间寻路径
 *
 *  @param from 起点
 *  @param to   终点
 *  @param path 路径
 */
- (void)findPathFrom:(CGPoint)from
                  to:(CGPoint)to
               extra:(CGPoint)ePoint
            filePath:(NSString *)path;

@end
