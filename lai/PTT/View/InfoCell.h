//
//  InfoCell.h
//  PTT
//
//  Created by xihan on 15/6/14.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    InfoCell_FriendOnline,
    InfoCell_FriendOffline,
    InfoCell_Group
}InfoCellHeadType;

@interface InfoCell : UITableViewCell


+ (InfoCell *)dequeueReusableCellFromTableView:(UITableView *)tableView;
+ (CGFloat)cellHeight;

@property(nonatomic, weak) NSString *name;
@property(nonatomic, assign) InfoCellHeadType headType;

@end
