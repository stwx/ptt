//
//  FriendInfo.h
//  PTT
//
//  Created by xihan on 15/7/1.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Letter, UserInfo;

@interface FriendInfo : NSManagedObject

@property (nonatomic, retain) NSString * fgid;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) Letter *firstLetter;
@property (nonatomic, retain) UserInfo *info;

@end
