//
//  loadingView.m
//  e-Learning
//
//  Created by RenHongwei on 15/3/22.
//  Copyright (c) 2015年 RenHongwei. All rights reserved.
//

#import "LoadingView.h"

@interface LoadingView()
{
    UIActivityIndicatorView *_activityIndicatorView;
}
@end

@implementation LoadingView

- (instancetype)initWithSuperVC:(UIViewController *)superVC
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    
    UIView *background = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    background.backgroundColor = [UIColor grayColor];
    background.alpha = 0.5;
    [self addSubview:background];

    _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake( 0, 0, 50, 50)];
    _activityIndicatorView.center = CGPointMake(Main_Screen_Width * 0.5, Main_Screen_Height * 0.5);
    _activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    _activityIndicatorView.hidesWhenStopped = YES;
  
    [self addSubview:_activityIndicatorView];
    [superVC.view addSubview:self];
    self.hidden = YES;
    return self;
}

- (void)startLoading
{
    MAIN(^{
        self.hidden = NO;
        [_activityIndicatorView startAnimating];
    });
}

- (void)stopLoading
{
    MAIN(^{
        [_activityIndicatorView stopAnimating];
        self.hidden = YES;
    });
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
