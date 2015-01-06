//
//  IndoorMapPath.m
//  WisdomMallAPP
//
//  Created by apple on 13-12-18.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "IndoorMapPath.h"

#import "Constants.h"

@implementation IndoorMapPath

@synthesize mapArea         = _mapArea;

-(id)initWithPrimitives:(NSMutableArray *)primitives
           areaLocation:(NSString *)areaLocation
{
    self = [super init];
    if(self != nil)
    {
        // set area id
        CGFloat _offset_y = OFFSET_Y;
        
        self.areaLocation = areaLocation;
        
        // add points to bezier path
        UIBezierPath  *path = [UIBezierPath new];
        
        if (primitives != nil) {
            for (int i = 0; i < primitives.count; i++) {
                MPoint *point = [primitives objectAtIndex:i];
                
                if (i == 0) {
                    [path moveToPoint:CGPointMake((point.x - OFFSET_X) * RATIO, (MAP_HEIGHT - point.y) * RATIO + _offset_y)];
                    continue;
                }
                
                [path addLineToPoint:CGPointMake((point.x - OFFSET_X) * RATIO, (MAP_HEIGHT - point.y) * RATIO + _offset_y)];
            }
            
            [path closePath];
            self.mapArea = path;
        }
        
    }
    return self;
}

-(BOOL)isAreaSelected:(CGPoint)inPointTouch
{
    return CGPathContainsPoint(self.mapArea.CGPath, NULL, inPointTouch, false);
}

@end
