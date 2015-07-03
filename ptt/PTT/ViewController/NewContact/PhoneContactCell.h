//
//  ContactCell.h
//  PTT
//
//  Created by xihan on 15/6/15.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ContactCellDelegate <NSObject>
- (void)invitedFriend:(NSInteger)index;
@end

typedef void(^InviteBlock)(NSInteger index);

@interface PhoneContactCell : UITableViewCell

+ (PhoneContactCell *)dequeueReusableCellFromTableView:(UITableView *)tableView;

@property (nonatomic, strong) InviteBlock inviteBlock;
@property (nonatomic, assign) NSInteger btnTag;
@property (nonatomic, assign) NSInteger btnType;
@property (nonatomic, assign) id<ContactCellDelegate>delegate;


@end
