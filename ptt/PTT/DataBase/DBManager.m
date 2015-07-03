//
//  DBManager.m
//  PTT
//
//  Created by xihan on 15/6/30.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import "DBManager.h"
#import "AppDelegate.h"
#import "UDManager.h"

#import "NSString+Extension.h"
#import "NSDate+Extension.h"

#import "FriendInfo.h"
#import "Group.h"
#import "Member.h"
#import "Message.h"
#import "Conversation.h"
#import "UserInfo.h"
#import "Letter.h"

@implementation DBManager

+ (BOOL)idIsGroupId:(NSString *)idStr{
    if ([[idStr substringToIndex:1] isEqualToString:@"g"]) {
        return YES;
    }
    return NO;
}

#pragma mark ----------- UserInfo --------------
+ (UserInfo *)userInfoByDic:(NSDictionary *)dic
               isFriendInfo:(BOOL)friend
                  inContext:(NSManagedObjectContext *)context{
    
    UserInfo *userInfo = [NSEntityDescription insertNewObjectForEntityForName:@"UserInfo" inManagedObjectContext:context];
    userInfo.shutup = [NSNumber numberWithBool:[dic[@"shutup"] boolValue]];
    userInfo.silence = [NSNumber numberWithBool:[dic[@"silence"] boolValue]];
    userInfo.status = [NSNumber numberWithInt:[dic[@"status"] intValue]];
    userInfo.currentGroup = dic[@"currentGroup"];

    NSString *name = dic[@"name"];
    if ([name isNull]) {
        name = friend ? dic[@"fuid"] : dic[@"uid"];
        NSRange range = [name rangeOfString:@"@"];
        if (NSNotFound != range.location) {
            name = [name substringToIndex:range.location];
        }
    }
    
    userInfo.name = name;
    return userInfo;
}

#pragma mark ----------- FirstLetter -------------
+ (Letter *)getOrCreateLetterIfNeedByLetter:(NSString *)firstLetter
                                        inContext:(NSManagedObjectContext *)context{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Letter"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"letter == %@",firstLetter];
    request.predicate = predicate;
    NSError *error;
    NSArray *array = [context executeFetchRequest:request error:&error];
    if (array.count == 0 || array == nil) {
        Letter *letter = [NSEntityDescription insertNewObjectForEntityForName:@"Letter" inManagedObjectContext:context];
        letter.letter = firstLetter;
        return letter;
    }else{
        return (Letter *)array[0];
    }
}


#pragma mark ----------- Friend -------------

+ (FriendInfo *)getOrCreateFriendIfNeedByUid:(NSString *)uid
                                   inContext:(NSManagedObjectContext *)context{
    FriendInfo * friend = [DBManager searchFriendByUid:uid inContext:context];
    if (friend == nil) {
        friend = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:context];
    }
    return friend;
}

+ (void)saveFriendInfo:(FriendInfo *)friend
               dataDic:(NSDictionary *)dic
             inContext:(NSManagedObjectContext *)context{
    
    friend.fgid = dic[@"fgid"];
    friend.uid = dic[@"fuid"];
    
    UserInfo *userInfo = [DBManager userInfoByDic:dic isFriendInfo:YES inContext:context];
    friend.info = userInfo;
    userInfo.friend = friend;
    
    NSString *letter = [userInfo.name firstLetter];
    Letter *firstLetter = [DBManager getOrCreateLetterIfNeedByLetter:letter inContext:context];
    friend.firstLetter = firstLetter;
    [firstLetter addFriendInfoObject:friend];
}

+ (FriendInfo *)searchFriendByUid:(NSString *)uid
                        inContext:(NSManagedObjectContext *)context{

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"FriendInfo"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == %@",uid];
    request.predicate = predicate;
    NSError *error;
    NSArray *array = [context executeFetchRequest:request error:&error];
    if (error) {
        DLog(@"Error Happend When SearchFriend : %@",error.localizedDescription);
        return nil;
    }
    if (array.count == 0 || array == nil) {
        return nil;
    }else{
        return (FriendInfo *)array[0];
    }
}

+ (FriendInfo *)searchFriendByGroupId:(NSString *)gid
                            inContext:(NSManagedObjectContext *)context{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"FriendInfo"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fgid == %@",gid];
    request.predicate = predicate;
    NSError *error;
    NSArray *array = [context executeFetchRequest:request error:&error];
    if (error) {
        DLog(@"Error Happend When SearchFriend : %@",error.localizedDescription);
        return nil;
    }
    if (array.count == 0 || array == nil) {
        return nil;
    }else{
        return (FriendInfo *)array[0];
    }
}

+ (BOOL)isFriendExistedByUid:(NSString *)uid{
    AppDelegate *delegate = ShareDelegate;
    NSManagedObjectContext *context = [delegate mainThreadContext];
    if ( nil == [DBManager searchFriendByUid:uid inContext:context]) {
        return NO;
    }
    return YES;
}

+ (BOOL)isFriendExistedByGid:(NSString *)gid{
    AppDelegate *delegate = ShareDelegate;
    NSManagedObjectContext *context = [delegate mainThreadContext];
    if ( nil == [DBManager searchFriendByGroupId:gid inContext:context]) {
        return NO;
    }
    return YES;
}

