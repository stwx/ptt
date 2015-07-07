//
//  GroupCell.h
//  PTT
//
//  Created by xihan on 15/7/7.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupCell : UITableViewCell

+ (GroupCell *)dequeueReusableCellFromTableView:(UITableView *)tableView;
+ (CGFloat)cellHeight;

@property (nonatomic, weak) NSString * name;

@end
