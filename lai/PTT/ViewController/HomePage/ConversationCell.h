//
//  ConversationCell.h
//  PTT
//
//  Created by xihan on 15/6/1.
//  Copyright (c) 2015年 stwx. All rights reserved.
//



#import <UIKit/UIKit.h>

@class Conversation;

@interface ConversationCell : UITableViewCell

@property (nonatomic, weak)Conversation *conversation;

+ (ConversationCell *)dequeueReusableCellFromTableView:(UITableView *)tableView;

+ (CGFloat)cellHeight;

@end
