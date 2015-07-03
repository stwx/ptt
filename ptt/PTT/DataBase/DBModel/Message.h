//
//  Message.h
//  PTT
//
//  Created by xihan on 15/7/1.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef enum {
    MSG_TEXT = 1,
    MSG_RECORD,
    MSG_IMG,
    MSG_TALK
}MsgType;

typedef enum {
    SR_Fail,
    SR_OK,
    SR_Sending
}SendResult;

@interface Message : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * fromSelf;
@property (nonatomic, retain) NSString * gid;
@property (nonatomic, retain) NSNumber * unread;
@property (nonatomic, retain) NSString * msg;
@property (nonatomic, retain) NSNumber * msgType;
@property (nonatomic, retain) NSNumber * recordDur;
@property (nonatomic, retain) NSString * senderName;
@property (nonatomic, retain) NSNumber * sendResult;

@end