+ (void)saveFriendListByDicArray:(NSArray *)dicArray{
    AppDelegate *delegate = ShareDelegate;
    NSManagedObjectContext *context = [delegate temporaryContext];
    [context performBlock:^{
        [dicArray enumerateObjectsUsingBlock:^(NSDictionary * dic, NSUInteger idx, BOOL *stop) {
            FriendInfo *friend = [NSEntityDescription insertNewObjectForEntityForName:@"FriendInfo" inManagedObjectContext:context];
            [DBManager saveFriendInfo:friend dataDic:dic inContext:context];
        }];
        NSError *error;
        if (![context save:&error]) {
            DLog(@"Error Happend When SaveFriendList : %@",error.localizedDescription);
        }else{
            [delegate saveContextWithWait:NO];
        }
    }];
}

+ (void)saveNewFriendByDic:(NSDictionary *)dic{
    AppDelegate *delegate = ShareDelegate;
    NSManagedObjectContext *context = [delegate temporaryContext];
    [context performBlock:^{
        FriendInfo *friend = [DBManager getOrCreateFriendIfNeedByUid:dic[@"uid"] inContext:context];
        [DBManager saveFriendInfo:friend dataDic:dic inContext:context];
        NSError *error;
        if (![context save:&error]) {
            DLog(@"Error Happend When SaveNewFriend : %@",error.localizedDescription);
        }else{
            [delegate saveContextWithWait:NO];
        }
    }];
}

+ (void)deleteFriendByUid:(NSString *)uid{
    AppDelegate *delegate = ShareDelegate;
    NSManagedObjectContext *context = [delegate mainThreadContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"FriendInfo"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == %@",uid];
    request.predicate = predicate;
    NSError *error;
    NSArray *array = [context executeFetchRequest:request error:&error];
    if (error) {
        DLog(@"Error Happend When GetFriend : %@",error.localizedDescription);
        return;
    }
    [array enumerateObjectsUsingBlock:^(FriendInfo * obj, NSUInteger idx, BOOL *stop) {
        [context deleteObject:obj];
        [obj.firstLetter removeFriendInfoObject:obj];
    }];
    if (![context save:&error]) {
        DLog(@"Error Happend When DeleteFriend : %@",error.localizedDescription);
    }else{
        [delegate saveContextWithWait:NO];
    }
    
}

+ (void)deleteFriendByGid:(NSString *)gid{
    
    AppDelegate *delegate = ShareDelegate;
    NSManagedObjectContext *context = [delegate mainThreadContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"FriendInfo"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fgid == %@",gid];
    request.predicate = predicate;
    NSError *error;
    NSArray *array = [context executeFetchRequest:request error:&error];
    if (error) {
        DLog(@"Error Happend When GetFriend : %@",error.localizedDescription);
        return;
    }
    [array enumerateObjectsUsingBlock:^(FriendInfo * obj, NSUInteger idx, BOOL *stop) {
        [context deleteObject:obj];
        [obj.firstLetter removeFriendInfoObject:obj];
    }];
    if (![context save:&error]) {
        DLog(@"Error Happend When DeleteFriend : %@",error.localizedDescription);
    }else{
        [delegate saveContextWithWait:NO];
    }
}

+ (void)deleteAllFriends{
    AppDelegate *delegate = ShareDelegate;
    NSManagedObjectContext *context = [delegate mainThreadContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"FriendInfo"];
    NSError *error;
    NSArray *array = [context executeFetchRequest:request error:&error];
    if (error) {
        DLog(@"Error Happend When DeleteAllFriends : %@",error.localizedDescription);
        return;
    }
    if (array.count == 0 || array == nil) {
        return;
    }else{
        [array enumerateObjectsUsingBlock:^(FriendInfo *obj, NSUInteger idx, BOOL *stop) {
            [context deleteObject:obj];
            [obj.firstLetter removeFriendInfoObject:obj];
        }];
        if (![context save:&error]) {
            DLog(@"Error Happend When SaveNewFriend : %@",error.localizedDescription);
        }else{
            [delegate saveContextWithWait:YES];
        }
    }
}

#pragma mark ----------- Group -------------
+ (Group *)searchGroupByGroupId:(NSString *)gid
                      inContext:(NSManagedObjectContext *)context{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Group"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"gid == %@",gid];
    request.predicate = predicate;
    NSError *error;
    NSArray *array = [context executeFetchRequest:request error:&error];
    if (error) {
        DLog(@"Error Happend When SearchGroup : %@",error.localizedDescription);
        return nil;
    }
    if (array.count == 0 || array == nil) {
        return nil;
    }else{
        return (Group *)array[0];
    }
}

+ (Group *)getOrCreateGroupIfNeedByGroupId:(NSString *)gid
                              inContext:(NSManagedObjectContext *)context{
    Group *group = [DBManager searchGroupByGroupId:gid inContext:context];
    if ( group == nil ) {
        group = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:context];
    }
    return group;
}

+ (BOOL)isGroupExistedByGid:(NSString *)gid{
    AppDelegate *delegate = ShareDelegate;
    NSManagedObjectContext * context = [delegate mainThreadContext];
    if (nil == [DBManager searchGroupByGroupId:gid inContext:context]) {
        return NO;
    }
    return YES;
}

+ (void)saveGroup:(Group *)group
              dic:(NSDictionary *)dic
        inContext:(NSManagedObjectContext *)context{
    
    group.gid = dic[@"gid"];
    NSString *name = dic[@"gnm"];
    if ([name isNull]) {
        name = dic[@"gid"];
        NSRange range = [name rangeOfString:@"@"];
        if (NSNotFound != range.location) {
            name = [name substringToIndex:range.location];
        }
    }
    group.name = name;
    Letter *letter = [DBManager getOrCreateLetterIfNeedByLetter:[name firstLetter] inContext:context];
    group.firstLetter = letter;
    [letter addGroupObject:group];
}

+ (void)saveGroupListByDicArray:(NSArray *)dicArray{
    AppDelegate *delegate = ShareDelegate;
    NSManagedObjectContext *context = [delegate temporaryContext];
    
    [context performBlock:^{
        [dicArray enumerateObjectsUsingBlock:^(NSDictionary * dic, NSUInteger idx, BOOL *stop) {
            Group * group = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:context];
            [DBManager saveGroup:group dic:dic inContext:context];
        }];
        NSError *error;
        if (![context save:&error]) {
            DLog(@"Error Happend When SaveGroupList : %@",error.localizedDescription);
        }else{
            [delegate saveContextWithWait:NO];
        }
    }];
}

