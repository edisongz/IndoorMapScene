//
//  IndoorMapViewNew.h
//  WisdomMallAPP
//
//  Created by apple on 14-1-13.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MyPositon.h"
#import "FacilityPoints.h"
#import "PrimitivePoints.h"

@protocol IndoorMapViewNewDelegate <NSObject>

@optional
- (void)touchPosition:(CGPoint)point content:(PrimitivePoints *)content;

@end

@interface IndoorMapViewNew : UIView
{
    NSMutableArray *facilitiesArray;
    
    NSMutableArray *pathArray;
    
    int sIndex;
    
    //for find path
//    BOOL isFindingcar;//寻车
//    BOOL isStartMap;//
//    BOOL isSameFloor;
    
    //
    MyPositon *myPosition;
    MyPositon *endPositon;
    
    //最短距离的电梯口（能通往车库的）
    FacilityPoints *minDistancePoint;
    
    //animation
    UIImageView *_personImageView;
    
    BOOL _isShowing;
    
    //ios7
    CGFloat _offset_y;
}

@property (weak, nonatomic) id<IndoorMapViewNewDelegate> delegate;
@property (strong, nonatomic) NSMutableArray *pointsArray;

@property (assign, nonatomic) float previousScale;
@property (assign, nonatomic) BOOL animationFinished;
@property (assign, nonatomic) int facilityType;

@property (strong, nonatomic) UIImageView *mapView;

- (void)setMapImage:(UIImage *)image;

/**
 *  画商场地图路径
 */
- (NSMutableArray *)findPathStartX:(CGFloat)startX
                             statY:(CGFloat)startY
                              endX:(CGFloat)endX
                              endY:(CGFloat)endY
                          filePath:(NSString *)filePath;

/**
 *  画线
 */
- (void)drawPaths:(NSMutableArray *)path;

@end
