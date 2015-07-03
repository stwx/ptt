//
//  Member.h
//  PTT
//
//  Created by xihan on 15/7/1.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Letter, UserInfo;

@interface Member : NSManagedObject

@property (nonatomic, retain) NSString * gid;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) UserInfo *info;
@property (nonatomic, retain) Letter *firstLetter;

@end