+ (void)saveNewGroupByDic:(NSDictionary *)dic{
    AppDelegate *delegate = ShareDelegate;
    NSManagedObjectContext *context = [delegate temporaryContext];
    [context performBlock:^{
        Group *group = [DBManager getOrCreateGroupIfNeedByGroupId:dic[@"gid"] inContext:context];
        [DBManager saveGroup:group dic:dic inContext:context];
        NSError *error;
        if (![context save:&error]) {
            DLog(@"Error Happend When SaveNewGroup : %@",error.localizedDescription);
        }else{
            [delegate saveContextWithWait:NO];
        }
    }];
}

+ (void)deleteAllGroups{
    AppDelegate *delegate = ShareDelegate;
    NSManagedObjectContext *context = [delegate mainThreadContext];

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Group"];

    NSError *error;
    NSArray *array = [context executeFetchRequest:request error:&error];
    if (error) {
        DLog(@"Error Happend When SearchGroup : %@",error.localizedDescription);
        return;
    }
    [array enumerateObjectsUsingBlock:^(Group *obj, NSUInteger idx, BOOL *stop) {
        [context deleteObject:obj];
        [obj.firstLetter removeGroupObject:obj];
    }];
    if (![context save:&error]) {
        DLog(@"Error Happend When DeleteAllGroups : %@",error.localizedDescription);
    }else{
        [delegate saveContextWithWait:YES];
    }
}

+ (void)deleteGroupByGid:(NSString *)gid{
    
    AppDelegate *delegate = ShareDelegate;
    NSManagedObjectContext *context = [delegate mainThreadContext];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Group"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"gid == %@",gid];
    request.predicate = predicate;

    NSError *error;
    NSArray *array = [context executeFetchRequest:request error:&error];
    if (error) {
        DLog(@"Error Happend When SearchGroup : %@",error.localizedDescription);
        return;
    }
    
    [array enumerateObjectsUsingBlock:^(Group *obj, NSUInteger idx, BOOL *stop) {
        [context deleteObject:obj];
        [obj.firstLetter removeGroupObject:obj];
    }];
    if (![context save:&error]) {
        DLog(@"Error Happend When DeleteGroup : %@",error.localizedDescription);
    }else{
        [delegate saveContextWithWait:YES];
    }

}

+ (void)changeGroupName:(NSString *)name
                groupId:(NSString *)gid{
    AppDelegate *delegate = ShareDelegate;
    NSManagedObjectContext *context = [delegate mainThreadContext];
    Group *group = [DBManager getOrCreateGroupIfNeedByGroupId:gid inContext:context];
    group.gid = gid;
    group.name = name;
    
    [group.firstLetter removeGroupObject:group];
    Letter *letter = [DBManager getOrCreateLetterIfNeedByLetter:[name firstLetter] inContext:context];
    [letter addGroupObject:group];
    group.firstLetter = letter;
    
    NSError *error;
    if (![context save:&error]) {
        DLog(@"Error Happend When UpdateGroup : %@",error.localizedDescription);
    }else{
        [delegate saveContextWithWait:YES];
    }
}

#pragma mark ----------- Member -------------

+ (Member *)searchMemberByUid:(NSString *)uid
                  inGroup:(NSString *)gid{
    
    AppDelegate *delegate = ShareDelegate;
    NSManagedObjectContext *context = [delegate mainThreadContext];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Member"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"gid == %@ AND uid == %@",gid, uid];
    request.predicate = predicate;
    
    NSError *error;
    NSArray *array = [context executeFetchRequest:request error:&error];
    if (error) {
        DLog(@"Error Happend When SearchGroup : %@",error.localizedDescription);
        return nil;
    }
    if (array == nil || array.count == 0) {
        return nil;
    }
    return array[0];
}

