//
//  HttpInfo.h
//  PTT
//
//  Created by xihan on 15/6/3.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import <Foundation/Foundation.h>

extern const int ACTION_NULL;

typedef void(^AckHandler)(NSString *ackString);
typedef void(^DicHandler)(NSDictionary *dataDic);

typedef enum{
    HT_Reg,
    HT_Login,
    HT_User,
    HT_Friend,
    HT_Group,
    HT_Member,
    HT_Talk,
    HT_Msg
}HttpType;

typedef enum {
    UA_Renam,
    UA_CHANGE_PWD,
    UA_View,
}User_Action;

typedef enum {
    FA_Invite,
    FA_Agree,
    FA_Disagree,
    FA_Delete,
    FA_PageList,
    FA_AllList
}Friend_Action;

typedef enum {
    GA_Create,
    GA_AddMembers,
    GA_List,
    GA_Rename
}Group_Action;


typedef enum {
    MA_Add,
    MA_List,
    MA_Quit
}Member_Action;

typedef enum {
    TA_Join,
    TA_Quit
}Talk_Action;

typedef enum{
    ACK_FAIL,
    ACK_OK,
    ACK_EMPTY
}ACK_RESULT_TYP;


extern NSString *const HTTP_HEAD;
extern NSString *const Device;

extern NSString *const USER_ID;
extern NSString *const FRIEND_USER_ID;
extern NSString *const GROUP_ID;
extern NSString *const FRIEND_GROUP_ID;

extern NSString *const PASSWORD;
extern NSString *const SESSION_CODE;

extern NSString *const ACK_RESULT;
extern NSString *const ACK_MSG;

extern NSString *const ACK_TIMEOUT;















