//
//  MapArea.m
//  TagImageView
//
//  Created by apple on 13-10-25.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "MapArea.h"

@implementation MapArea

@synthesize mapArea         = _mapArea;
@synthesize areaID          = _areaID;

-(id)initWithCoordinate:(NSString*)inStrCoordinate areaID:(NSInteger)inAreaID
{
    self = [super init];
    
    if(self != nil)
    {
        // set area id
        _areaID = inAreaID;
        
        inStrCoordinate = @"974,992,1030,890,1080,925,1106,887,1155,890,1158,845,1290,845,1292,890,1345,890,1348,910,1407,909,1407,1038,1440,1039,1441,1085,1450,1086,1447,1136,1391,1149,1391,1164,1264,1166,1263,1138,1016,1139,1016,1019";
        
        NSArray*    arrAreaCoordinates = \
        [inStrCoordinate componentsSeparatedByString:@","];
        
        NSUInteger  countTotal      = [arrAreaCoordinates count];
        NSUInteger  countCoord      = countTotal/2;
        BOOL        isFirstPoint    = YES;
        
        // add points to bezier path
        UIBezierPath  *path = [UIBezierPath new];
        
        for(NSUInteger i = 0; i < countCoord; i++)
        {
            NSUInteger index = i<<1;
            CGPoint aPoint = CGPointMake([[arrAreaCoordinates objectAtIndex:index] floatValue], [[arrAreaCoordinates objectAtIndex:index+1] floatValue]);
            
            if(isFirstPoint)
            {
                [path moveToPoint:aPoint];
                isFirstPoint = NO;
            }
            [path addLineToPoint:aPoint];
        }
        
        [path closePath];
        
        self.mapArea = path;
    }
    return self;
}

-(BOOL)isAreaSelected:(CGPoint)inPointTouch
{
    return CGPathContainsPoint(self.mapArea.CGPath,NULL,inPointTouch,false);
}

@end