+ (Member *)getOrCreateMemberIfNeedByUid:(NSString *)uid
                                 inGroup:(NSString *)gid
                                 context:(NSManagedObjectContext *)context{
    Member *member = [DBManager searchMemberByUid:uid inGroup:gid];
    if (member == nil) {
        member = [NSEntityDescription insertNewObjectForEntityForName:@"Member" inManagedObjectContext:context];
    }
    return member;
}

+ (void)saveMember:(Member *)member
           inGroup:(NSString *)gid
           dataDic:(NSDictionary *)dic
           context:(NSManagedObjectContext *)context{
    
    member.uid = dic[@"uid"];
    member.gid = gid;
    
    UserInfo *info = [DBManager userInfoByDic:dic isFriendInfo:NO inContext:context];
    member.info = info;
    info.member = member;
    
    NSString *letter = [info.name firstLetter];
    Letter *firstLetter = [DBManager getOrCreateLetterIfNeedByLetter:letter inContext:context];
    member.firstLetter = firstLetter;
    [firstLetter addMemberObject:member];
}

+ (void)saveMemberListByDicArray:(NSArray *)dicArray
                         toGroup:(NSString *)gid{
    AppDelegate *delegate = ShareDelegate;
    NSManagedObjectContext *context = [delegate temporaryContext];
    
    [context performBlock:^{
        
        [dicArray enumerateObjectsUsingBlock:^(NSDictionary * dic, NSUInteger idx, BOOL *stop) {
            NSString *uid = dic[@"uid"];
            if ([uid isEqualToString:[UDManager getUserName]]) {
                return;
            }
            Member *member = [NSEntityDescription insertNewObjectForEntityForName:@"Member" inManagedObjectContext:context];
            [DBManager saveMember:member inGroup:gid dataDic:dic context:context];
        }];
        NSError *error;
        if (![context save:&error]) {
            DLog(@"Error Happend When SaveMemberList : %@",error.localizedDescription);
        }else{
            [delegate saveContextWithWait:NO];
        }
    }];
}

+ (void)saveMemberToGroupId:(NSString *)gid
                    dataDic:(NSDictionary *)dic{
    
    AppDelegate *delegate = ShareDelegate;
    NSManagedObjectContext *context = [delegate temporaryContext];

    [context performBlock:^{
        NSString *uid = dic[@"uid"];
        if ([uid isEqualToString:[UDManager getUserName]]) {
            return;
        }
        Member *member = [DBManager getOrCreateMemberIfNeedByUid:dic[@"uid"] inGroup:gid context:context];
        [DBManager saveMember:member inGroup:gid dataDic:dic context:context];
        NSError *error;
        if (![context save:&error]) {
            DLog(@"Error Happend When SaveMember : %@",error.localizedDescription);
        }else{
            [delegate saveContextWithWait:NO];
        }
    }];
}

+ (void)deleteAllMembersInGroup:(NSString *)gid{
    
    AppDelegate *delegate = ShareDelegate;
    NSManagedObjectContext *context = [delegate mainThreadContext];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Member"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"gid == %@",gid];
    request.predicate = predicate;
    
    NSError *error;
    NSArray *array = [context executeFetchRequest:request error:&error];
    if (error) {
        DLog(@"Error Happend When SearchGroup : %@",error.localizedDescription);
        return;
    }
    [array enumerateObjectsUsingBlock:^(Member *obj, NSUInteger idx, BOOL *stop) {
        [context deleteObject:obj];
        [obj.firstLetter removeMemberObject:obj];
    }];
    if (![context save:&error]) {
        DLog(@"Error Happend When DeleteAllGroups : %@",error.localizedDescription);
    }else{
        [delegate saveContextWithWait:YES];
    }
}

+ (void)deleteMemberByUid:(NSString *)uid
                  inGroup:(NSString *)gid{
    AppDelegate *delegate = ShareDelegate;
    NSManagedObjectContext *context = [delegate mainThreadContext];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Member"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"gid == %@ AND uid == %@",gid , uid];
    request.predicate = predicate;
    
    NSError *error;
    NSArray *array = [context executeFetchRequest:request error:&error];
    if (error) {
        DLog(@"Error Happend When SearchGroup : %@",error.localizedDescription);
        return;
    }
    [array enumerateObjectsUsingBlock:^(Member *obj, NSUInteger idx, BOOL *stop) {
        [context deleteObject:obj];
         [obj.firstLetter removeMemberObject:obj];
    }];
    if (![context save:&error]) {
        DLog(@"Error Happend When DeleteAllGroups : %@",error.localizedDescription);
    }else{
        [delegate saveContextWithWait:YES];
    }
}


