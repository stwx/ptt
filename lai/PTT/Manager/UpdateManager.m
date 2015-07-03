//
//  UpdateManager.m
//  PTT
//
//  Created by xihan on 15/6/25.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import "UpdateManager.h"
#import "HttpManager.h"
#import "DBManager.h"
@implementation UpdateManager


+ (void)updateFriendList{
    [DBManager deleteAllFriends];
    [UpdateManager getFriendListFromPage:1];
}

+ (void)updateGroupList{
    [DBManager deleteAllGroups];
    [UpdateManager getGroupListFromPage:1];
}

+ (void)updateMemberListByGroupId:(NSString *)gid{
    [DBManager deleteAllMembersInGroup:gid];
    [UpdateManager getMemberByGroupId:gid formPage:1];
}


+ (void)getFriendListFromPage:(int)page{
    [HttpManager getFriendListByPage:page Handler:^(NSDictionary *dataDic) {
        if (PttDicResult(dataDic) != ACK_OK){
            return;
        }
        NSDictionary *ackDic = PttDicMsg(dataDic);
        [DBManager saveFriendListByDicArray:ackDic[@"users"]];
        
        int currentPage = [ackDic[@"curr"] intValue];
        int pageCount = [ackDic[@"total"] intValue];
        
        if (currentPage < pageCount) {
            currentPage ++;
            [UpdateManager getFriendListFromPage:currentPage];
        }
    }];
}


+ (void)getGroupListFromPage:(int)page{
    [HttpManager getGroupListByPage:page handler:^(NSDictionary *dataDic) {
        if (PttDicResult(dataDic) != ACK_OK) {
            return ;
        }
        NSDictionary *ackDic = PttDicMsg(dataDic);
        [DBManager saveGroupListByDicArray:ackDic[@"groups"]];
        
        int currentPage = [ackDic[@"curr"] intValue];
        int pageCount = [ackDic[@"total"] intValue];
        
        if (currentPage < pageCount) {
            currentPage ++;
            [UpdateManager getGroupListFromPage:currentPage];
        }
    }];
}

+ (void)getMemberByGroupId:(NSString *)gid
                  formPage:(int)page{
    
    [HttpManager getMembersForGroupId:gid page:page handler:^(NSDictionary *dataDic) {
        
        if (PttDicResult(dataDic) != ACK_OK) {
            return ;
        }
        
        NSDictionary *ackDic = PttDicMsg(dataDic);
        [DBManager saveMemberListByDicArray:ackDic[@"users"] toGroup:gid];
        
        int currentPage = [dataDic[@"curr"] intValue];
        int pageCount = [dataDic[@"total"] intValue];
        
        if (currentPage < pageCount) {
            currentPage ++;
            [UpdateManager getMemberByGroupId:gid formPage:currentPage];
        }
      
    }];

}


+ (void)updateAllMember{
//    BACK(^{
//        NSArray *array = [DBManager getAllGroupId];
//        [array enumerateObjectsUsingBlock:^(NSString* gid, NSUInteger idx, BOOL *stop) {
//            [UpdateManager getMemberByGroupId:gid];
//        }];
//    });
}





@end
