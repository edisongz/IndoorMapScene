//
//  Utils.m
//  IndoorMapScene
//
//  Created by apple on 13-10-29.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+ (UIBezierPath *)bezierPathFromCoordinateString:(NSString *)strCoordinate
{
    UIBezierPath  *path         = [UIBezierPath new];
    NSArray *data = [strCoordinate componentsSeparatedByString:@","];
    NSUInteger  countTotal      = [data count];
    NSUInteger  countCoord      = countTotal/2;
    
    for(NSUInteger i = 0; i < countCoord; i++)
    {
        NSUInteger index = i<<1;
        CGPoint aPoint = CGPointMake([[data objectAtIndex:index] floatValue],
                                     [[data objectAtIndex:index+1] floatValue]);
        
        if(i == 0)
        {
            [path moveToPoint:aPoint];
        }
        [path addLineToPoint:aPoint];
    }
    
    [path closePath];
    return path;
}

+ (NSString *)pathStringWithFrame:(CGRect)rect
{
    NSMutableString *result = [[NSMutableString alloc] init];
    [result appendString:[NSString stringWithFormat:@"%f", rect.origin.x]];
    [result appendString:@","];
    [result appendString:[NSString stringWithFormat:@"%f", rect.origin.y]];
    [result appendString:@","];
    [result appendString:[NSString stringWithFormat:@"%f", rect.origin.x + rect.size.width]];
    [result appendString:@","];
    [result appendString:[NSString stringWithFormat:@"%f", rect.origin.y]];
    [result appendString:@","];
    [result appendString:[NSString stringWithFormat:@"%f", rect.origin.x + rect.size.width]];
    [result appendString:@","];
    [result appendString:[NSString stringWithFormat:@"%f", rect.origin.y + rect.size.height]];
    [result appendString:@","];
    [result appendString:[NSString stringWithFormat:@"%f", rect.origin.x]];
    [result appendString:@","];
    [result appendString:[NSString stringWithFormat:@"%f", rect.origin.y + rect.size.height]];
    return result;
}

+ (CGPoint)gravityPointInRect:(CGRect)rect
{
    return CGPointMake(rect.origin.x + rect.size.width/2.0f, rect.origin.y + rect.size.height/2.0f);
}

@end
