//
//  HttpManager.m
//  PTT
//
//  Created by xihan on 15/6/3.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import "HttpManager.h"
#import "HttpRequest.h"
#import "HttpAckHandler.h"
#import "UDManager.h"

@interface HttpManager()

@property (nonatomic, strong) DicHandler dicHandler;

@end

@implementation HttpManager

+ (void)setDicHandler:(DicHandler)dicHandler
           Dictionary:(NSDictionary *)dic{
    
    HttpManager *manager = [[HttpManager alloc] init];
    manager.dicHandler = dicHandler;
    if (manager.dicHandler) {
        manager.dicHandler(dic);
    }
    
}

+ (void)registerWithUserId:(NSString *)uid
                  password:(NSString *)password
                   handler:(DicHandler)handler{
    NSString *userid = [NSString stringWithFormat:@"%@@a",uid];
    [HttpRequest postRequestWithHttpType:HT_Reg action:ACTION_NULL params:@[ userid, password, @"i"] Handler:^(NSString *ackString) {
        NSDictionary *ackDic = [HttpAckHandler handleRegAck:ackString];
        [HttpManager setDicHandler:handler Dictionary:ackDic];
    }];
}

+ (void)loginWithUserId:(NSString *)uid
               password:(NSString *)password
                handler:(DicHandler)handler{
    NSString *userid = [NSString stringWithFormat:@"%@@a",uid];
    [UDManager savePassword:password];
    [HttpRequest postRequestWithHttpType:HT_Login action:ACTION_NULL params:@[ userid, password, @"i"] Handler:^(NSString *ackString) {
        NSDictionary *ackDic = [HttpAckHandler handleLoginAck:ackString];
        [HttpManager setDicHandler:handler Dictionary:ackDic];
    }];
}

+ (void)changeOldPwd:(NSString *)oldPwd
            toNewPwd:(NSString *)newPwd
             handler:(DicHandler)handler{
    
    [HttpRequest postRequestWithHttpType:HT_User action:UA_CHANGE_PWD params:@[ [UDManager getUserId], oldPwd, newPwd ] Handler:^(NSString *ackString) {
        NSDictionary *ackDic = [HttpAckHandler handleChangPwdAck:ackString];
        [HttpManager setDicHandler:handler Dictionary:ackDic];
    }];
}

+ (void)changeToNewNikename:(NSString *)name
                    handler:(DicHandler)handler{
    
    NSArray *params =@[ [UDManager getUserId], [UDManager getPassword], name ];
    
    [HttpRequest postRequestWithHttpType:HT_User action:UA_Renam params:params Handler:^(NSString *ackString) {
        NSDictionary *ackDic = [HttpAckHandler handleUserRenamAck:ackString];
        [HttpManager setDicHandler:handler Dictionary:ackDic];
    }];
}


+ (void)getUserInfoByUserId:(NSString *)userId
                    Handler:(DicHandler)handler{
    
    NSArray *params =@[userId, [UDManager getPassword], @"i" ];
    
    [HttpRequest postRequestWithHttpType:HT_User action:UA_View params:params Handler:^(NSString *ackString) {
        NSDictionary *ackDic = [HttpAckHandler handleGetUserInfoAck:ackString];
        [HttpManager setDicHandler:handler Dictionary:ackDic];
    }];
}

+ (void)deleteFriendByFriendGroupId:(NSString *)fgid
                            Handler:(DicHandler)handler{
    
    [HttpRequest postRequestWithHttpType:HT_Friend action:FA_Delete params:@[ fgid ] Handler:^(NSString *ackString) {
        NSDictionary *ackDic = [HttpAckHandler handleDeleteFriendAck:ackString];
        [HttpManager setDicHandler:handler Dictionary:ackDic];
    }];

}

+ (void)inviteFriendByFriendId:(NSString *)fuid
                         notes:(NSString *)notes
                       handler:(DicHandler)handler{
    
    [HttpRequest postRequestWithHttpType:HT_Friend action:FA_Invite params:@[ fuid, notes ] Handler:^(NSString *ackString) {
        NSDictionary *ackDic = [HttpAckHandler handleInviteAck:ackString];
        [HttpManager setDicHandler:handler Dictionary:ackDic];
    }];
    
}

+ (void)getFriendListByPage:(int)page
                    Handler:(DicHandler)handler{
    
    NSNumber *pageNum = [NSNumber numberWithInt:page];
    [HttpRequest postRequestWithHttpType:HT_Friend action:FA_PageList params:@[ pageNum ] Handler:^(NSString *ackString) {
        NSDictionary *ackDic = [HttpAckHandler handleGetFriendListByPageAck:ackString];
        [HttpManager setDicHandler:handler Dictionary:ackDic];
    }];
}

+ (void)getAllFriendAndAckHandler:(DicHandler)handler{
    
    [HttpRequest postRequestWithHttpType:HT_Friend action:FA_AllList params:nil Handler:^(NSString *ackString) {
        NSDictionary *ackDic = [HttpAckHandler handleGetAllFriendListAck:ackString];
        [HttpManager setDicHandler:handler Dictionary:ackDic];
    }];
}

+ (void)getGroupListByPage:(int)page
                   handler:(DicHandler)handler{
    
    [HttpRequest postRequestWithHttpType:HT_Group action:GA_List params:@[ [NSNumber numberWithInt:page] ] Handler:^(NSString *ackString) {
        NSDictionary *ackDic = [HttpAckHandler handleGetGroupAck:ackString];
        [HttpManager setDicHandler:handler Dictionary:ackDic];
    }];
}

