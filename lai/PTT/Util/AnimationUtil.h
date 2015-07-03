//
//  AnimationUtil.h
//  e-Learning
//
//  Created by RenHongwei on 15/4/13.
//  Copyright (c) 2015年 RenHongwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AnimationUtil : NSObject

+ (void)addPopAnimationToView:(UIView *)view
                     duration:(CFTimeInterval)dur;

+ (void)fadeoutWithAnimation:(UIView *) view
                    duration:(CFTimeInterval)dur;

+ (void)addPushAnimationToNavitonController:(UINavigationController *)navitonController
                                       Type:(NSString *)type
                                    subType:(NSString *)subtype;

+ (void)addPopAnimationToNavitonController:(UINavigationController *)navitonController
                                      Type:(NSString *)type
                                   subType:(NSString *)subtype;

+ (UIImageView *)rotate360DegreeWithImageView:(UIImageView *)imageView;
@end
