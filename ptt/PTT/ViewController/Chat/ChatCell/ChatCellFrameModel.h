//
//  ChatCellFrameModel.h
//  PTT
//
//  Created by xihan on 15/6/4.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Message;

extern const CGFloat textPadding;

@interface ChatCellFrameModel : NSObject

@property (nonatomic, strong) Message *message;
@property (nonatomic, assign) BOOL showTime;
@property (nonatomic, assign, readonly) CGRect timeFrame;
@property (nonatomic, assign, readonly) CGRect iconFrame;
@property (nonatomic, assign, readonly) CGRect nameFrame;
@property (nonatomic, assign, readonly) CGRect textFrame;
@property (nonatomic, assign, readonly) CGRect pointFrame;
@property (nonatomic, assign, readonly) CGRect failBtnFrame;
@property (nonatomic, assign, readonly) CGFloat cellHeght;



@end