+ (void)joinGroupTalkByGroupId:(NSString *)groupId
                       Handler:(DicHandler)handler{
    [HttpRequest postRequestWithHttpType:HT_Talk action:TA_Join params:@[ groupId ] Handler:^(NSString *ackString) {
        NSDictionary *ackDic = [HttpAckHandler handleJoinTalkAck:ackString];
        [HttpManager setDicHandler:handler Dictionary:ackDic];
    }];
}

+ (void)quitGroupTalkByGroupId:(NSString *)groupId
                       Handler:(DicHandler)handler{
    
    [HttpRequest postRequestWithHttpType:HT_Talk action:TA_Quit params:@[ groupId ] Handler:^(NSString *ackString) {
        NSDictionary *ackDic = [HttpAckHandler handleQuitTalkAck:ackString];
        [HttpManager setDicHandler:handler Dictionary:ackDic];
    }];
}

+ (void)agreeInvitedForFriendId:(NSString *)fuid
                        Handler:(DicHandler)handler{
    [HttpRequest postRequestWithHttpType:HT_Friend action:FA_Agree params:@[ fuid ] Handler:^(NSString *ackString) {
        NSDictionary *ackDic = [HttpAckHandler handleAgreeInviteAck:ackString];
        [HttpManager setDicHandler:handler Dictionary:ackDic];
    }];
}

+ (void)disagreeInvitedForFriendId:(NSString *)fuid
                             Notes:(NSString *)notes
                           Handler:(DicHandler)handler{
    [HttpRequest postRequestWithHttpType:HT_Friend action:FA_Disagree params:@[ fuid, notes ] Handler:^(NSString *ackString) {
        NSDictionary *ackDic = [HttpAckHandler handleDisagreeInviteAck:ackString];
        [HttpManager setDicHandler:handler Dictionary:ackDic];
    }];
}

+ (void)sendMsgToGroupId:(NSString *)gid
                 message:(NSString *)msg
                 msgType:(int)msgType
               voiceTime:(float)voiceTime
                 handler:(DicHandler)handler{
    
    NSNumber *type = [NSNumber numberWithInt:msgType];
    NSNumber *dur = [NSNumber numberWithFloat:voiceTime];
    
    [HttpRequest postRequestWithHttpType:HT_Msg action:ACTION_NULL params:@[ gid, msg,type, dur] Handler:^(NSString *ackString) {
        NSDictionary *ackDic = [HttpAckHandler handleSendMsgAck:ackString];
        [HttpManager setDicHandler:handler Dictionary:ackDic];
    }];
}

+ (void)getMembersForGroupId:(NSString *)gid
                        page:(int)page
                     handler:(DicHandler)handler{
    
    [HttpRequest postRequestWithHttpType:HT_Member action:MA_List params:@[ gid, [NSNumber numberWithInt:page] ] Handler:^(NSString *ackString) {
        NSDictionary *ackDic = [HttpAckHandler handleGetMemberAck:ackString];
        [HttpManager setDicHandler:handler Dictionary:ackDic];
    }];
}

+ (void)addMembersByUserIds:(NSString *)uids
                  toGroupId:(NSString *)gid
                    handler:(DicHandler)handler{
    [HttpRequest postRequestWithHttpType:HT_Member action:MA_Add params:@[ gid, uids ] Handler:^(NSString *ackString) {
        NSDictionary *ackDic = [HttpAckHandler handleAddMembersAck:ackString];
        [HttpManager setDicHandler:handler Dictionary:ackDic];
    }];
}

+ (void)quitGroupByGroupId:(NSString *)gid
                   handler:(DicHandler)handler{
    
    [HttpRequest postRequestWithHttpType:HT_Member action:MA_Quit params:@[ gid ] Handler:^(NSString *ackString) {
        NSDictionary *ackDic = [HttpAckHandler handleQuitGroupAck:ackString groupId:gid];
        [HttpManager setDicHandler:handler Dictionary:ackDic];
    }];
}

+ (void)createGroupWithGroupName:(NSString *)groupName
                            uids:(NSString *)uids
                         handler:(DicHandler)handler{
    [HttpRequest postRequestWithHttpType:HT_Group action:GA_Create params:@[ groupName, uids ] Handler:^(NSString *ackString) {
        NSDictionary *ackDic = [HttpAckHandler handleCreateGroupaAck:ackString];
        [HttpManager setDicHandler:handler Dictionary:ackDic];
    }];
}

+ (void)changeGroupNameByGroupId:(NSString *)groupId
                            name:(NSString *)name
                         handler:(DicHandler)handler{
    [HttpRequest postRequestWithHttpType:HT_Group action:GA_Rename params:@[ groupId, name ] Handler:^(NSString *ackString) {
        NSDictionary *ackDic = [HttpAckHandler handleGroupRenameAck:ackString];
        [HttpManager setDicHandler:handler Dictionary:ackDic];
    }];
}

+ (void)downloadFileByFileName:(NSString *)fileName
                       handler:(DicHandler)handler{
    
    [HttpRequest downloadFileByFileName:fileName handler:^(NSDictionary *dataDic) {
        [HttpManager setDicHandler:handler Dictionary:dataDic];
    }];
}

+ (void)uploadFileByFilePath:(NSString *)filePath
                     handler:(DicHandler)handler{

    [HttpRequest uploadFileByFilePath:filePath handler:^(NSString *ackString) {
        NSDictionary *ackDic = [HttpAckHandler handleUploadAck:ackString];
        [HttpManager setDicHandler:handler Dictionary:ackDic];
    }];
}
@end
