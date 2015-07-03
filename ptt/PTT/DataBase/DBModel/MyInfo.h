//
//  MyInfo.h
//  PTT
//
//  Created by xihan on 15/7/1.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class UserInfo;

@interface MyInfo : NSManagedObject

@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSString * pwd;
@property (nonatomic, retain) UserInfo *info;

@end
