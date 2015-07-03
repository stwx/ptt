//
//  UpdateManager.h
//  PTT
//
//  Created by xihan on 15/6/25.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UpdateManager : NSObject

+ (void)updateFriendList;
+ (void)updateGroupList;
+ (void)updateMemberListByGroupId:(NSString *)gid;

+ (void)updateAllMember;

@end
