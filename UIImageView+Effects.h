//
//  UIImageView+Effects.h
//  IndoorMapScene
//
//  Created by apple on 13-10-29.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (Effects)

/** Applies 3d rotation on the y axis of a view.
 @param radiants              The ammount of the rotation expressed in radiants.
 @param anchorPoint           The center of the rotation.
 @param perspectiveCoeficient The perspective coeficient (CATransform3D.m34).
 */
- (void)setYRotation:(CGFloat)radiants anchorPoint:(CGPoint)anchorPoint perspectiveCoeficient:(CGFloat)perspectiveCoeficient;

@end
