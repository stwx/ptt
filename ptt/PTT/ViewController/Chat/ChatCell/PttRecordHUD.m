//
//  PttProgressHUD.m
//  PTT
//
//  Created by xihan on 15/6/4.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import "PttRecordHUD.h"

@interface PttRecordHUD()
{
    NSTimer *myTimer;
    int angle;
    
    UILabel *centerLabel;
    UIImageView *edgeImageView;
    
}
@property (nonatomic, strong, readonly) UIWindow *overlayWindow;
@end

@implementation PttRecordHUD
@synthesize overlayWindow;

+ (PttRecordHUD*)sharedView {
    static dispatch_once_t once;
    static PttRecordHUD *sharedView;
    dispatch_once(&once, ^ {
        sharedView = [[PttRecordHUD alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        sharedView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
    });
    return sharedView;
}

- (void)showWithTimeoutBlock:(Timeout)timeout {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(!self.superview)
            [self.overlayWindow addSubview:self];
        self.timeout = timeout;
        if (!centerLabel){
            centerLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 150, 40)];
            centerLabel.backgroundColor = [UIColor clearColor];
        }
        
        if (!edgeImageView)
            edgeImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"recording_animation"]];
        
        centerLabel.center = CGPointMake([[UIScreen mainScreen] bounds].size.width/2,[[UIScreen mainScreen] bounds].size.height/2);
        centerLabel.text = @"30";
        centerLabel.textAlignment = NSTextAlignmentCenter;
        centerLabel.font = [UIFont systemFontOfSize:30];
        centerLabel.textColor = [UIColor yellowColor];
        
        
        edgeImageView.frame = CGRectMake(0, 0, 154, 154);
        edgeImageView.center = centerLabel.center;
        [self addSubview:edgeImageView];
        [self addSubview:centerLabel];
        
        BACK(^{
            if (myTimer)
                [myTimer invalidate];
            myTimer = nil;
            myTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                       target:self
                                                     selector:@selector(startAnimation)
                                                     userInfo:nil
                                                      repeats:YES];
            
            NSRunLoop *runloop = [NSRunLoop currentRunLoop];
            [runloop addTimer:myTimer forMode:NSDefaultRunLoopMode];
            [runloop run];
        });
        
        
        [UIView animateWithDuration:0.5
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             self.alpha = 1;
                         }
                         completion:^(BOOL finished){
                         }];
        [self setNeedsDisplay];
    });
}

-(void) startAnimation
{
    angle -= 20;
    MAIN((^{
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.09];
        UIView.AnimationRepeatAutoreverses = YES;
        edgeImageView.transform = CGAffineTransformMakeRotation(angle * (M_PI / 180.0f));
        float second = [centerLabel.text floatValue];
        if (second <= 10.0f) {
            centerLabel.textColor = [UIColor redColor];
        }else{
            centerLabel.textColor = [UIColor yellowColor];
        }
        centerLabel.text = [NSString stringWithFormat:@"%.1f",second-0.1];
        
        [UIView commitAnimations];
        if (second == 0) {
            [self dismiss:@"Timeout"];
            if (self.timeout) {
                self.timeout();
            }
        }
    }));
}

+ (void)dismissWithTimeShortBlock:(TimeBlock)timeblock{
    [[PttRecordHUD sharedView] dismissWithBlock:timeblock];
}

+ (void)dismissWithSuccess:(NSString *)str {
    [[PttRecordHUD sharedView] dismiss:str];
}

+ (void)dismissWithError:(NSString *)str {
    [[PttRecordHUD sharedView] dismiss:str];
}

- (void)dismissWithBlock:(TimeBlock)blcok{
    [myTimer invalidate];
    myTimer = nil;
    self.block = blcok;
    float dur = [centerLabel.text floatValue];
    if (dur < 1.5) {
        [self dismiss:@"TooShort"];
    }
    else{
        [self dismiss:nil];
    }
}

- (void)dismiss:(NSString *)state {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [myTimer invalidate];
        myTimer = nil;
        centerLabel.text = state;
        centerLabel.textColor = [UIColor whiteColor];
        
        CGFloat timeLonger;
        if ([state isEqualToString:@"TooShort"]) {
            timeLonger = 1;
        }else{
            timeLonger = 0.6;
        }
        [UIView animateWithDuration:timeLonger
                              delay:0
                            options:UIViewAnimationCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             self.alpha = 0;
                         }
                         completion:^(BOOL finished){
                             if(self.alpha == 0) {
                                 [centerLabel removeFromSuperview];
                                 centerLabel = nil;
                                 [edgeImageView removeFromSuperview];
                                 edgeImageView = nil;
                                 
                                 NSMutableArray *windows = [[NSMutableArray alloc] initWithArray:[UIApplication sharedApplication].windows];
                                 [windows removeObject:overlayWindow];
                                 overlayWindow = nil;
                                 
                                 [windows enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIWindow *window, NSUInteger idx, BOOL *stop) {
                                     if([window isKindOfClass:[UIWindow class]] && window.windowLevel == UIWindowLevelNormal) {
                                         [window makeKeyWindow];
                                         *stop = YES;
                                     }
                                 }];
                             }
                         }];
    });
}

- (UIWindow *)overlayWindow {
    if(!overlayWindow) {
        overlayWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        overlayWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        overlayWindow.userInteractionEnabled = NO;
        [overlayWindow makeKeyAndVisible];
    }
    return overlayWindow;
}

+ (void)showWithTimeoutBlock:(Timeout)timeout {
    [[PttRecordHUD sharedView] showWithTimeoutBlock: timeout];
}


@end