+ (NSArray *)getMembersByGroupId:(NSString *)gid{
    AppDelegate *delegate = ShareDelegate;
    NSManagedObjectContext *context = [delegate mainThreadContext];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Member"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"gid == %@ ",gid];
    request.predicate = predicate;
    
    NSError *error;
    NSArray *array = [context executeFetchRequest:request error:&error];
    if (error) {
        DLog(@"Error Happened When GetMembers : %@",error.localizedDescription);
        return nil;
    }
    return array;
}

#pragma mark ----------- Conversation -------------

+ (Conversation *)getOrCreateConversionIfNeedByGroupId:(NSString *)gid
                                             inContext:(NSManagedObjectContext *)context{
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Conversation"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"gid == %@",gid];
    request.predicate = predicate;
    NSError *error;
    NSArray *array = [context executeFetchRequest:request error:&error];
    if (array.count == 0 || array == nil) {
        Conversation *conversation = [NSEntityDescription insertNewObjectForEntityForName:@"Conversation" inManagedObjectContext:context];
        return conversation;
    }
    else{
        return (Conversation *)[array lastObject];
    }
}

+ (Conversation *)getOrCreateConversionIfNeedByUserId:(NSString *)uid
                                            inContext:(NSManagedObjectContext *)context{
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Conversation"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == %@",uid];
    request.predicate = predicate;
    NSError *error;
    NSArray *array = [context executeFetchRequest:request error:&error];
    if (array.count == 0 || array == nil) {
        Conversation *conversation = [NSEntityDescription insertNewObjectForEntityForName:@"Conversation" inManagedObjectContext:context];
        return conversation;
    }
    else{
        return (Conversation *)[array lastObject];
    }
}

+ (void)saveChatConversationByDic:(NSDictionary *)dataDic
                         isUnread:(BOOL)isUnread{
    
    AppDelegate *delegate = ShareDelegate;
    NSManagedObjectContext *context = [delegate temporaryContext];
    
    [context performBlock:^{
        NSString *gid = dataDic[@"gid"];
        
        BOOL isGroup = [DBManager idIsGroupId:gid];
        Conversation *conversation = [DBManager getOrCreateConversionIfNeedByGroupId:gid inContext:context];
        conversation.gid = gid;
        
        NSString *name;
        
        if (isGroup) {
            Group *group = [DBManager searchGroupByGroupId:gid inContext:context];
            if (group == nil) {
                DLog(@"信息保存失败，没有该群组");
                return ;
            }
            name = group.name;
        }
        else{
            FriendInfo *friend = [DBManager searchFriendByGroupId:gid inContext:context];
            if (friend == nil) {
                DLog(@"信息保存失败，没有该好友");
                return ;
            }
            name = friend.info.name;
        }
        
        conversation.title = name;
        conversation.name = name;
        
        int type = [dataDic[@"msgType"] intValue];
        
        if (type == MSG_TEXT) {
            conversation.detail = dataDic[@"msg"];
        }
        else if (type == MSG_RECORD){
            conversation.detail = @"语音信息";
        }
        else if (type == MSG_IMG){
            conversation.detail = @"图片";
        }
        
        conversation.date = [NSDate dateFromString:dataDic[@"msgDate"]];
        
        if (isUnread) {
            int unread = [conversation.unreadCount intValue];
            unread = unread + 1;
            conversation.unreadCount = [NSNumber numberWithInt:unread];
        }
        
        if (isGroup) {
            conversation.conversationType = [NSNumber numberWithInt:CT_GROUP_CHAT];
        }
        else{
            conversation.conversationType = [NSNumber numberWithInt:CT_FRIEND_CHAT];
        }
        
        NSError *saveError = nil;
        if(![context save:&saveError]){
            DLog(@"保存会话失败:%@",saveError);
        }else{
            [delegate saveContextWithWait:NO];
        }
    }];
}

+ (void)saveTalkConversationByDic:(NSDictionary *)dataDic
                         isUnread:(BOOL)isUnread{
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [delegate temporaryContext];
    
    [context performBlock:^{
        
        NSString *gid = dataDic[@"gid"];
        Conversation *conversation = [DBManager getOrCreateConversionIfNeedByGroupId:gid inContext:context];
        conversation.gid = gid;
        NSString *name;
        
        if ([DBManager idIsGroupId:gid]) {
            Group *group = [DBManager searchGroupByGroupId:gid inContext:context];
            if (group == nil) {
                DLog(@"信息保存失败，没有该群组");
                return ;
            }
            name = group.name;
        }
        else{
            FriendInfo *friend = [DBManager searchFriendByGroupId:gid inContext:context];
            if (friend == nil) {
                DLog(@"信息保存失败，没有该好友");
                return ;
            }
            name = friend.info.name;
        }
        
        conversation.title = name;
        conversation.name = name;
        
        conversation.detail = dataDic[@"message"];
        conversation.date = [NSDate date];
        
        if (isUnread) {
            int unread = [conversation.unreadCount intValue];
            unread = unread + 1;
            conversation.unreadCount = [NSNumber numberWithInt:unread];
        }
        
        if ([DBManager idIsGroupId:dataDic[@"gid"]]) {
            conversation.conversationType = [NSNumber numberWithInt:CT_GROUP_CHAT];
        }
        else{
            conversation.conversationType = [NSNumber numberWithInt:CT_FRIEND_CHAT];
        }
        
        NSError *saveError = nil;
        if(![context save:&saveError]){
            DLog(@"保存会话失败:%@",saveError);
        }else{
            [delegate saveContextWithWait:NO];
        }
    }];
    
}


