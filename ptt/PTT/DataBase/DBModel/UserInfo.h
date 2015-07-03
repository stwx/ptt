//
//  UserInfo.h
//  PTT
//
//  Created by xihan on 15/7/1.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FriendInfo, Member, MyInfo;

@interface UserInfo : NSManagedObject

@property (nonatomic, retain) NSString * currentGroup;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * device;
@property (nonatomic, retain) NSString * icoPath;
@property (nonatomic, retain) NSNumber * shutup;
@property (nonatomic, retain) NSNumber * sex;
@property (nonatomic, retain) NSNumber * silence;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) Member *member;
@property (nonatomic, retain) FriendInfo *friend;
@property (nonatomic, retain) MyInfo *myInfo;

@end
