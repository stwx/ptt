//
//  HttpAckHandler.m
//  PTT
//
//  Created by xihan on 15/6/3.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import "HttpAckHandler.h"
#import "HttpInfo.h"
#import "NSString+Extension.h"
#import "UDManager.h"
#import "DBManager.h"
#import "PttService.h"
#import "UpdateManager.h"

NSString *const Ack_Fail    =   @"0";
NSString *const Ack_Ok      =   @"1";
NSString *const Ack_Empty   =   @"2";

const int ACK_CODE_OK = 0;

NSString *const ACK_CODE    =   @"code";


#pragma mark --------------------- ACK -----------------------

NSDictionary *AckFormatErrorDic(NSString *ackString){
    return @{ ACK_RESULT : Ack_Fail, ACK_MSG : ackString };
}

NSDictionary *AckEmptyDic(){
    return @{ ACK_RESULT : Ack_Empty };
}

NSDictionary *AckFailDic(NSDictionary *ackDic){
    return @{
                ACK_RESULT : Ack_Fail,
                  ACK_CODE : ackDic[@"isSucceed"],
                   ACK_MSG : ackDic[ACK_MSG]
              };
}


NSDictionary *AckTimeoutDic(){
    return @{ ACK_RESULT : Ack_Fail, ACK_MSG:@"连接服务器超时" };
}

int GetAckCode(NSDictionary *ackDic){
    return [ackDic[@"isSucceed"] intValue];
}

#pragma mark ------------------- HttpAckHandler -----------------------

@implementation HttpAckHandler

+ (NSDictionary *)handleRegAck:(NSString *)ackString{
    if ([ackString isEqualToString:ACK_TIMEOUT]) {
        return AckTimeoutDic();
    }
    NSDictionary *dataDic = [ackString jsonToDictionary];
    if ( dataDic == nil ) {
        return AckFormatErrorDic(ackString);
    }
    if ( GetAckCode(dataDic) != 0 ) {
        return AckFailDic(dataDic);
    }
    [UDManager saveUserId:dataDic[@"uid"]];
    [UDManager savePassword:dataDic[@"pwd"]];
    return @{ ACK_RESULT : Ack_Ok, ACK_MSG: PttDicMsg(dataDic) };
}

+ (NSDictionary *)handleLoginAck:(NSString *)ackString{
    if ([ackString isEqualToString:ACK_TIMEOUT]) {
        return AckTimeoutDic();
    }
    DLog(@"%@",ackString);
    NSDictionary *dataDic = [ackString jsonToDictionary];
    if ( dataDic == nil ) {
        [UDManager deleteUserInfo];
        return AckFormatErrorDic(ackString);
    }
    if ( GetAckCode(dataDic) != 0 ) {
        [UDManager deleteUserInfo];
        return AckFailDic(dataDic);
    }
    
    [UDManager saveUserId:dataDic[USER_ID]];
    [UDManager saveCode:dataDic[SESSION_CODE]];
    [UDManager saveUserName:dataDic[@"name"]];
    
    NSString *uid = dataDic[USER_ID];
    NSString *pwd = [UDManager getPassword];
    
    [[PttService sharedInstance] PTT_Login:[uid stringToChar] password:[pwd stringToChar]];
    
    return @{ ACK_RESULT : Ack_Ok };
}

+ (NSDictionary *)handleChangPwdAck:(NSString *)ackString{
    if ([ackString isEqualToString:ACK_TIMEOUT]) {
        return AckTimeoutDic();
    }
    NSDictionary *dataDic = [ackString jsonToDictionary];
     DLog(@"\n================\n%@\n=============\n",ackString);
    if ( dataDic == nil ) {
        return AckFormatErrorDic(ackString);
    }
    if ( GetAckCode(dataDic) != 0 ) {
        return AckFailDic(dataDic);
    }
    return @{ ACK_RESULT : Ack_Ok };
}

+ (NSDictionary *)handleUserRenamAck:(NSString *)ackString{
    if ([ackString isEqualToString:ACK_TIMEOUT]) {
        return AckTimeoutDic();
    }
    NSDictionary *dataDic = [ackString jsonToDictionary];
    if ( dataDic == nil ) {
        return AckFormatErrorDic(ackString);
    }
    if ( GetAckCode(dataDic) != 0 ) {
        return AckFailDic(dataDic);
    }
    return @{ ACK_RESULT : Ack_Ok };
}

+ (NSDictionary *)handleGetUserInfoAck:(NSString *)ackString{
    if ([ackString isEqualToString:ACK_TIMEOUT]) {
        return AckTimeoutDic();
    }
    NSDictionary *dataDic = [ackString jsonToDictionary];
    if ( dataDic == nil ) {
        return AckFormatErrorDic(ackString);
    }
    if ( GetAckCode(dataDic) != 0 ) {
        return AckFailDic(dataDic);
    }
    return @{ ACK_RESULT : Ack_Ok , ACK_MSG : dataDic[@"user"]};
}

