//
//  FriendSelCell.h
//  PTT
//
//  Created by xihan on 15/6/9.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    MST_Normoal,
    MST_Selected,
    MST_NotSelect
}MemberSelType;

@interface MemberSelCell : UITableViewCell

@property (nonatomic, assign) MemberSelType selType;
@property (nonatomic, copy) NSString *name;

+ (MemberSelCell *)dequeueReusableCellFromTableView:(UITableView *)tableView;
+ (CGFloat)cellHeight;

@end