+ (void)saveInviteMeConversationByDic:(NSDictionary *)dataDic{
    AppDelegate *delegate = ShareDelegate;
    NSManagedObjectContext *context = [delegate temporaryContext];
    
    [context performBlock:^{
        
        NSString *uid = dataDic[@"uid"];
        Conversation *conversation = [DBManager getOrCreateConversionIfNeedByUserId:uid inContext:context];
        conversation.uid = uid;
        conversation.conversationType = [NSNumber numberWithInt:CT_NEW_INVITE];
        
        conversation.date = [NSDate date];
        
        NSString *name = dataDic[@"name"];
        if ([name isNull]) {
            name = dataDic[@"uid"];
            NSRange range = [name rangeOfString:@"@"];
            if (NSNotFound != range.location) {
                name = [name substringToIndex:range.location];
            }
        }
        conversation.name = name;
        conversation.title = [NSString stringWithFormat:@"%@想要加你为好友",name];
        
        NSString *note = dataDic[@"notes"];
        if ([note isNull]) {
            conversation.detail = @"无验证信息";
        }
        else{
            conversation.detail = [NSString stringWithFormat:@"验证信息:%@",note];
        }
        conversation.note = note;
        conversation.unreadCount = @1;
        
        NSError *error = nil;
        if(![context save:&error]){
            DLog(@"保存会话失败:%@",error.localizedDescription);
        }else{
            [delegate saveContextWithWait:NO];
        }
    }];
}


+ (void)saveInviteOtherConversationByDic:(NSDictionary *)dataDic{
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [delegate temporaryContext];
    [context performBlock:^{
        
        NSString *uid = dataDic[@"uid"];
        Conversation *conversation = [DBManager getOrCreateConversionIfNeedByUserId:uid inContext:context];
        conversation.uid = uid;
        
        NSString *name = dataDic[@"name"];
        if ([name isNull]) {
            name = dataDic[@"uid"];
            NSRange range = [name rangeOfString:@"@"];
            if (NSNotFound != range.location) {
                name = [name substringToIndex:range.location];
            }
        }
        conversation.name = name;
        
        conversation.note = dataDic[@"notes"];
        int type = [dataDic[@"state"] intValue];
        if ( type == 0 ) {
            conversation.title = [NSString stringWithFormat:@"邀请%@",name];
            conversation.detail = @"等待对方回应";
            conversation.conversationType = @3;
        }
        else{
            conversation.title = [NSString stringWithFormat:@"%@拒绝了你的邀请",name];
            conversation.detail = [NSString stringWithFormat:@"拒绝理由:%@",dataDic[@"notes"]];
            conversation.conversationType = @4;
        }
        
        conversation.date = [NSDate date];
        conversation.unreadCount = @1;
        
        NSError *error;
        if (![context save:&error]) {
            DLog(@"保存邀请信息会话失败:%@",error);
        }
        else{
            [delegate saveContextWithWait:NO];
        }
    }];
}


+ (void)saveAgreeInvitedConversationByDic:(NSDictionary *)dataDic{
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [delegate temporaryContext];
    
    [context performBlock:^{
        NSString *uid = dataDic[@"fuid"];
        Conversation *conversation = [DBManager getOrCreateConversionIfNeedByUserId:uid inContext:context];
        conversation.uid = uid;
        conversation.conversationType = [NSNumber numberWithInt:CT_FRIEND_CHAT];
        
        conversation.date = [NSDate date];

        conversation.gid = dataDic[@"fgid"];
        
        NSString *name = dataDic[@"name"];
        if ([name isNull]) {
            name = dataDic[@"fuid"];
            NSRange range = [name rangeOfString:@"@"];
            if (NSNotFound != range.location) {
                name = [name substringToIndex:range.location];
            }
        }
        conversation.name = name;
        conversation.title = [NSString stringWithFormat:@"%@和你已经成为好友", name];
        conversation.detail = @"点击进入对讲";
        conversation.unreadCount = @1;
        NSError *saveError = nil;
        if(![context save:&saveError]){
            DLog(@"保存会话失败:%@",saveError);
        }else{
            [delegate saveContextWithWait:NO];
        }
    }];
}

+ (void)saveJoinGroupConversationByDic:(NSDictionary *)dataDic{
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [delegate temporaryContext];
    
    [context performBlock:^{
        Conversation *conversation = [DBManager getOrCreateConversionIfNeedByGroupId:dataDic[@"gid"] inContext:context];
        conversation.gid = dataDic[@"gid"];
        conversation.name = dataDic[@"gnm"];
        conversation.title = [NSString stringWithFormat:@"你加入了%@",dataDic[@"gnm"]];
        conversation.detail = @"点击进入对讲";
        conversation.date = [NSDate date];
        conversation.conversationType = @1;
        conversation.unreadCount = @1;
        
        NSError *error;
        if (![context save:&error]) {
            DLog(@"保存加入群组会话失败:%@",error);
        }
        else{
            [delegate saveContextWithWait:NO];
        }
    }];
}