+ (NSDictionary *)handleInviteAck:(NSString *)ackString{
    
    if ([ackString isEqualToString:ACK_TIMEOUT]) {
        return AckTimeoutDic();
    }
    DLog(@"\n================\n%@\n=============\n",ackString);
    NSDictionary *dataDic = [ackString jsonToDictionary];
    if ( dataDic == nil ) {
        return AckFormatErrorDic(ackString);
    }
    if ( GetAckCode(dataDic) != 0 ) {
        return AckFailDic(dataDic);
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:dataDic];
    dic[@"state"] = @0;
    return @{ ACK_RESULT : Ack_Ok, ACK_MSG : dic };
}

+ (NSDictionary *)handleAgreeInviteAck:(NSString *)ackString{
    
    if ([ackString isEqualToString:ACK_TIMEOUT]) {
        return AckTimeoutDic();
    }
    NSDictionary *dataDic = [ackString jsonToDictionary];
    DLog(@"\n================\n%@\n=============\n",dataDic);
    if ( dataDic == nil ) {
        return AckFormatErrorDic(ackString);
    }
    if ( GetAckCode(dataDic) != 0 ) {
        return AckFailDic(dataDic);
    }
    return @{ ACK_RESULT : Ack_Ok, ACK_MSG : dataDic };
}

+ (NSDictionary *)handleDisagreeInviteAck:(NSString *)ackString{
    if ([ackString isEqualToString:ACK_TIMEOUT]) {
        return AckTimeoutDic();
    }
    NSDictionary *dataDic = [ackString jsonToDictionary];
    if ( dataDic == nil ) {
        return AckFormatErrorDic(ackString);
    }
    if ( GetAckCode(dataDic) != 0 ) {
        return AckFailDic(dataDic);
    }
    return @{ ACK_RESULT : Ack_Ok };
}

+ (NSDictionary *)handleDeleteFriendAck:(NSString *)ackString{
    if ([ackString isEqualToString:ACK_TIMEOUT]) {
        return AckTimeoutDic();
    }
    NSDictionary *dataDic = [ackString jsonToDictionary];
    if ( dataDic == nil ) {
        return AckFormatErrorDic(ackString);
    }
    if ( GetAckCode(dataDic) != 0 ) {
        return AckFailDic(dataDic);
    }
    return @{ ACK_RESULT : Ack_Ok };
}

+ (NSDictionary *)handleGetFriendListByPageAck:(NSString *)ackString{
    DLog(@"%@",ackString);
    if ([ackString isEqualToString:ACK_TIMEOUT]) {
        return AckTimeoutDic();
    }
    NSDictionary *dataDic = [ackString jsonToDictionary];
    if ( dataDic == nil ) {
        return AckFormatErrorDic(ackString);
    }
    if ( GetAckCode(dataDic) != 0 ) {
        return AckFailDic(dataDic);
    }
    return @{ ACK_RESULT : Ack_Ok , ACK_MSG : dataDic };
}

+ (NSDictionary *)handleGetAllFriendListAck:(NSString *)ackString{
    if ([ackString isEqualToString:ACK_TIMEOUT]) {
        return AckTimeoutDic();
    }
    NSDictionary *dataDic = [ackString jsonToDictionary];
   // DLog(@"\n================\n%@\n=============\n",dataDic);
    if ( dataDic == nil ) {
        return AckFormatErrorDic(ackString);
    }
    if ( GetAckCode(dataDic) != 0 ) {
        return AckFailDic(dataDic);
    }
    [DBManager deleteAllFriends];
    [DBManager saveFriendListByDicArray:dataDic[@"users"]];
    return @{ ACK_RESULT : Ack_Ok };
}

+ (NSDictionary *)handleGetGroupAck:(NSString *)ackString{
    if ([ackString isEqualToString:ACK_TIMEOUT]) {
        return AckTimeoutDic();
    }
    DLog(@"%@",ackString);
    NSDictionary *dataDic = [ackString jsonToDictionary];
    if ( dataDic == nil ) {
        return AckFormatErrorDic(ackString);
    }
    if ( GetAckCode(dataDic) != 0 ) {
        return AckFailDic(dataDic);
    }
    return @{ ACK_RESULT: Ack_Ok, ACK_MSG:dataDic };
}

+ (NSDictionary *)handleJoinTalkAck:(NSString *)ackString{
    if ([ackString isEqualToString:ACK_TIMEOUT]) {
        return AckTimeoutDic();
    }
    NSDictionary *dataDic = [ackString jsonToDictionary];
    if ( dataDic == nil ) {
        return AckFormatErrorDic(ackString);
    }
    if ( GetAckCode(dataDic) != 0 ) {
        return AckFailDic(dataDic);
    }
     return @{ ACK_RESULT: Ack_Ok };
}

