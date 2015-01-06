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
        
        _mapViewNew = [[IndoorMapViewNew alloc] initWithFrame:CGRectMake(0, 0, 1.0f*frame.size.width, frame.size.height * 1.0f)];
        _mapViewNew.userInteractionEnabled = YES;
        _mapViewNew.delegate = self;
        [self addSubview:_mapViewNew];
        
//        //寻车路线View
//        [_mapViewNew findPath];
        
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
        
        _animationFinished = YES;
    }
    return self;
}

#pragma mark - load map data
- (void)loadMapInfoFile:(NSString *)path shop:(Shop *)shop
{
    if (shop == nil)
    {
        _isSelectedPopover = NO;
    }
    else
    {
        _isSelectedPopover = YES;
    }
    [SVProgressHUD showWithStatus:@"正在加载地图数据"];
    sIndex = -1;
    
    if (pointsArray != nil && pointsArray.count > 0) {
        [pointsArray removeAllObjects];
    }
    
    if (facilitiesArray == nil) {
        facilitiesArray = [[NSMutableArray alloc] init];
    }
    
    //如果facilitiesArray不为空，清除以前残留的uiimageview
    for (int i = 0; i < facilitiesArray.count; i++)
    {
        UIImageView *imageView = (UIImageView *)[self viewWithTag:(kOffset_tag + i)];
        [imageView removeFromSuperview];
    }
    [facilitiesArray removeAllObjects];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        MifFileReader *mifReader = [[MifFileReader alloc] init];
        pointsArray = [mifReader readMifDataNewVersion:path];
        
        for (id obj in pointsArray)
        {
            
            /**
             *  控制 弹出框 图片的显示，主要用于从商户界面跳转进来时，自行定位
             **/
            if ([obj isKindOfClass:[PrimitivePoints class]] &&
                ![shop.shopAddressNo isEqualToString:@""])
            {
                PrimitivePoints *point = obj;
                if ([point.type isEqualToString:@"PLINE"])
                {
                    NSString *parkingNo = [point.property.parkingNo stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    NSString *shopAddressNo = [shop.shopAddressNo stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    if ([parkingNo isEqualToString:shopAddressNo])
                    {
                        _selectedPoint = point;
                        break;
                    }
                }
            }
            
            //设施图标
            if ([obj isKindOfClass:[FacilityPoints class]])
            {
                FacilityPoints *facility = obj;
                [facilitiesArray addObject:facility];
            }
            
        }
        
        //刷新界面
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [_mapViewNew setPointsArray:pointsArray];
            [_mapViewNew setNeedsDisplay];
            
            for (int i = 0; i < facilitiesArray.count; i++) {
                FacilityPoints *point = [facilitiesArray objectAtIndex:i];
                [self drawFacility:point tag:(kOffset_tag + i)];
            }
            
            //弹出popover
            if (shop != nil) {
                [popover setTitle:shop.shopName subTitle:shop.shopAddressNo];
                [self didDisplayPopoverView:_selectedPoint];
                popover.hidden = NO;
                [self bringSubviewToFront:popover];
            }
            
            [SVProgressHUD dismissWithSuccess:@"加载完毕"];
            
        });
    });
}

- (void)loadMapViewByPos:(MyPositon *)position
                 isStart:(BOOL)isStart
{
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *path = [mainBundle pathForResource:position.floorNo ofType:@"mif"];
    [self loadMapInfoFile:path position:position isStart:isStart];
}

- (void)loadMapViewByStartPos:(MyPositon *)startPos
                       endPos:(MyPositon *)endPos
                      isStart:(BOOL)isStart
{
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *path = [mainBundle pathForResource:endPos.floorNo ofType:@"mif"];
    [self loadMapInfoFile:path startPos:startPos endPos:endPos isStart:isStart];
}

- (void)loadMapForSameFloor:(MyPositon *)startPos
                     endPos:(MyPositon *)endPos
{
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *path = [mainBundle pathForResource:endPos.floorNo ofType:@"mif"];
    [self loadMapInfoForSameFloor:path startPos:startPos endPos:endPos];
}

