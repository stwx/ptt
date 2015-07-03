//
//  HttpManager.h
//  PTT
//
//  Created by xihan on 15/6/3.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpInfo.h"

@interface HttpManager : NSObject

+ (void)registerWithUserId:(NSString *)uid
                  password:(NSString *)password
                   handler:(DicHandler)handler;

+ (void)loginWithUserId:(NSString *)uid
               password:(NSString *)password
                handler:(DicHandler)handler;

+ (void)changeOldPwd:(NSString *)oldPwd
            toNewPwd:(NSString *)newPwd
             handler:(DicHandler)handler;

+ (void)changeToNewNikename:(NSString *)name
                    handler:(DicHandler)handler;

+ (void)getUserInfoByUserId:(NSString *)userId
                    Handler:(DicHandler)handler;

+ (void)inviteFriendByFriendId:(NSString *)fuid
                         notes:(NSString *)notes
                       handler:(DicHandler)handler;

+ (void)deleteFriendByFriendGroupId:(NSString *)fgid
                            Handler:(DicHandler)handler;

+ (void)agreeInvitedForFriendId:(NSString *)fuid
                        Handler:(DicHandler)handler;

+ (void)disagreeInvitedForFriendId:(NSString *)fuid
                             Notes:(NSString *)notes
                           Handler:(DicHandler)handler;

+ (void)getFriendListByPage:(int)page
                    Handler:(DicHandler)handler;

+ (void)getAllFriendAndAckHandler:(DicHandler)handler;

+ (void)getGroupListByPage:(int)page
                   handler:(DicHandler)handler;

+ (void)joinGroupTalkByGroupId:(NSString *)groupId
                       Handler:(DicHandler)handler;

+ (void)quitGroupTalkByGroupId:(NSString *)groupId
                       Handler:(DicHandler)handler;

+ (void)sendMsgToGroupId:(NSString *)gid
                 message:(NSString *)msg
                 msgType:(int)msgType
               voiceTime:(float)voiceTime
                 handler:(DicHandler)handler;

+ (void)getMembersForGroupId:(NSString *)gid
                        page:(int)page
                     handler:(DicHandler)handler;

+ (void)addMembersByUserIds:(NSString *)uids
                  toGroupId:(NSString *)gid
                    handler:(DicHandler)handler;

+ (void)quitGroupByGroupId:(NSString *)gid
                   handler:(DicHandler)handler;

+ (void)createGroupWithGroupName:(NSString *)groupName
                            uids:(NSString *)uids
                         handler:(DicHandler)handler;

+ (void)changeGroupNameByGroupId:(NSString *)groupId
                            name:(NSString *)name
                         handler:(DicHandler)handler;

+ (void)downloadFileByFileName:(NSString *)fileName
                       handler:(DicHandler)handler;

+ (void)uploadFileByFilePath:(NSString *)filePath
                     handler:(DicHandler)handler;
@end
