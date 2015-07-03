//
//  HttpInfo.m
//  PTT
//
//  Created by xihan on 15/6/3.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import "HttpInfo.h"

//NSString *const HTTP_HEAD = @"http://vnia.v068145.10000net.cn/ptt/";

NSString *const HTTP_HEAD = @"http://hjdv.v082.10000net.cn/ptt/";


NSString *const Device = @"&device=i";

NSString *const USER_ID         =   @"uid";
NSString *const FRIEND_USER_ID  =   @"fuid";
NSString *const GROUP_ID        =   @"gid";
NSString *const FRIEND_GROUP_ID =   @"fgid";

NSString *const PASSWORD        =   @"pwd";
NSString *const SESSION_CODE    =   @"code";

NSString *const ACK_RESULT  =   @"result";
NSString *const ACK_MSG     =   @"message";

NSString *const ACK_TIMEOUT =   @"Timeout";

const int ACTION_NULL = 100;

int PttDicResult(NSDictionary *ackDic){
    return [ackDic[ACK_RESULT] intValue];
}

id  PttDicMsg(NSDictionary *ackDic){
    return ackDic[ACK_MSG];
}