//
//  MessageModel.h
//  PTT
//
//  Created by xihan on 15/6/23.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MessageModel : NSObject

@property (nonatomic, copy) NSString * msg;
@property (nonatomic, copy) NSString * senderName;
@property (nonatomic, copy) NSString * dateString;
@property (nonatomic, retain) NSDate * date;

@property (nonatomic, assign) int msgType;
@property (nonatomic, assign) float recordDur;

@property (nonatomic, assign) BOOL fromSelf;
@property (nonatomic, assign) BOOL isUnread;
@property (nonatomic, assign) BOOL sendResult;
@property (nonatomic, assign) BOOL showTime;

@end