#pragma mark - load 2.1
- (void)loadMapViewByPos:(MyPositon *)position
           paymentCenter:(MyPositon *)pPosition
                 isStart:(BOOL)isStart
{
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *path = [mainBundle pathForResource:position.floorNo ofType:@"mif"];
    [self loadMapInfoFile:path position:position paymentCenter:pPosition isStart:isStart];
}

- (void)loadMapViewByStartPos:(MyPositon *)startPos
                       endPos:(MyPositon *)endPos
                paymentCenter:(MyPositon *)pPosition
                      isStart:(BOOL)isStart
{
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *path = [mainBundle pathForResource:endPos.floorNo ofType:@"mif"];
    [self loadMapInfoFile:path startPos:startPos endPos:endPos paymentCenter:pPosition isStart:isStart];
}

- (void)loadMapViewByFloor:(NSString *)floorNo
                paymentCenter:(MyPositon *)pPosition
{
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *path = [mainBundle pathForResource:floorNo ofType:@"mif"];
    [self loadMapInfoFile:path paymentCenter:pPosition];
//    [self loadMapInfoFile:path startPos:startPos endPos:endPos paymentCenter:pPosition isStart:isStart];
}

- (void)loadMapForSameFloorWithElevator:(MyPositon *)startPos
                                 endPos:(MyPositon *)endPos
                          paymentCenter:(MyPositon *)pPosition
{
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *path = [mainBundle pathForResource:endPos.floorNo ofType:@"mif"];
    [self loadMapInfoForSameFloorWithElevator:path startPos:startPos endPos:endPos paymentCenter:pPosition];
}

#pragma mark - load data new version v2.0
/**
 *  加载起始地址
 **/
- (void)loadMapInfoFile:(NSString *)path
               position:(MyPositon *)position
                isStart:(BOOL)isStart
{
    _isStartMap = isStart;
    _myPosition = position;
    [SVProgressHUD showWithStatus:@"正在加载地图数据"];
    sIndex = -1;
    if (pointsArray != nil && pointsArray.count > 0) {
        [pointsArray removeAllObjects];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //耗时解析过程
        MifFileReader *mifReader = [[MifFileReader alloc] init];
        pointsArray = [mifReader readMifDataNewVersion:path];
        
        [self findMinDistancePoint:position];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [_mapViewNew setPointsArray:pointsArray];
            [_mapViewNew setNeedsDisplay];
            
            [self drawFindingCarPath];
            
            [SVProgressHUD dismissWithSuccess:@"加载完毕"];
            
        });
    });
}

/**
 *  加载目的地址
 **/
- (void)loadMapInfoFile:(NSString *)path
               startPos:(MyPositon *)startPos
                 endPos:(MyPositon *)endPos
                isStart:(BOOL)isStart
{
    _isStartMap = isStart;
    _endPositon = endPos;
    [SVProgressHUD showWithStatus:@"正在加载地图数据"];
    sIndex = -1;
    if (pointsArray != nil && pointsArray.count > 0) {
        [pointsArray removeAllObjects];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //耗时解析过程
        MifFileReader *mifReader = [[MifFileReader alloc] init];
        pointsArray = [mifReader readMifDataNewVersion:path];
        
        [self findMinDistancePoint:startPos];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [_mapViewNew setPointsArray:pointsArray];
            [_mapViewNew setNeedsDisplay];
            
            [self drawFindingCarPath];
            
            [SVProgressHUD dismissWithSuccess:@"加载完毕"];
            
        });
    });
}

