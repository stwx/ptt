//
//  PttProgressHUD.h
//  PTT
//
//  Created by xihan on 15/6/4.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^Timeout)();
typedef void(^TimeBlock)();
@interface PttRecordHUD : UIView

+ (void)showWithTimeoutBlock:(Timeout)timeout;

+ (void)dismissWithSuccess:(NSString *)str;

+ (void)dismissWithError:(NSString *)str;

+ (void)dismissWithTimeShortBlock:(TimeBlock)blcok;

@property (nonatomic, strong)Timeout timeout;
@property (nonatomic, strong) TimeBlock block;

@end
