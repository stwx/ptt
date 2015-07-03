//
//  PttSNotiHandler.m
//  PTT
//
//  Created by xihan on 15/6/5.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import "PttSNotiHandler.h"
#import "UDManager.h"
#import "DBManager.h"
#import "HttpManager.h"
#import "UpdateManager.h"

@implementation PttSNotiHandler

+ (PttSNotiHandler *)sharePttsNotiHandler{
    static PttSNotiHandler *pttSNotiHandler = nil;
    static dispatch_once_t predocate;
    dispatch_once(&predocate, ^{
        pttSNotiHandler  = [[PttSNotiHandler alloc] init];
    });
    return pttSNotiHandler;
}

+ (void)handleNotiWithDic:(NSDictionary *)dic{
    NSString *type = dic[@"type"];
    PttSNotiHandler *handler = [PttSNotiHandler sharePttsNotiHandler];
    if ( [type isEqualToString:@"receive"] ) {
        [handler handleRecvMsgNoti:dic];
    }
    else if ( [type isEqualToString:@"join"] ){
        [handler handleJoinTalkNoti:dic];
    }
    else if ( [type isEqualToString:@"quit"] ){
        [handler handleQuitTalkNoti:dic];
    }
    else if ( [type isEqualToString:@"addg"] ){
        [handler handleAddToGroupNoti:dic];
    }
    else if ( [type isEqualToString:@"addm"] ){
        [handler handleNewGroupMemberNoti:dic];
    }
    else if ( [type isEqualToString:@"delm"] ){
        [handler handleGroupMemberQuitNoti:dic];
    }
    else if ( [type isEqualToString:@"invite"] ){
        [handler handleInviteNoti:dic];
    }
    else if ( [type isEqualToString:@"agree"] ){
        [handler handleAgreeInviteNoti:dic];
    }
    else if ( [type isEqualToString:@"disagree" ] ){
        [handler handleDisagreeInviteNoti:dic];
    }
    else if ( [type isEqualToString:@"renameg"] ){
        [handler handleRecvGroupRenameNoti:dic];
    }
}

- (void)handleRecvGroupRenameNoti:(NSDictionary *)dic{
  /*
   [ NOTIFY`RecvAppMessage`{"type":"renameg","uid":"15013768446@a","gid":"g403@a","gnm":"丝袜 SM 滴蜡","message":"赖润豪修改了群名称！"} ]
   */
    if ([dic[@"uid"] isEqualToString:[UDManager getUserId]]) {
        return;
    }
    [DBManager saveNewGroupByDic:dic];
    
}

- (void)handleRecvMsgNoti:(NSDictionary *)dic{
   /*
    [ NOTIFY`RecvAppMessage`{"type":"receive","gid":"g281@a","uid":"13424224381@a","name":"韩宇","msgDate":"2015-06-24 16:06:45","msg":"20150624_040711.wav","msgType":"2","voiceTime":"3","message":"发送信息成功！"} ]
    */
    if ([dic[@"uid"] isEqualToString:[UDManager getUserId]]) {
        return;
    }
    
    NSMutableDictionary *dic2 = [NSMutableDictionary dictionaryWithDictionary:dic];
    NSString *name = dic[@"name"];
    if (name == nil || name.length == 0) {
        name = dic[@"uid"];
        NSRange range = [name rangeOfString:@"@"];
        if (NSNotFound != range.location) {
            name = [name substringToIndex:range.location];
        }
        dic2[@"name"] = name;
    }
    
    if ( [dic[@"msgType"] intValue] == 2 ) {
        [HttpManager downloadFileByFileName:dic[@"msg"] handler:^(NSDictionary *dataDic) {
            if (PttDicResult(dataDic) == ACK_OK) {
                
                dic2[@"msg"] = PttDicMsg(dataDic);
                [DBManager saveChatMessageByDic:dic2];
                
                if ([[UDManager getCurrentChatGroup] isEqualToString:dic[@"gid"]]) {
                    [DBManager saveChatConversationByDic:dic2 isUnread:NO];
                }
                else{
                     [DBManager saveChatConversationByDic:dic2 isUnread:YES];
                }
                
//                if ([_delegate respondsToSelector:@selector(PttsNoti_messageByDic:)]) {
//                    [_delegate PttsNoti_messageByDic:dic2];
//                    
//                    
//                }
//                else{
//                   
//                }
            }
        }];
    }
    else{
        [DBManager saveChatMessageByDic:dic2];
        if ([[UDManager getCurrentChatGroup] isEqualToString:dic[@"gid"]]) {
            [DBManager saveChatConversationByDic:dic2 isUnread:NO];
        }
        else{
            [DBManager saveChatConversationByDic:dic2 isUnread:YES];
        }
       
//        if ([_delegate respondsToSelector:@selector(PttsNoti_messageByDic:)]) {
//            [_delegate PttsNoti_messageByDic:dic2];
//            [DBManager saveChatConversationByDic:dic2 isUnread:NO];
//        }
//        else{
//            [DBManager saveChatConversationByDic:dic2 isUnread:YES];
//        }
    }
}