- (void)loadMapInfoForSameFloor:(NSString *)path
                       startPos:(MyPositon *)startPos
                         endPos:(MyPositon *)endPos
{
    _isSameFloor = YES;
    _myPosition = startPos;
    _endPositon = endPos;
    sIndex = -1;
    if (pointsArray != nil && pointsArray.count > 0) {
        [pointsArray removeAllObjects];
    }
    [SVProgressHUD showWithStatus:@"正在加载地图数据"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //耗时解析过程
        MifFileReader *mifReader = [[MifFileReader alloc] init];
        pointsArray = [mifReader readMifDataNewVersion:path];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [_mapViewNew setPointsArray:pointsArray];
            [_mapViewNew setNeedsDisplay];
            
//            [self drawFindingCarPath];
            [self drawPeople:_myPosition];
            
            UIImage *image = [UIImage imageNamed:@"findcar_icon_car.png"];
            [self drawDestination:_endPositon image:image];
            
            [SVProgressHUD dismissWithSuccess:@"加载完毕"];
            
        });
    });
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

#pragma mark - load data new version v2.1
/**
 *  加载起始地址
 **/
- (void)loadMapInfoFile:(NSString *)path
               position:(MyPositon *)position
          paymentCenter:(MyPositon *)pPosition
                isStart:(BOOL)isStart
{
    _isStartMap = isStart;
    _myPosition = position;
    [SVProgressHUD showWithStatus:@"正在加载地图数据"];
    sIndex = -1;
    if (pointsArray != nil && pointsArray.count > 0) {
        [pointsArray removeAllObjects];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //耗时解析过程
        MifFileReader *mifReader = [[MifFileReader alloc] init];
        pointsArray = [mifReader readMifDataNewVersion:path];
        
        [self findMinDistancePoint:pPosition];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [_mapViewNew setPointsArray:pointsArray];
            [_mapViewNew setNeedsDisplay];
            
            [self drawFindingCarPath];
            
            [SVProgressHUD dismissWithSuccess:@"加载完毕"];
            
        });
    });
}

/**
 *  加载目的地址
 **/
- (void)loadMapInfoFile:(NSString *)path
               startPos:(MyPositon *)startPos
                 endPos:(MyPositon *)endPos
          paymentCenter:(MyPositon *)pPosition
                isStart:(BOOL)isStart
{
    _isStartMap = isStart;
    _endPositon = endPos;
    [SVProgressHUD showWithStatus:@"正在加载地图数据"];
    sIndex = -1;
    if (pointsArray != nil && pointsArray.count > 0) {
        [pointsArray removeAllObjects];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //耗时解析过程
        MifFileReader *mifReader = [[MifFileReader alloc] init];
        pointsArray = [mifReader readMifDataNewVersion:path];
        
        [self findMinDistancePoint:pPosition];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [_mapViewNew setPointsArray:pointsArray];
            [_mapViewNew setNeedsDisplay];
            
            [self drawFindingCarPath];
            
            [SVProgressHUD dismissWithSuccess:@"加载完毕"];
            
        });
    });
}

/**
 *  电梯，缴费中心
 **/
- (void)loadMapInfoFile:(NSString *)path
          paymentCenter:(MyPositon *)pPosition
{
    [SVProgressHUD showWithStatus:@"正在加载地图数据"];
    sIndex = -1;
    if (pointsArray != nil && pointsArray.count > 0) {
        [pointsArray removeAllObjects];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //耗时解析过程
        MifFileReader *mifReader = [[MifFileReader alloc] init];
        pointsArray = [mifReader readMifDataNewVersion:path];
        
        [self findMinDistancePoint:pPosition];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [_mapViewNew setPointsArray:pointsArray];
            [_mapViewNew setNeedsDisplay];
            
            [self drawFacility:minDistancePoint tag:300];
            
            [SVProgressHUD dismissWithSuccess:@"加载完毕"];
            
        });
    });
}

/**
 *  人 电梯 车
 */
