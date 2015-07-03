//
//  HttpAckHandler.h
//  PTT
//
//  Created by xihan on 15/6/3.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HttpAckHandler : NSObject

+ (NSDictionary *)handleRegAck:(NSString *)ackString;
+ (NSDictionary *)handleLoginAck:(NSString *)ackString;

+ (NSDictionary *)handleChangPwdAck:(NSString *)ackString;
+ (NSDictionary *)handleUserRenamAck:(NSString *)ackString;
+ (NSDictionary *)handleGetUserInfoAck:(NSString *)ackString;

+ (NSDictionary *)handleInviteAck:(NSString *)ackString;
+ (NSDictionary *)handleAgreeInviteAck:(NSString *)ackString;
+ (NSDictionary *)handleDisagreeInviteAck:(NSString *)ackString;
+ (NSDictionary *)handleDeleteFriendAck:(NSString *)ackString;
+ (NSDictionary *)handleGetFriendListByPageAck:(NSString *)ackString;
+ (NSDictionary *)handleGetAllFriendListAck:(NSString *)ackString;

+ (NSDictionary *)handleCreateGroupaAck:(NSString *)ackString;
+ (NSDictionary *)handleGetGroupAck:(NSString *)ackString;
+ (NSDictionary *)handleGroupRenameAck:(NSString *)ackString;
+ (NSDictionary *)handleGetMemberAck:(NSString *)ackString;
+ (NSDictionary *)handleAddMembersAck:(NSString *)ackString;
+ (NSDictionary *)handleQuitGroupAck:(NSString *)ackString
                             groupId:(NSString *)gid;

+ (NSDictionary *)handleJoinTalkAck:(NSString *)ackString;
+ (NSDictionary *)handleQuitTalkAck:(NSString *)ackString;

+ (NSDictionary *)handleSendMsgAck:(NSString *)ackString;

+ (NSDictionary *)handleUploadAck:(NSString *)ackString;

@end