+ (void)saveNewMemberConversationByDic:(NSDictionary *)dataDic
                                unread:(BOOL)unread{
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [delegate temporaryContext];
    
    /*
     [ NOTIFY`RecvAppMessage`{"type":"addm","gid":"g478@a","gnm":"测试成员","uid":"15999518574@a","name":"贺美龙","uids":"15999518575@a;15914171994@a;15013555301@a;","message":"贺美龙邀请贺美龙5;兰团保;林加明加入测试成员"} ]
     */
    
    [context performBlock:^{
        Conversation *conversation = [DBManager getOrCreateConversionIfNeedByGroupId:dataDic[@"gid"] inContext:context];
        conversation.gid = dataDic[@"gid"];
        conversation.name = dataDic[@"gnm"];
        conversation.title = dataDic[@"gnm"];
        conversation.detail = dataDic[@"message"];
        conversation.date = [NSDate date];
        conversation.conversationType = [NSNumber numberWithInt:CT_GROUP_CHAT];
        if (unread) {
            int unreadCount = [conversation.unreadCount intValue];
            unreadCount = unreadCount + 1;
            conversation.unreadCount = [NSNumber numberWithInt:unreadCount];
        }
        NSError *error;
        if (![context save:&error]) {
            DLog(@"保存新成员会话失败:%@",error);
        }
        else{
            [delegate saveContextWithWait:NO];
        }
    }];
}

+ (void)saveMemberQuitConversationByDic:(NSDictionary *)dataDic
                                 unread:(BOOL)unread{
    /*
     [ NOTIFY`RecvAppMessage`{"type":"delm","gid":"g479@a","uid":"15914171994@a","message":"兰团保退出C608"} ]
     */
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [delegate temporaryContext];
    
    [context performBlock:^{
        Conversation *conversation = [DBManager getOrCreateConversionIfNeedByGroupId:dataDic[@"gid"] inContext:context];
        Group *group = [DBManager searchGroupByGroupId:dataDic[@"gid"] inContext:context];
        if (group == nil) {
            DLog(@"保存成员退出会话失败, 没有该群组");
            return ;
        }
        conversation.gid = dataDic[@"gid"];
        conversation.name = group.name;
        conversation.title = group.name;
        conversation.detail = dataDic[@"message"];
        conversation.date = [NSDate date];
        conversation.conversationType = [NSNumber numberWithInt:CT_GROUP_CHAT];
        if (unread) {
            int unreadCount = [conversation.unreadCount intValue];
            unreadCount = unreadCount + 1;
            conversation.unreadCount = [NSNumber numberWithInt:unreadCount];
        }
        NSError *error;
        if (![context save:&error]) {
            DLog(@"保存成员退出会话失败:%@",error);
        }
        else{
            [delegate saveContextWithWait:NO];
        }
    }];


}


+ (void)deleteConversationByGroupId:(NSString *)gid{
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [delegate mainThreadContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Conversation"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"gid==%@", gid];
    request.predicate = predicate;
    NSError *error;
    NSArray *array = [context executeFetchRequest:request error:&error];
    if (error) {
        DLog(@"Error Happened When SearchConversion : %@",error.localizedDescription);
    }
    [array enumerateObjectsUsingBlock:^(Conversation * obj, NSUInteger idx, BOOL *stop) {
        [context deleteObject:obj];
    }];
    if (![context save:&error]) {
        DLog(@"Error Happened When DeleteConversion:%@",error.localizedDescription);
    }
    else{
        [delegate saveContextWithWait:YES];
    }
}

+ (void)deleteConversationByUserId:(NSString *)uid{
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [delegate mainThreadContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Conversation"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid==%@", uid];
    request.predicate = predicate;
    NSError *error;
    NSArray *array = [context executeFetchRequest:request error:&error];
    if (error) {
        DLog(@"Error Happened When SearchConversion : %@",error.localizedDescription);
    }
    [array enumerateObjectsUsingBlock:^(Conversation * obj, NSUInteger idx, BOOL *stop) {
        [context deleteObject:obj];
    }];
    if (![context save:&error]) {
        DLog(@"Error Happened When DeleteConversion:%@",error.localizedDescription);
    }
    else{
        [delegate saveContextWithWait:YES];
    }
}

+ (void)clearConversationUnreadCout:(Conversation *)conversation{
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    conversation.unreadCount = 0;
    [delegate saveContextWithWait:NO];
    
}


#pragma mark ----------- Message -------------
+ (Message *)saveChatMessageByDic:(NSDictionary *)dataDic{
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [delegate temporaryContext];
    
    Message *message = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:context];
    
    
    if ([dataDic[@"uid"] isEqualToString:[UDManager getUserId]]) {
        message.senderName = @"我";
        message.fromSelf = @1;
        message.date = [NSDate date];
    }
    else{
        message.senderName = dataDic[@"name"];
        message.fromSelf = @0;
        message.date = [NSDate dateFromString:dataDic[@"msgDate"]];
    }
    
    message.msg = dataDic[@"msg"];
    
    message.sendResult = dataDic[@"sendResult"];
    
    int type = [dataDic[@"msgType"] intValue];
    message.msgType = [NSNumber numberWithInt:type];
    
    if (type == MSG_RECORD) {
        message.unread = @1;
        message.recordDur = [NSNumber numberWithFloat:[dataDic[@"voiceTime"] floatValue]];
        
        //录音统一用现在的时间，因为收到录音时还要下载，如果用发送的时间，会出现会话界面信息插在上面的情形
        message.date = [NSDate date];
    }
    
    NSString *gid = dataDic[@"gid"];
    if ([DBManager idIsGroupId:gid]) {
        Group *group = [DBManager searchGroupByGroupId:gid inContext:context];
        if (group == nil) {
            DLog(@"保存信息失败，没有该群组！");
            return nil;
        }
        message.gid = gid;
    }
    else{
        FriendInfo *friendInfo = [DBManager searchFriendByGroupId:gid inContext:context];
        if (friendInfo == nil) {
            DLog(@"保存信息失败，没有该好友！");
            return nil;
        }
        message.gid = gid;
    }
    NSError *saveError = nil;
    if(![context save:&saveError]){
        DLog(@"保存信息失败:%@",saveError);
    }
    else{
        DLog(@"保存信息成功");
        [delegate saveContextWithWait:YES];
    }
    return message;
}

