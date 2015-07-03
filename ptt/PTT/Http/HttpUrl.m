//
//  HttpUrlString.m
//  PTT
//
//  Created by xihan on 15/6/3.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import "HttpUrl.h"
#import "UDManager.h"


NSString *const SESSION_CODE_STRING = @"session";

@implementation HttpUrl{
@private
    NSArray *_key, *_params;
    NSString *_httpType, *_httpAction;
    BOOL _ADD_SESSION;
}

+ (NSString *)httpUrlStringWithHttpType:(HttpType)httpTpye
                                 action:(int) action
                                 params:(NSArray *)params{
    HttpUrl *httpUrl = [[HttpUrl alloc] init];
    [httpUrl setParams:params];
    
    switch (httpTpye) {
        case HT_Friend:
            [httpUrl handleFriendType:action];
            break;
        case HT_Group:
            [httpUrl handleGroupType:action];
            break;
        case HT_Member:
            [httpUrl handleMemberType:action];
            break;
        case HT_Msg:
            [httpUrl handleMsgType];
            break;
        case HT_Talk:
            [httpUrl handleTalkType:action];
            break;
        case HT_User:
            [httpUrl handleUserType:action];
            break;
        case HT_Login:
            [httpUrl handleLoginType];
            break;
        case HT_Reg:
            [httpUrl handleRegType];
            break;
        default:
            
            break;
    }
    return [httpUrl formUrlString];
}

- (void)setParams:(NSArray *)params{
    _params = params;
}


#pragma mark ----------------- Reg -------------------------
- (void)handleRegType{
    _httpType = @"Reg?";
    _key = @[ USER_ID, PASSWORD, @"device" ];
}

#pragma mark ---------------- Login ------------------------
- (void)handleLoginType{
    _httpType = @"Login?";
    _key = @[ USER_ID, PASSWORD, @"device" ];
}

#pragma mark ---------------- User ------------------------
- (void)handleUserType:(User_Action)action{
    _httpType = @"User?";
    switch (action) {
        case UA_CHANGE_PWD:
        {
            _httpAction = @"rename";
            _key = @[ USER_ID, PASSWORD, @"newPassword" ];
        }
            break;
        case UA_Renam:
        {
            _httpAction = @"rename";
            _key = @[ USER_ID, PASSWORD, @"name" ];
        }
            break;
        case UA_View:
        {
            _httpAction = @"view";
            _key = @[ USER_ID, SESSION_CODE, @"device" ];
        }
            break;
        default:
            break;
    }
}

#pragma mark ---------------- Friend ------------------------
- (void)handleFriendType:(Friend_Action)action{
    _httpType = @"Friend?";
    _ADD_SESSION = YES;
    switch (action) {
        case FA_AllList:
        {
            _httpAction = @"list";
        }
            break;
        case FA_PageList:
        {
            _httpAction = @"list";
            _key = @[ @"page" ];
        }
            break;
        case FA_Agree:
        {
            _httpAction = @"agree";
            _key = @[ FRIEND_USER_ID];
        }
            break;
        case FA_Invite:
        {
            _httpAction = @"invite";
            _key = @[ FRIEND_USER_ID, @"notes" ];
        }
            break;
        case FA_Delete:
        {
            _httpAction = @"del";
            _key = @[ FRIEND_GROUP_ID ];
        }
            break;
        case FA_Disagree:
        {
            _httpAction = @"disagree";
            _key = @[ FRIEND_USER_ID, @"notes" ];
        }
            
            break;
        default:
            break;
    }
}
#pragma mark ---------------- Group ------------------------
- (void)handleGroupType:(Group_Action)action{
    
    _httpType = @"Group?";
    _ADD_SESSION = YES;
    
    switch (action) {
        case GA_List:
        {
            _httpAction = @"list";
            _key = @[ @"page" ];
        }
            break;
        case GA_Create:
        {
            _httpAction = @"add";
            _key = @[ @"name", @"uids" ];
        }
            break;
        case GA_Rename:
        {
            _httpAction = @"rename";
            _key = @[ GROUP_ID, @"name" ];
        }
            break;
        default:
            break;
    }
}

#pragma mark ---------------- Member ------------------------
- (void)handleMemberType:(Member_Action)action{
    
    _httpType = @"Member?";
    _ADD_SESSION = YES;
    switch (action) {
        case MA_List:
        {
            _httpAction = @"list";
            _key = @[ GROUP_ID, @"page" ];
        }
            break;
        case MA_Add:
        {
            _httpAction = @"add";
            _key = @[ GROUP_ID, @"uids" ];
        }
            break;
        case MA_Quit:
        {
            _httpAction = @"del";
            _key = @[ GROUP_ID ];
        }
            break;
        default:
            break;
    }
}

#pragma mark ------------------ MSG--------------------------
- (void)handleMsgType{
    _ADD_SESSION = YES;
    _httpType = @"SendMsg?";
    _key = @[ GROUP_ID, @"msg", @"msgType", @"voiceTime"];
}

#pragma mark ------------------ Talk--------------------------
- (void)handleTalkType:(Talk_Action)action{
    _httpType = @"Talk?";
    _ADD_SESSION = YES;
    
    switch (action) {
        case TA_Join:
            _httpAction = @"join";
            _key = @[ GROUP_ID ];
            break;
        case TA_Quit:
            _httpAction = @"quit";
            _key = @[ GROUP_ID ];
            break;
        default:
            break;
    }
}

#pragma mark -------------- Form Url String-------------------------

- (NSString *)codeString{
    NSString *codeString;
    if (_httpAction == nil) {
        codeString = [NSString stringWithFormat:@"%@=%@&%@=%@%@",USER_ID, [UDManager getUserId], SESSION_CODE, [UDManager getCode], Device];
    }else{
        codeString = [NSString stringWithFormat:@"&%@=%@&%@=%@%@",USER_ID, [UDManager getUserId], SESSION_CODE, [UDManager getCode], Device];
    }
    
    return codeString;
}

- (NSString *)formUrlString{
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@",HTTP_HEAD, _httpType];
    
    if (_httpAction != nil) {
        [urlString appendFormat:@"action=%@",_httpAction];
    }
    if (_ADD_SESSION) {
        [urlString appendString:[self codeString]];
    }
    if ( _key != nil || _key.count > 0) {
        [_key enumerateObjectsUsingBlock:^(NSString* obj, NSUInteger idx, BOOL *stop) {
            if ( idx == 0 && _httpAction == nil &&!_ADD_SESSION) {
                [urlString appendFormat:@"%@=%@",obj,_params[idx]];
            }else{
                [urlString appendFormat:@"&%@=%@",obj,_params[idx]];
            }
        }];
    }
    NSLog(@"%@",urlString);
    return urlString;
}




@end
