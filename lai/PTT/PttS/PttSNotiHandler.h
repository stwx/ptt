//
//  PttSNotiHandler.h
//  PTT
//
//  Created by xihan on 15/6/5.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol PttSNotiDelegate <NSObject>

@optional

- (void)PttSNoti_invitedFromUserId:(NSString *)uid
                              name:(NSString *)name
                              note:(NSString *)note;

- (void)PttsNoti_messageByDic:(NSDictionary *)dic;

- (void)PttsNoti_agreeForUserId:(NSString *)uid
                           fgid:(NSString *)fuid;

- (void)PttsNoti_disagreeForUserId:(NSString *)uid
                              name:(NSString *)name
                              note:(NSString *)note;

- (void)PttSNoti_addToGroupId:(NSString *)gid
                       owerId:(NSString *)uid
                      members:(NSArray *)arry;

- (void)PttSNoti_newGroupMembers:(NSString *)gid
                         inviter:(NSString *)uid
                         members:(NSArray *)array;

- (void)PttSNoti_groupMemberQuit:(NSString *)uid
                         groupId:(NSString *)gid;


- (void)PttsNoti_friendJoinTalkToGroupId:(NSString *)gid
                                     msg:(NSString *)msg;

- (void)PttsNoti_friendQuitTalkFromGroupId:(NSString *)gid
                                       msg:(NSString *)msg;
@end

@interface PttSNotiHandler : NSObject

+ (void)handleNotiWithDic:(NSDictionary *)dic;
+ (PttSNotiHandler *)sharePttsNotiHandler;
@property (nonatomic, weak)id<PttSNotiDelegate>delegate;

@end
