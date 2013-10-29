//
//  UIImageView+Effects.m
//  IndoorMapScene
//
//  Created by apple on 13-10-29.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "UIImageView+Effects.h"

@implementation UIImageView (Effects)

#pragma mark - 3d Effects
- (void)setYRotation:(CGFloat)degrees anchorPoint:(CGPoint)point perspectiveCoeficient:(CGFloat)m34
{
	CATransform3D transfrom = CATransform3DIdentity;
	transfrom.m34 = 1.0 / m34;
    CGFloat radiants = degrees / 360.0 * 2 * M_PI;
	transfrom = CATransform3DRotate(transfrom, radiants, 1.0f, 0.0f, 0.0f);
	CALayer *layer = self.layer;
	layer.anchorPoint = point;
	layer.transform = transfrom;
}

@end
