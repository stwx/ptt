//
//  MembersViewController.h
//  PTT
//
//  Created by xihan on 15/6/14.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import "PttViewController.h"

typedef void (^ChangeNameBlock)(NSString *name);

@interface MembersViewController : PttViewController
@property (nonatomic, copy) NSString *gid;
@property (nonatomic, copy) NSString *gnm;
@property (nonatomic, strong) ChangeNameBlock changeNameBlock;
@end
