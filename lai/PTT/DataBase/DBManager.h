//
//  NDBManager.h
//  PTT
//
//  Created by xihan on 15/6/30.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Conversation, Message;

@interface DBManager : NSObject

#pragma mark ------- Friend --------

+ (void)saveFriendListByDicArray:(NSArray *)dicArray;
+ (void)saveNewFriendByDic:(NSDictionary *)dic;

+ (void)deleteFriendByUid:(NSString *)uid;
+ (void)deleteFriendByGid:(NSString *)gid;
+ (void)deleteAllFriends;

+ (BOOL)isFriendExistedByGid:(NSString *)gid;
+ (BOOL)isFriendExistedByUid:(NSString *)uid;

#pragma mark --------- Group ---------

+ (void)saveGroupListByDicArray:(NSArray *)dicArray;
+ (void)saveNewGroupByDic:(NSDictionary *)dic;

+ (void)deleteAllGroups;
+ (void)deleteGroupByGid:(NSString *)gid;

+ (void)changeGroupName:(NSString *)name
                groupId:(NSString *)gid;

+ (BOOL)isGroupExistedByGid:(NSString *)gid;

#pragma mark --------- Member ---------

+ (void)saveMemberListByDicArray:(NSArray *)dicArray
                         toGroup:(NSString *)gid;
+ (void)saveMemberToGroupId:(NSString *)gid
                    dataDic:(NSString *)dic;

+ (void)deleteAllMembersInGroup:(NSString *)gid;
+ (void)deleteMemberByUid:(NSString *)uid
                  inGroup:(NSString *)gid;

+ (NSArray *)getMembersByGroupId:(NSString *)gid;

#pragma mark --------- Conversation ---------
+ (void)saveChatConversationByDic:(NSDictionary *)dataDic
                         isUnread:(BOOL)isUnread;
+ (void)saveTalkConversationByDic:(NSDictionary *)dataDic
                         isUnread:(BOOL)isUnread;

+ (void)saveNewMemberConversationByDic:(NSDictionary *)dataDic
                                unread:(BOOL)unread;
+ (void)saveMemberQuitConversationByDic:(NSDictionary *)dataDic
                                 unread:(BOOL)unread;

+ (void)saveInviteMeConversationByDic:(NSDictionary *)dataDic;
+ (void)saveInviteOtherConversationByDic:(NSDictionary *)dataDic;
+ (void)saveAgreeInvitedConversationByDic:(NSDictionary *)dataDic;

+ (void)saveJoinGroupConversationByDic:(NSDictionary *)dataDic;

+ (void)deleteConversationByGroupId:(NSString *)gid;
+ (void)deleteConversationByUserId:(NSString *)uid;

+ (void)clearConversationUnreadCout:(Conversation *)conversation;

#pragma mark --------- Message ---------

+ (Message *)saveChatMessageByDic:(NSDictionary *)dataDic;
+ (void)saveTalkMessageByDic:(NSDictionary *)dataDic;
+ (void)saveNewMemberMessageByDic:(NSDictionary *)dataDic;

+ (void)deleteMessagesByGroupId:(NSString *)gid;

+ (void)updateMessageSendResult:(Message *)message
                         result:(int)result;
+ (void)updateMessageUnread:(Message *)message;

@end
