//
//  loadingView.h
//  e-Learning
//
//  Created by RenHongwei on 15/3/22.
//  Copyright (c) 2015年 RenHongwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingView : UIView
- (instancetype)initWithSuperVC:(UIViewController *)superVC;
- (void)stopLoading;
- (void)startLoading;

@end
