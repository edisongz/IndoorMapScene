//
//  MapArea.h
//  TagImageView
//
//  Created by apple on 13-10-25.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MapArea : NSObject
{
    UIBezierPath        *_mapArea;
    NSUInteger          _areaID;
}

@property (nonatomic, retain)   UIBezierPath        *mapArea;
@property (nonatomic, readonly) NSUInteger          areaID;
-(id)initWithCoordinate:(NSString*)inStrCoordinate areaID:(NSInteger)inAreaID;
-(BOOL)isAreaSelected:(CGPoint)inPointTouch;

@end
