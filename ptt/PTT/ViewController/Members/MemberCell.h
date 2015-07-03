//
//  MemberCell.h
//  PTT
//
//  Created by xihan on 15/6/9.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    RBT_REMARK,
    RBT_DELETE
}RightBtnType;

@protocol MemberCellDelegate <NSObject>

- (void)deleteMemberByIndex:(NSIndexPath *)index;
- (void)remarkMemberByIndex:(NSIndexPath *)index;

@end


@interface MemberCell : UITableViewCell

@property (nonatomic, copy)   NSString *name;
@property (nonatomic, assign) RightBtnType btnType;
@property (nonatomic, retain) NSIndexPath *index;


@property (nonatomic, assign)id<MemberCellDelegate>delegate;

+ (MemberCell *)dequeueReusableCellFromTableView:(UITableView *)tableView;
+ (CGFloat)cellHeight;

@end
