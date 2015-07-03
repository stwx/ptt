//
//  Conversation.h
//  PTT
//
//  Created by xihan on 15/7/1.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef enum {
    CT_FRIEND_CHAT,
    CT_GROUP_CHAT,
    CT_NEW_INVITE,
    CT_INVITE_WAIT,
    CT_INVITE_DISAGREE,
}ConversationType;

@interface Conversation : NSManagedObject

@property (nonatomic, retain) NSNumber * conversationType;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * chatStatus;
@property (nonatomic, retain) NSString * detail;
@property (nonatomic, retain) NSString * gid;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSNumber * unreadCount;

@end
