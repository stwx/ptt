//
//  MemberFootView.h
//  PTT
//
//  Created by xihan on 15/6/9.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MemberFootViewDelegate <NSObject>
@optional
- (void)FootView_addMember;
- (void)FootView_deleteMember;
- (void)FootView_quitGroup;
- (void)FootView_startEditing:(CGFloat)maxY;
- (void)FootView_changeGroupName:(NSString *)name;
@end




@interface MemberFootView : UIView

@property (nonatomic, copy) NSString *groupName;
@property (nonatomic, copy) NSString *groupNikName;
@property (nonatomic, assign) id<MemberFootViewDelegate>delegate;

- (void)hideKeyBoard;

@end
