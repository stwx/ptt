//
//  InviteInfoViewController.h
//  PTT
//
//  Created by xihan on 15/6/24.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import "PttViewController.h"

typedef enum {
    IT_WAIT,
    IT_DISAGREE,
}InviteType;

@interface InviteInfoViewController : PttViewController

@property (nonatomic, assign) InviteType invtiteType;
@property (nonatomic, copy) NSString * note;
@property (nonatomic, copy) NSString * name;

@end