+ (void)saveTalkMessageByDic:(NSDictionary *)dataDic{
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [delegate temporaryContext];
    
    [context performBlockAndWait:^{
        
        Message *message = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:context];
    
        if ([dataDic[@"uid"] isEqualToString:[UDManager getUserId]]) {
            message.fromSelf = @1;
        }
        else{
            message.fromSelf = @0;
        }
        message.senderName = @" ";
        
        message.msg = dataDic[@"message"];
        message.date = [NSDate date];
        
        message.msgType = [NSNumber numberWithInt:MSG_TALK];
        
        NSString *gid = dataDic[@"gid"];
        if ([DBManager idIsGroupId:gid]) {
            Group *group = [DBManager searchGroupByGroupId:gid inContext:context];
            if (group == nil) {
                DLog(@"保存信息失败，没有该群组！");
                return ;
            }
            message.gid = gid;
        }
        else{
            FriendInfo *friendInfo = [DBManager searchFriendByGroupId:gid inContext:context];
            if (friendInfo == nil) {
                DLog(@"保存信息失败，没有该好友！");
                return;
            }
            message.gid = gid;
        }
        NSError *saveError = nil;
        if(![context save:&saveError]){
            DLog(@"保存信息失败:%@",saveError);
        }
        else{
            DLog(@"保存信息成功");
            [delegate saveContextWithWait:NO];
        }
    }];
}

+ (void)saveNewMemberMessageByDic:(NSDictionary *)dataDic{
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [delegate temporaryContext];
    
    Message *message = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:context];

    message.fromSelf = @0;
    message.date = [NSDate date];
    message.msg = dataDic[@"message"];
    
    message.msgType = [NSNumber numberWithInt:MSG_TEXT];
    
    NSString *gid = dataDic[@"gid"];
    if ([DBManager idIsGroupId:gid]) {
        Group *group = [DBManager searchGroupByGroupId:gid inContext:context];
        if (group == nil) {
            DLog(@"保存信息失败，没有该群组！");
            return;
        }
        message.gid = gid;
    }
    else{
        return;
    }
    NSError *saveError = nil;
    if(![context save:&saveError]){
        DLog(@"保存信息失败:%@",saveError);
    }
    else{
        DLog(@"保存信息成功");
        [delegate saveContextWithWait:YES];
    }

}

+ (void)deleteMessagesByGroupId:(NSString *)gid{
    
    AppDelegate *delegate = ShareDelegate;
    NSManagedObjectContext *context = [delegate mainThreadContext];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Message"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"gid==%@", gid];
    request.predicate = predicate;
    NSError *error;
    NSArray *array = [context executeFetchRequest:request error:&error];
    if (error) {
        DLog(@"Error Happened When SearchMessage : %@",error.localizedDescription);
        return;
    }
    [array enumerateObjectsUsingBlock:^(Message *obj, NSUInteger idx, BOOL *stop) {
        [context deleteObject:obj];
    }];
    if (![context save:&error]) {
        DLog(@"Error Happened When DeleteGroupMessage:%@",error.localizedDescription);
    }
    else{
        [delegate saveContextWithWait:NO];
    }
}

+ (void)updateMessageSendResult:(Message *)message
                        result:(int)result{
    AppDelegate *delegate = ShareDelegate;
    message.sendResult = [NSNumber numberWithInt:result];
    [delegate saveContextWithWait:YES];
}

+ (void)updateMessageUnread:(Message *)message{
    AppDelegate *delegate = ShareDelegate;
    message.unread = @0;
    [delegate saveContextWithWait:YES];
}


@end
