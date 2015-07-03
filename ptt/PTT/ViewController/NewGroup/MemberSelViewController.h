//
//  MemberSelViewController.h
//  PTT
//
//  Created by xihan on 15/6/22.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import "PttViewController.h"

typedef enum {
    MSVT_ADD,
    MSVT_NEW
}MemberSelViewType;

@interface MemberSelViewController : PttViewController

@property (nonatomic, assign) MemberSelViewType viewType;
@property (nonatomic, strong) NSArray *memberArray;
@property (nonatomic, copy) NSString *groupName;
@property (nonatomic, copy) NSString *gid;


@end