- (void)loadMapInfoForSameFloorWithElevator:(NSString *)path
                                   startPos:(MyPositon *)startPos
                                     endPos:(MyPositon *)endPos
                              paymentCenter:(MyPositon *)pPosition
{
    _isSameFloor = YES;
    _myPosition = startPos;
    _endPositon = endPos;
    sIndex = -1;
    if (pointsArray != nil && pointsArray.count > 0) {
        [pointsArray removeAllObjects];
    }
    [SVProgressHUD showWithStatus:@"正在加载地图数据"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //耗时解析过程
        MifFileReader *mifReader = [[MifFileReader alloc] init];
        pointsArray = [mifReader readMifDataNewVersion:path];
        
        [self findMinDistancePoint:pPosition];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [_mapViewNew setPointsArray:pointsArray];
            [_mapViewNew setNeedsDisplay];
            
            [self drawFindingCarPath];
            [self drawPeople:_myPosition];
            
            UIImage *image = [UIImage imageNamed:@"findcar_icon_car.png"];
            [self drawDestination:_endPositon image:image];
            
            [SVProgressHUD dismissWithSuccess:@"加载完毕"];
            
        });
    });
}

#pragma mark - draw something

/**
 *  画设施
 **/
- (void)drawFacility:(FacilityPoints *)facility tag:(int)tag
{
    
    UIImage *image = [UIImage imageNamed:@"parking.png"];
    CGFloat scale = (self.zoomScale / self.minimumZoomScale);
    
    //不同设施显示不同的图片
    switch (facility.fIndex) {
        case FACILITY_NO_NDB:
        {
            image = FACILITY_IMAGE_NDB;
        }
            break;
        case FACILITY_NO_ESCALATOR:
        {
            image = FACILITY_IMAGE_ESCALATOR;
        }
            break;
        case FACILITY_NO_LIFT:
        {
            image = FACILITY_IMAGE_LIFT;
        }
            break;
        case FACILITY_NO_TOILETS:
        {
            image = FACILITY_IMAGE_TOILETS;
        }
            break;
        case FACILITY_NO_DISABLED_TOILETS:
        {
            image = FACILITY_IMAGE_DISABLED_TOILETS;
        }
            break;
        case FACILITY_NO_MCR:
        {
            image = FACILITY_IMAGE_MCR;
        }
            break;
        case FACILITY_NO_CASHIER:
        {
            image = FACILITY_IMAGE_CASHIER;
        }
            break;
        case FACILITY_NO_CSC:
        {
            image = FACILITY_IMAGE_CSC;
        }
            break;
        case FACILITY_NO_PARKING:
        {
            image = FACILITY_IMAGE_PARKING;
        }
            break;
        case FACILITY_NO_PAYMENT_CETENR:
        {
            image = FACILITY_IMAGE_PAYMENT_CENTER;
        }
            break;
            
        default:
            break;
    }
    
    if (self.facilityType == 0) {//全部
        
        UIImageView *imgView = [[UIImageView alloc] initWithImage:image];
        imgView.center = CGPointMake(facility.point.x * RATIO * scale, (MAP_HEIGHT - facility.point.y) * RATIO * scale + _offset_y);
        imgView.tag = tag;
        
        [self addSubview:imgView];
    }
}

/**
 *  画寻车指引
 **/
