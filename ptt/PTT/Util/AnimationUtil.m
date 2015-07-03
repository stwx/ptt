//
//  AnimationUtil.m
//  e-Learning
//
//  Created by RenHongwei on 15/4/13.
//  Copyright (c) 2015年 RenHongwei. All rights reserved.
//

#import "AnimationUtil.h"
#import <QuartzCore/QuartzCore.h>

@implementation AnimationUtil

+(void)addPopAnimationToView:(UIView *)view duration:(CFTimeInterval)dur
{
    view.alpha = 1;
    CAKeyframeAnimation *animation;
    animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = dur;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 0.9)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    animation.values = values;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:@"easeInEaseOut"];
    [view.layer addAnimation:animation forKey:nil];
}

+(void)fadeoutWithAnimation:(UIView *) view duration :(CFTimeInterval)dur
{
    [UIView animateWithDuration:dur animations:^{
        view.alpha = 0;
    }completion:^(BOOL finished) {
        view.alpha = 1;
        [view removeFromSuperview];
    }];
}

+ (void)addPushAnimationToNavitonController:(UINavigationController *)navitonController
                                       Type:(NSString *)type
                                    subType:(NSString *)subtype{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.6;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = type;
    transition.subtype = subtype;
    [navitonController.view.layer addAnimation:transition forKey:nil];
}

+ (void)addPopAnimationToNavitonController:(UINavigationController *)navitonController
                                      Type:(NSString *)type
                                   subType:(NSString *)subtype{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.4;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = type;
    transition.subtype = subtype;
    [navitonController.view.layer addAnimation:transition forKey:nil];
}

+ (UIImageView *)rotate360DegreeWithImageView:(UIImageView *)imageView{
    CABasicAnimation *animation = [ CABasicAnimation
                                   animationWithKeyPath: @"transform" ];
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    
    //围绕Z轴旋转，垂直与屏幕
    animation.toValue = [ NSValue valueWithCATransform3D:
                         
                         CATransform3DMakeRotation(M_PI, 0.0, 0.0, 1.0) ];
    animation.duration = 0.5;
    //旋转效果累计，先转180度，接着再旋转180度，从而实现360旋转
    animation.cumulative = YES;
    animation.repeatCount = 1000;
    
    //在图片边缘添加一个像素的透明区域，去图片锯齿
    CGRect imageRrect = CGRectMake(0, 0,imageView.frame.size.width, imageView.frame.size.height);
    UIGraphicsBeginImageContext(imageRrect.size);
    [imageView.image drawInRect:CGRectMake(1,1,imageView.frame.size.width-2,imageView.frame.size.height-2)];
    imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [imageView.layer addAnimation:animation forKey:nil];
    return imageView;
}

@end