+ (NSDictionary *)handleQuitTalkAck:(NSString *)ackString{
    if ([ackString isEqualToString:ACK_TIMEOUT]) {
        return AckTimeoutDic();
    }
    NSDictionary *dataDic = [ackString jsonToDictionary];
    if ( dataDic == nil ) {
        return AckFormatErrorDic(ackString);
    }
    if ( GetAckCode(dataDic) != 0 ) {
        return AckFailDic(dataDic);
    }
    [UDManager saveTalkState:NO];
    return @{ ACK_RESULT: Ack_Ok };
}

+ (NSDictionary *)handleSendMsgAck:(NSString *)ackString{
    DLog(@"%@",ackString);
    if ([ackString isEqualToString:ACK_TIMEOUT]) {
        return AckTimeoutDic();
    }
    NSDictionary *dataDic = [ackString jsonToDictionary];
    if ( dataDic == nil ) {
        return AckFormatErrorDic(ackString);
    }
    if ( GetAckCode(dataDic) != 0 ) {
        return AckFailDic(dataDic);
    }
    return @{ ACK_RESULT: Ack_Ok };
}

+ (NSDictionary *)handleGetMemberAck:(NSString *)ackString{
    DLog(@"%@",ackString);
    if ([ackString isEqualToString:ACK_TIMEOUT]) {
        return AckTimeoutDic();
    }
    NSDictionary *dataDic = [ackString jsonToDictionary];
   // DLog(@"\n================\n%@\n=============\n",dataDic);
    if ( dataDic == nil ) {
        return AckFormatErrorDic(ackString);
    }
    if ( GetAckCode(dataDic) != 0 ) {
        return AckFailDic(dataDic);
    }
    return @{ ACK_RESULT: Ack_Ok, ACK_MSG:dataDic };
}

+ (NSDictionary *)handleAddMembersAck:(NSString *)ackString{
    if ([ackString isEqualToString:ACK_TIMEOUT]) {
        return AckTimeoutDic();
    }
    NSDictionary *dataDic = [ackString jsonToDictionary];
    if ( dataDic == nil ) {
        return AckFormatErrorDic(ackString);
    }
    if ( GetAckCode(dataDic) != 0 ) {
        return AckFailDic(dataDic);
    }
    [UpdateManager updateMemberListByGroupId:dataDic[@"gid"]];
    return @{ ACK_RESULT: Ack_Ok };
}

+ (NSDictionary *)handleQuitGroupAck:(NSString *)ackString
                             groupId:(NSString *)gid{
    if ([ackString isEqualToString:ACK_TIMEOUT]) {
        return AckTimeoutDic();
    }
    DLog(@"%@",ackString);
    NSDictionary *dataDic = [ackString jsonToDictionary];
    if ( dataDic == nil ) {
        return AckFormatErrorDic(ackString);
    }
    if ( GetAckCode(dataDic) != 0 ) {
        return AckFailDic(dataDic);
    }
   // [DBManager deleteGroupByGroupId:gid];
   // [DBManager deleteMembersByGroupId:gid];
    return @{ ACK_RESULT: Ack_Ok };
}

+ (NSDictionary *)handleCreateGroupaAck:(NSString *)ackString{
    if ([ackString isEqualToString:ACK_TIMEOUT]) {
        return AckTimeoutDic();
    }
    NSDictionary *dataDic = [ackString jsonToDictionary];
    if ( dataDic == nil ) {
        return AckFormatErrorDic(ackString);
    }
    if ( GetAckCode(dataDic) != 0 ) {
        return AckFailDic(dataDic);
    }
    //[UpdateManager updateGroupList];
    return @{ ACK_RESULT: Ack_Ok, ACK_MSG:dataDic };
}

+ (NSDictionary *)handleGroupRenameAck:(NSString *)ackString{
    if ([ackString isEqualToString:ACK_TIMEOUT]) {
        return AckTimeoutDic();
    }
    NSDictionary *dataDic = [ackString jsonToDictionary];
    if ( dataDic == nil ) {
        return AckFormatErrorDic(ackString);
    }
    if ( GetAckCode(dataDic) != 0 ) {
        return AckFailDic(dataDic);
    }
    return @{ ACK_RESULT: Ack_Ok };
}

+ (NSDictionary *)handleUploadAck:(NSString *)ackString{
    if ([ackString isEqualToString:ACK_TIMEOUT]) {
        return AckTimeoutDic();
    }
    DLog(@"%@",ackString);
    NSDictionary *dataDic = [ackString jsonToDictionary];
    if ( dataDic == nil ) {
        return AckFormatErrorDic(ackString);
    }
    if ( GetAckCode(dataDic) != 0 ) {
        return AckFailDic(dataDic);
    }
    return @{ ACK_RESULT : Ack_Ok };
}

@end
