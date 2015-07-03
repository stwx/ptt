//
//  ChatViewController.h
//  PTT
//
//  Created by xihan on 15/6/23.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import "PttViewController.h"

typedef enum {
    VT_FRIEND,
    VT_GROUP,
}ViewType;

@interface ChatViewController : PttViewController

@property (nonatomic, copy) NSString *chatName;
@property (nonatomic, copy) NSString *gid;
@property (nonatomic, assign) ViewType viewType;

@end
