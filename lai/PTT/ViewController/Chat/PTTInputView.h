//
//  PTTInputView.h
//  PTT
//
//  Created by xihan on 15/6/23.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import <UIKit/UIKit.h>

const CGFloat InputViewHeight = 50;

@protocol PTTInputViewDelegate <NSObject>

- (void)IV_SendText:(NSString *)text;
- (void)IV_Record:(BOOL)start;
- (void)IV_Talk:(BOOL)start;
- (void)IV_TalkState:(BOOL)join;
@end

@interface PTTInputView : UIView

@property (nonatomic, assign) id<PTTInputViewDelegate>delegate;

- (void)hideKeyBoard;
- (void)setMiddleBtnEnable:(BOOL)enable;
- (void)changeToTalkState;
@end