- (void)handleJoinTalkNoti:(NSDictionary *)dic{
    /*
     [ NOTIFY`RecvAppMessage`{"type":"join","gid":"g275@a","uid":"15013555301@a","message":"林加明加入对讲！"} ]
     */
    NSString *uid = dic[@"uid"];
    if ([uid isEqualToString:[UDManager getUserId]]) {
        [UDManager saveTalkState:YES];
        return;
    }
  
    NSString *gid = dic[@"gid"];
    [DBManager saveTalkMessageByDic:dic];
    
    if ([[UDManager getCurrentChatGroup] isEqualToString:gid]) {
        [DBManager saveTalkConversationByDic:dic isUnread:NO];
    }
    else{
        [DBManager saveTalkConversationByDic:dic isUnread:YES];
    }
    
//    if ([_delegate respondsToSelector:@selector(PttsNoti_friendJoinTalkToGroupId:msg:)]) {
//        [_delegate PttsNoti_friendJoinTalkToGroupId:gid msg:dic[@"message"]];
//        [DBManager saveTalkConversationByDic:dic isUnread:NO];
//    }
//    else{
//        [DBManager saveTalkConversationByDic:dic isUnread:YES];
//       
//    }
}

- (void)handleQuitTalkNoti:(NSDictionary *)dic{
    /*
     [ NOTIFY`RecvAppMessage`{"type":"quit","gid":"g275@a","uid":"13760225023@a","message":"退出对讲！"} ]
     */
    [UDManager saveTalkState:NO];
    
    NSString *uid = dic[@"uid"];
    if ([uid isEqualToString:[UDManager getUserId]]) {
        return;
    }
    
    NSString *gid = dic[@"gid"];
    [DBManager saveTalkMessageByDic:dic];
    
    
    if ([[UDManager getCurrentChatGroup] isEqualToString:gid]) {
        [DBManager saveTalkConversationByDic:dic isUnread:NO];
    }
    else{
        [DBManager saveTalkConversationByDic:dic isUnread:YES];
    }
    
//    if ([_delegate respondsToSelector:@selector(PttsNoti_friendQuitTalkFromGroupId:msg:)]) {
//        [_delegate PttsNoti_friendQuitTalkFromGroupId:gid msg:dic[@"message"]];
//        [DBManager saveTalkConversationByDic:dic isUnread:NO];
//    }
//    else{
//        
//        [DBManager saveTalkConversationByDic:dic isUnread:YES];
//        
//    }
}

- (void)handleInviteNoti:(NSDictionary *)dic{

    if ([dic[@"uid"] isEqualToString:[UDManager getUserId]]) {
        return;
    }
    [DBManager saveInviteMeConversationByDic:dic];
    
}

