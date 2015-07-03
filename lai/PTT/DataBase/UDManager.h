//
//  UDManager.h
//  PTT
//
//  Created by xihan on 15/5/27.
//  Copyright (c) 2015年 STWX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UDManager : NSObject

+ (void)saveUserId:(NSString *)userId;
+ (void)savePassword:(NSString *)pwd;
+ (void)saveCode:(NSString *)code;
+ (void)saveUserName:(NSString *)userName;
+ (void)saveCurrentGroup:(NSString *)gid;
+ (void)saveTalkState:(BOOL)talking;
+ (void)saveListenState:(BOOL)listening;
+ (void)saveCurrentChatGroup:(NSString *)gid;


+ (NSString *)getUserId;
+ (NSString *)getPassword;
+ (NSString *)getCode;
+ (NSString *)getUserName;
+ (NSString *)getCurrentGroup;
+ (NSString *)getCurrentChatGroup;
+ (BOOL)isTalking;
+ (BOOL)isListening;

+ (void)deleteUserInfo;
+ (void)deleteCach;
@end
