//
//  UDManager.m
//  PTT
//
//  Created by xihan on 15/5/27.
//  Copyright (c) 2015年 STWX. All rights reserved.
//

#import "UDManager.h"


@implementation UDManager

+ (void)saveUserId:(NSString *)userId{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [[NSUserDefaults standardUserDefaults] setObject:userId forKey:@"uid"];
    [defaults synchronize];
}

+ (void)savePassword:(NSString *)pwd{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [[NSUserDefaults standardUserDefaults] setObject:pwd forKey:@"pwd"];
    [defaults synchronize];
}

+ (void)saveCode:(NSString *)code{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [[NSUserDefaults standardUserDefaults] setObject:code forKey:@"code"];
    [defaults synchronize];
}

+ (void)saveUserName:(NSString *)userName{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [[NSUserDefaults standardUserDefaults] setObject:userName forKey:@"unm"];
    [defaults synchronize];
}

+ (void)saveCurrentGroup:(NSString *)gid{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [[NSUserDefaults standardUserDefaults] setObject:gid forKey:@"cur"];
    [defaults synchronize];
}

+ (void)saveCurrentChatGroup:(NSString *)gid{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [[NSUserDefaults standardUserDefaults] setObject:gid forKey:@"chat"];
    [defaults synchronize];
}

+ (void)saveTalkState:(BOOL)talking{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:talking] forKey:@"talkState"];
    [defaults synchronize];
}

+ (void)saveListenState:(BOOL)listening{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:listening] forKey:@"listenState"];
    [defaults synchronize];
}

+ (BOOL)isListening{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"listenState"] boolValue];
}

+ (NSString *)getUserId{
   return (NSString *) [[NSUserDefaults standardUserDefaults] objectForKey:@"uid"];
}

+ (NSString *)getPassword{
     return (NSString *) [[NSUserDefaults standardUserDefaults] objectForKey:@"pwd"];
}

+ (NSString *)getCode{
     return (NSString *) [[NSUserDefaults standardUserDefaults] objectForKey:@"code"];
}

+ (NSString *)getUserName{
    return (NSString *) [[NSUserDefaults standardUserDefaults] objectForKey:@"unm"];
}

+ (NSString *)getCurrentGroup{
    return (NSString *) [[NSUserDefaults standardUserDefaults] objectForKey:@"cur"];
}

+ (NSString *)getCurrentChatGroup{
    return (NSString *) [[NSUserDefaults standardUserDefaults] objectForKey:@"chat"];
}

+ (BOOL)isTalking{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"talkState"] boolValue];
}

+ (void)deleteCach{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"code"];
    [defaults removeObjectForKey:@"unm"];
    [defaults removeObjectForKey:@"chat"];
    [defaults removeObjectForKey:@"cur"];
    [defaults removeObjectForKey:@"talkState"];
    [defaults removeObjectForKey:@"listenState"];
    [defaults synchronize];
}

+ (void)deleteUserInfo{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"uid"];
    [defaults removeObjectForKey:@"pwd"];
    [defaults removeObjectForKey:@"code"];
    [defaults removeObjectForKey:@"unm"];
    [defaults removeObjectForKey:@"chat"];
    [defaults removeObjectForKey:@"cur"];
    [defaults removeObjectForKey:@"talkState"];
    [defaults removeObjectForKey:@"listenState"];
}
@end