- (void)handleAgreeInviteNoti:(NSDictionary *)dic{
    /*
     [ NOTIFY`RecvAppMessage`{"type":"agree","fgid":"fg106@a","fuid":"15013768446@a","name":"赖润豪","message":"赖润豪同意了您的好友邀请"} ]
     */
    NSString *fuid = dic[@"fuid"];
    if ([fuid isEqualToString:[UDManager getUserId]]) {
        return;
    }
//    NSString *fgid = dic[@"fgid"];
    
    [DBManager saveNewFriendByDic:dic];
    [DBManager saveAgreeInvitedConversationByDic:dic];
    
//    if ([_delegate respondsToSelector:@selector(PttsNoti_agreeForUserId:fgid:)]) {
//        [_delegate PttsNoti_agreeForUserId:fuid fgid:fgid];
//    }
}

- (void)handleDisagreeInviteNoti:(NSDictionary *)dic{
    NSString *uid = dic[@"uid"];
    NSString *name = dic[@"name"];
    NSString *note = dic[@"notes"];
    
    /*
     [ NOTIFY`RecvAppMessage`{"type":"disagree","uid":"15013768446@a","name":"赖润豪","notes":" ","message":"赖润豪拒绝了您的邀请！"} ]
     */
    NSMutableDictionary *dic1 = [NSMutableDictionary dictionaryWithDictionary:dic];
    dic1[@"state"] = @1;
    
    [DBManager saveInviteOtherConversationByDic:dic1];
    if ([_delegate respondsToSelector:@selector(PttsNoti_disagreeForUserId:name:note:)]) {
        [_delegate PttsNoti_disagreeForUserId:uid name:name note:note];
    }
}

- (void)handleAddToGroupNoti:(NSDictionary *)dic{
    /*
     [ NOTIFY`RecvAppMessage`{"type":"addg","gid":"g302@a","gnm":"奋斗","uid":"15013555301@a","name":"林加明","uids":"15013768446@a;","message":"林加明邀请您加入奋斗"} ]
     */
    NSString *uid = dic[@"uid"];
    if ([uid isEqualToString:[UDManager getUserId]]) {
        return;
    }
    if ([DBManager isGroupExistedByGid:dic[@"gid"]]) {
        return;
    }

    [DBManager saveNewGroupByDic:dic];
    [DBManager saveJoinGroupConversationByDic:dic];
}

- (void)handleNewGroupMemberNoti:(NSDictionary *)dic{

    /*
     [ NOTIFY`RecvAppMessage`{"type":"addm","gid":"g478@a","gnm":"测试成员","uid":"15999518574@a","name":"贺美龙","uids":"15999518575@a;15914171994@a;15013555301@a;","message":"贺美龙邀请贺美龙5;兰团保;林加明加入测试成员"} ]
     */
    NSString *gid = dic[@"gid"];
    [UpdateManager updateMemberListByGroupId:gid];
    [DBManager saveNewMemberMessageByDic:dic];
    
    if ([[UDManager getCurrentChatGroup] isEqualToString:gid]) {
        [DBManager saveNewMemberConversationByDic:dic unread:NO];
    }
    else{
       [DBManager saveNewMemberConversationByDic:dic unread:YES];
    }
}

- (void)handleGroupMemberQuitNoti:(NSDictionary *)dic{
    /*
     [ NOTIFY`RecvAppMessage`{"type":"delm","gid":"g275@a","uid":"15013555301@a","message":"林加明退出西汉测试"} ]
     
     */
    NSString *uid = dic[@"uid"];
    NSString *gid = dic[@"gid"];
    if ([uid isEqualToString:[UDManager getUserId]]) {
        return;
    }
    [DBManager deleteMemberByUid:uid inGroup:gid];
    [DBManager saveMemberQuitConversationByDic:dic unread:YES];
    
    
    if ([_delegate respondsToSelector:@selector(PttSNoti_groupMemberQuit:groupId:)]) {
        [_delegate PttSNoti_groupMemberQuit:uid groupId:gid];
    }
}

@end