- (void)drawFindingCarPath
{
    if (_isFindingcar)//寻车状态下（不同floor）
    {
        [self drawFacility:minDistancePoint tag:300];
        
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

/**
 *  画缴费中心
 **/
- (void)drawPaymentCenter:(MyPositon *)position image:(UIImage *)image
{
    CGFloat scale = (self.zoomScale / self.minimumZoomScale);
    
    [[self viewWithTag:202] removeFromSuperview];
    UIImageView *pImageView = [[UIImageView alloc] initWithImage:image];
    pImageView.tag = 202;
    pImageView.center = CGPointMake((position.point.x - OFFSET_X) * RATIO * scale, (MAP_HEIGHT - position.point.y)* RATIO * scale + _offset_y * scale);
    [self addSubview:pImageView];
    
    //弹出pop，提示是缴费中心
    popover.hidden = NO;
    [self bringSubviewToFront:popover];
    [popover setTitle:@"缴费中心" subTitle:@"先缴费，后提车"];
    popover.center = CGPointMake((position.point.x - OFFSET_X) * RATIO * scale, (MAP_HEIGHT - position.point.y)* RATIO * scale + _offset_y * scale - 20.0f);
    _touchPoint = CGPointMake((position.point.x - OFFSET_X) * RATIO * scale, (MAP_HEIGHT - position.point.y)* RATIO * scale + _offset_y * scale);
    
//    [self drawFindCarPathFrom:CGPointZero toPoint:CGPointZero];
}

- (void)drawFindCarPathFrom:(CGPoint)fPoint toPoint:(CGPoint)toPoint
{
    CGFloat scale = (self.zoomScale / self.minimumZoomScale);
//    pathView.scale = scale;
//    pathView.startPoint = CGPointMake((_myPosition.point.x - OFFSET_X) * RATIO * scale, (MAP_HEIGHT - _myPosition.point.y)* RATIO * scale + _offset_y * scale);
//    pathView.paymentPoint = CGPointMake((self.paymentPostion.point.x - OFFSET_X) * RATIO * scale, (MAP_HEIGHT - self.paymentPostion.point.y)* RATIO * scale + _offset_y * scale);
//    pathView.endPoint = CGPointMake((_endPositon.point.x - OFFSET_X) * RATIO * scale, (MAP_HEIGHT - _endPositon.point.y)* RATIO * scale + _offset_y * scale);
//    [pathView setNeedsDisplay];
    
    UIGraphicsBeginImageContext(CGSizeMake(_mapViewNew.frame.size.width, _mapViewNew.frame.size.height));//创建一个新图像上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetAllowsAntialiasing(context, TRUE);
    CGContextSetShouldAntialias(context, true);
    
    CGContextMoveToPoint(context, (_myPosition.point.x - OFFSET_X) * RATIO * scale, (MAP_HEIGHT - _myPosition.point.y)* RATIO * scale + _offset_y * scale);  // 开始坐标右边开始
    CGContextAddLineToPoint(context, (self.paymentPostion.point.x - OFFSET_X) * RATIO * scale, (MAP_HEIGHT - self.paymentPostion.point.y)* RATIO * scale + _offset_y * scale);
    CGContextAddLineToPoint(context, (_endPositon.point.x - OFFSET_X) * RATIO * scale, (MAP_HEIGHT - _endPositon.point.y)* RATIO * scale + _offset_y * scale);
    
    CGContextSetLineWidth(context, 5.0f);
    //    CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    
    //    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathStroke); //根据坐标绘制路径
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();//将上下文转为一个UIImage对象。
    
    UIGraphicsEndImageContext();
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:theImage];
    imageView.tag = 121;
    [self addSubview:imageView];
}

/**
 *  刷新设施图片
 **/
- (void)reDrawFacilities:(int)type
{
    _facilityType = type;
    CGFloat scale = (self.zoomScale / self.minimumZoomScale);
    [self didDisplayFacilitiesAtScale:scale];
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
    [self didDisplayFacilitiesAtScale:scale];
    [self didDisplayPerson:scale];
    [self didDisplayDestination:scale];
    [self didDisplayPaymentCenter:scale];
//    [self didDisplayPath:scale];
    [self didDisplayPopoverView:_selectedPoint];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    [self didDisplayFacilitiesAtScale:scale];
//    [self didDisplayPopoverView:_selectedPoint];
    
    [scrollView setZoomScale:scale animated:NO];
    [_mapViewNew setNeedsDisplay];
}

#pragma mark - control uiimage display
/**
 *  控制设施图片的显示
 **/
- (void)didDisplayFacilitiesAtScale:(float)scale
{
    int i = 0;
    for (id obj in facilitiesArray)
    {
        FacilityPoints *facility = obj;
        UIImageView *imageView = (UIImageView *)[self viewWithTag:(kOffset_tag + i)];
        imageView.center = CGPointMake(facility.point.x * RATIO * scale, (MAP_HEIGHT - facility.point.y) * RATIO * scale + _offset_y * scale);
        i++;
        
        if (_facilityType == 0)//全部设施
        {
            imageView.alpha = 1;
        }
        else//特定设施
        {
            if (facility.fIndex == _facilityType) {
                imageView.alpha = 1;
            }
            else
            {
                imageView.alpha = 0;
            }
        }
    }
    
    //控制寻车时的设施缩放
    if (_isFindingcar) {
        UIImageView *imageView = (UIImageView *)[self viewWithTag:300];
        if (imageView)
        {
            imageView.center = CGPointMake(minDistancePoint.point.x * RATIO * scale, (MAP_HEIGHT - minDistancePoint.point.y) * RATIO * scale + _offset_y * scale);
        }
    }
}

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
 *  控制 缴费中心 图片的显示
 **/
- (void)didDisplayPaymentCenter:(float)scale
{
    UIImageView *imageView = (UIImageView *)[self viewWithTag:202];
    if (imageView && self.paymentPostion != nil)
    {
        imageView.center = CGPointMake((self.paymentPostion.point.x - OFFSET_X) * RATIO * scale, (MAP_HEIGHT - self.paymentPostion.point.y)* RATIO * scale + _offset_y * scale);
    }
}

/**
 *  控制 地图路线View的放大缩小 的显示
 **/
- (void)didDisplayPath:(float)scale
{
//    pathView.scale = scale;
//    pathView.startPoint = CGPointMake((_myPosition.point.x - OFFSET_X) * RATIO * scale, (MAP_HEIGHT - _myPosition.point.y)* RATIO * scale + _offset_y * scale);
//    pathView.paymentPoint = CGPointMake((self.paymentPostion.point.x - OFFSET_X) * RATIO * scale, (MAP_HEIGHT - self.paymentPostion.point.y)* RATIO * scale + _offset_y * scale);
//    pathView.endPoint = CGPointMake((_endPositon.point.x - OFFSET_X) * RATIO * scale, (MAP_HEIGHT - _endPositon.point.y)* RATIO * scale + _offset_y * scale);
//    [pathView setNeedsDisplay];
//    CGFloat scale = (self.zoomScale / self.minimumZoomScale);
    //    pathView.scale = scale;
    //    pathView.startPoint = CGPointMake((_myPosition.point.x - OFFSET_X) * RATIO * scale, (MAP_HEIGHT - _myPosition.point.y)* RATIO * scale + _offset_y * scale);
    //    pathView.paymentPoint = CGPointMake((self.paymentPostion.point.x - OFFSET_X) * RATIO * scale, (MAP_HEIGHT - self.paymentPostion.point.y)* RATIO * scale + _offset_y * scale);
    //    pathView.endPoint = CGPointMake((_endPositon.point.x - OFFSET_X) * RATIO * scale, (MAP_HEIGHT - _endPositon.point.y)* RATIO * scale + _offset_y * scale);
    //    [pathView setNeedsDisplay];
    
    UIGraphicsBeginImageContext(CGSizeMake(_mapViewNew.frame.size.width / scale, _mapViewNew.frame.size.height / scale));//创建一个新图像上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetAllowsAntialiasing(context, TRUE);
    CGContextSetShouldAntialias(context, true);
    
    CGContextMoveToPoint(context, (_myPosition.point.x - OFFSET_X) * RATIO * scale, (MAP_HEIGHT - _myPosition.point.y)* RATIO * scale + _offset_y * scale);  // 开始坐标右边开始
    CGContextAddLineToPoint(context, (self.paymentPostion.point.x - OFFSET_X) * RATIO * scale, (MAP_HEIGHT - self.paymentPostion.point.y)* RATIO * scale + _offset_y * scale);
    CGContextAddLineToPoint(context, (_endPositon.point.x - OFFSET_X) * RATIO * scale, (MAP_HEIGHT - _endPositon.point.y)* RATIO * scale + _offset_y * scale);
    
    CGContextSetLineWidth(context, 5.0f);
    //    CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    
    //    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathStroke); //根据坐标绘制路径
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();//将上下文转为一个UIImage对象。
    
    UIGraphicsEndImageContext();
    
    UIImageView *imageView = (UIImageView *)[self viewWithTag:121];
    imageView.image = theImage;
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

#pragma mark - animation
/**
 *  起始界面的动画
 **/
- (void)doPathAnimation
{
    CGFloat scale = (self.zoomScale / self.minimumZoomScale);
    _animationFinished = NO;
    if (_isFindingcar)//如果是寻车模式
    {
        UIImage *image = [UIImage imageNamed:@"findcar_icon_person.png"];
        if (_pImageView == nil) {
            _pImageView = [[UIImageView alloc] initWithImage:image];
            [self addSubview:_pImageView];
        }
        _pImageView.center = CGPointMake(_myPosition.point.x * RATIO * scale, (MAP_HEIGHT - _myPosition.point.y) * RATIO * scale + _offset_y * scale);
        _pImageView.alpha = 1;
        
        //执行动画
        [UIView animateWithDuration:1.0f animations:^{
            
            _pImageView.center = CGPointMake(minDistancePoint.point.x * RATIO * scale, (MAP_HEIGHT - minDistancePoint.point.y) * RATIO * scale + _offset_y * scale);
            
        } completion:^(BOOL finished) {
            if (finished)
            {
                [UIView animateWithDuration:1.5f animations:^{
                    _pImageView.image = FACILITY_IMAGE_LIFT;
                    
                    _pImageView.center = CGPointMake(minDistancePoint.point.x * RATIO * scale, (MAP_HEIGHT - minDistancePoint.point.y) * RATIO * scale + 200.0f + _offset_y * scale);
                    
                } completion:^(BOOL finished) {
                    if (finished)
                    {
                        _pImageView.alpha = 0;
                        _pImageView.center = CGPointMake(_myPosition.point.x * RATIO * scale, (MAP_HEIGHT - _myPosition.point.y) * RATIO * scale + _offset_y * scale);
                    }
                }];
            }
        }];
    }
}

/**
 *  目的界面的动画
 **/
- (void)doDestinationAnimation:(AnimationCompletion)completionHandler
{
    CGFloat scale = (self.zoomScale / self.minimumZoomScale);
    if (_isFindingcar)//如果是寻车模式
    {
        if (_pImageView == nil) {
            _pImageView = [[UIImageView alloc] initWithImage:FACILITY_IMAGE_LIFT];
            [self addSubview:_pImageView];
        }
        _pImageView.center = CGPointMake(minDistancePoint.point.x * RATIO * scale, (MAP_HEIGHT - minDistancePoint.point.y) * RATIO * scale - 400.0f + _offset_y * scale);
        _pImageView.alpha = 1;
        
        //执行动画
        [UIView animateWithDuration:1.0f animations:^{
            
            _pImageView.center = CGPointMake(minDistancePoint.point.x * RATIO * scale, (MAP_HEIGHT - minDistancePoint.point.y) * RATIO * scale + _offset_y * scale);
            
        } completion:^(BOOL finished) {
            if (finished)
            {
                [UIView animateWithDuration:1.5f animations:^{
                    
                    UIImage *image = [UIImage imageNamed:@"findcar_icon_person.png"];
                    _pImageView.image = image;
                    
                    _pImageView.center = CGPointMake(_endPositon.point.x * RATIO * scale, (MAP_HEIGHT - _endPositon.point.y) * RATIO * scale + _offset_y * scale);
                    
                } completion:^(BOOL finished) {
                    if (finished)
                    {
                        _pImageView.alpha = 0;
                        _pImageView.center = CGPointMake(minDistancePoint.point.x * RATIO * scale, (MAP_HEIGHT - minDistancePoint.point.y) * RATIO * scale - 400.0f + _offset_y * scale);
                        _animationFinished = YES;
                        completionHandler();
                    }
                }];
            }
        }];
    }
}

/**
 *  同一楼层的动画
 **/
- (void)doSameFloorAnimation:(AnimationCompletion)completionHandler
{
    if (_isSameFloor) {
        CGFloat scale = (self.zoomScale / self.minimumZoomScale);
        UIImage *image = [UIImage imageNamed:@"findcar_icon_person.png"];
        if (_pImageView == nil) {
            _pImageView = [[UIImageView alloc] initWithImage:image];
            [self addSubview:_pImageView];
        }
        _pImageView.center = CGPointMake(_myPosition.point.x * RATIO * scale, (MAP_HEIGHT - _myPosition.point.y) * RATIO * scale + _offset_y * scale);
        _pImageView.alpha = 1;
        
        //执行动画
        [UIView animateWithDuration:1.0f animations:^{
            
            _pImageView.center = CGPointMake(_endPositon.point.x * RATIO * scale, (MAP_HEIGHT - _endPositon.point.y) * RATIO * scale + _offset_y * scale);
            
        } completion:^(BOOL finished) {
            if (finished)
            {
                _pImageView.alpha = 0;
                _pImageView.center = CGPointMake(_myPosition.point.x * RATIO * scale, (MAP_HEIGHT - _myPosition.point.y) * RATIO * scale + _offset_y * scale);
                completionHandler();
            }
        }];
    }
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
    CGFloat scale = (self.zoomScale / self.minimumZoomScale);
    //弹出pop，提示是缴费中心
    popover.hidden = NO;
    [self bringSubviewToFront:popover];
    [popover setTitle:@"缴费中心" subTitle:@"先缴费，后提车"];
    popover.center = CGPointMake((position.point.x - OFFSET_X) * RATIO * scale, (MAP_HEIGHT - position.point.y)* RATIO * scale + _offset_y * scale - 20.0f);
    _touchPoint = CGPointMake((position.point.x - OFFSET_X) * RATIO * scale, (MAP_HEIGHT - position.point.y)* RATIO * scale + _offset_y * scale);
}

/**
 *  设置弹出pop的文字内容
 */
- (void)setPopupTitleText:(NSString *)title subText:(NSString *)subStr
{
    [popover setTitle:title subTitle:subStr];
}

/**
 *  获取路径
 */
- (void)findPathTest:(NSString *)filePath
{
    NSMutableArray *paths = [_mapViewNew findPathStartX:_myPosition.point.x statY:_myPosition.point.y endX:minDistancePoint.point.x endY:minDistancePoint.point.y filePath:filePath];
    [_mapViewNew drawPaths:paths];
}

/**
 *  人，车，缴费中心同一层，获取路径
 */
- (void)findPathSameFloor:(CGPoint)start
                  payment:(CGPoint)payment
                      end:(CGPoint)end
                 filePath:(NSString *)filePath
{
    NSMutableArray *paths = [[NSMutableArray alloc] init];
    
    NSMutableArray *path1 = [_mapViewNew findPathStartX:start.x
                                                  statY:start.y
                                                   endX:payment.x
                                                   endY:payment.y
                                               filePath:filePath];
    
    NSMutableArray *path2 = [_mapViewNew findPathStartX:payment.x
                                                  statY:payment.y
                                                   endX:end.x
                                                   endY:end.y
                                               filePath:filePath];
    [paths addObjectsFromArray:path1];
    [paths addObjectsFromArray:path2];
    
    [_mapViewNew drawPaths:paths];
}

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
            filePath:(NSString *)path
{
    NSMutableArray *paths = [[NSMutableArray alloc] init];
    if (ePoint.x == 0 && ePoint.y == 0)
    {
        NSMutableArray *path1 = [_mapViewNew findPathStartX:from.x
                                                      statY:from.y
                                                       endX:to.x
                                                       endY:to.y
                                                   filePath:path];
        [paths addObjectsFromArray:path1];
    }
    else
    {
        NSMutableArray *path1 = [_mapViewNew findPathStartX:from.x
                                                      statY:from.y
                                                       endX:ePoint.x
                                                       endY:ePoint.y
                                                   filePath:path];
        
        NSMutableArray *path2 = [_mapViewNew findPathStartX:ePoint.x
                                                      statY:ePoint.y
                                                       endX:to.x
                                                       endY:to.y
                                                   filePath:path];
        [paths addObjectsFromArray:path1];
        [paths addObjectsFromArray:path2];
    }
    
    [_mapViewNew drawPaths:paths];
}

@end
