//
//  Letter.h
//  PTT
//
//  Created by xihan on 15/7/1.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FriendInfo, Group, Member;

@interface Letter : NSManagedObject

@property (nonatomic, retain) NSString * letter;
@property (nonatomic, retain) NSSet *friendInfo;
@property (nonatomic, retain) NSSet *group;
@property (nonatomic, retain) NSSet *member;
@end

@interface Letter (CoreDataGeneratedAccessors)

- (void)addFriendInfoObject:(FriendInfo *)value;
- (void)removeFriendInfoObject:(FriendInfo *)value;
- (void)addFriendInfo:(NSSet *)values;
- (void)removeFriendInfo:(NSSet *)values;

- (void)addGroupObject:(Group *)value;
- (void)removeGroupObject:(Group *)value;
- (void)addGroup:(NSSet *)values;
- (void)removeGroup:(NSSet *)values;

- (void)addMemberObject:(Member *)value;
- (void)removeMemberObject:(Member *)value;
- (void)addMember:(NSSet *)values;
- (void)removeMember:(NSSet *)values;

@end
