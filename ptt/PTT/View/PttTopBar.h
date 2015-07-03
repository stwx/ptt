//
//  PttTopBar.h
//  PTT
//
//  Created by xihan on 15/6/6.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^BackBlock)();

@protocol PttTopBarDelegate <NSObject>
@optional
- (void)backToSuperView;

@end

@interface PttTopBar : UIView

@property (nonatomic, assign)id<PttTopBarDelegate>delegate;

- (instancetype)initWithTitle:(NSString *)title;
- (void)changeTitle:(NSString *)title;

@property (nonatomic, strong) BackBlock backBlock;

@end
