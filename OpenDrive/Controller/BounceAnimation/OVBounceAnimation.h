//
//  OVBounceAnimation.h
//  OpenDrive
//
//  Created by ioshero on 1/3/16.
//  Copyright © 2016 ioshero. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef CGFloat OVBounceAnimationStiffness;

extern OVBounceAnimationStiffness OVBounceAnimationStiffnessLight;
extern OVBounceAnimationStiffness OVBounceAnimationStiffnessMedium;
extern OVBounceAnimationStiffness OVBounceAnimationStiffnessHeavy;

@interface OVBounceAnimation : CAKeyframeAnimation

@property (nonatomic, retain) id fromValue;
@property (nonatomic, retain) id byValue;
@property (nonatomic, retain) id toValue;
@property (nonatomic, assign) NSUInteger numberOfBounces;
@property (nonatomic, assign) BOOL shouldOvershoot; //default YES
@property (nonatomic, assign) BOOL shake; //if shaking, set fromValue to the furthest value, and toValue to the current value
@property (nonatomic, assign) OVBounceAnimationStiffness stiffness;

+ (OVBounceAnimation*) animationWithKeyPath:(NSString*)keyPath;


@end
