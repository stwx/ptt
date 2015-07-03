//
//  MemberFootView.m
//  PTT
//
//  Created by xihan on 15/6/9.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import "MemberFootView.h"
#import "HttpManager.h"

@implementation MemberFootView{
    UILabel *_nikeNameLabel, *_groupNameLabel;
    UITextField *_nikeNameTF, *_groupNameTF;
    UIView *_groupNameView, *_nikeNameView;
}

#define viewHeight 60

- (instancetype)init{
    self = [super initWithFrame:CGRectMake(0, 0, Main_Screen_Width, (viewHeight + 20) * 3 + 80) ];
    if (self) {
        self.backgroundColor = RGBCOLOR(247, 247, 247);
        UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 20, WIDTH(self), viewHeight)];
        view1.backgroundColor = [UIColor whiteColor];
        [self addSubview:view1];
        
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(5, 5, viewHeight - 10, viewHeight - 10)];
        [btn setBackgroundImage:[UIImage imageNamed:@"add_member_btn_nor"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"add_member_btn_pre"] forState:UIControlStateHighlighted];
        [btn addTarget:self action:@selector(addMember) forControlEvents:UIControlEventTouchUpInside];
        [view1 addSubview: btn];
        
        UIButton *btn1 = [[UIButton alloc] initWithFrame:CGRectMake(MaxX(btn)+10, 5, viewHeight - 10, viewHeight - 10)];
        [btn1 setBackgroundImage:[UIImage imageNamed:@"del_member_btn_nor"] forState:UIControlStateNormal];
        [btn1 setBackgroundImage:[UIImage imageNamed:@"del_member_btn_pre"] forState:UIControlStateHighlighted];
        [btn1 addTarget:self action:@selector(deleteMember) forControlEvents:UIControlEventTouchUpInside];
        [view1 addSubview: btn1];
        
        _groupNameView= [self footCellViewWithFrame:CGRectMake(0, MaxY(view1) + 20, WIDTH(self), viewHeight) isGroup:YES];
    
        [self addSubview:_groupNameView];
        
        
        _nikeNameView = [self footCellViewWithFrame:CGRectMake(0, MaxY(_groupNameView)+20, WIDTH(self), viewHeight) isGroup:NO];
        [self addSubview:_nikeNameView];
        
        
        UIButton *btn2 = [[UIButton alloc] initWithFrame:CGRectMake(20, MaxY(_nikeNameView)+20, Main_Screen_Width - 40, 44)];
        [btn2 setBackgroundImage:[UIImage imageNamed:@"red_btn_nor"] forState:UIControlStateNormal];
        [btn2 setBackgroundImage:[UIImage imageNamed:@"red_btn_pre"] forState:UIControlStateHighlighted];
        [btn2 setTitle:@"退出并删除" forState:UIControlStateNormal];
        [btn2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn2.titleLabel.font = [UIFont systemFontOfSize:17];
        [btn2 addTarget:self action:@selector(quitGroup) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview: btn2];
        
    }
    return self;
}

- (UIView *)footCellViewWithFrame:(CGRect) frame isGroup:(BOOL)isGroup{
    
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor whiteColor];
    
    UIImageView* headImgView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, viewHeight - 10, viewHeight - 10)];
    headImgView.image = [UIImage imageNamed: isGroup ? @"group":@"friend_online"];
    [view addSubview:headImgView];
    
    UITextField *nameTF = [[UITextField alloc] initWithFrame:CGRectMake(MaxX(headImgView)+2, 0, 200, viewHeight)];
    nameTF.borderStyle = UITextBorderStyleNone;
    nameTF.textColor = [UIColor blackColor];
    nameTF.font = [UIFont systemFontOfSize:15];
    nameTF.enabled = NO;
    nameTF.text = isGroup?@"群组名称":@"我在本群的昵称";
    if (isGroup) {
        _groupNameTF = nameTF;
    }else{
        _nikeNameTF = nameTF;
    }
    [view addSubview:nameTF];
    
    UIButton *remarkBtn = [[UIButton alloc] initWithFrame:CGRectMake(Main_Screen_Width - viewHeight, 0, viewHeight, viewHeight)];
    [remarkBtn setBackgroundImage:[UIImage imageNamed:@"remark"] forState:UIControlStateNormal];
    remarkBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [remarkBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [remarkBtn setTitle:@"修改" forState:UIControlStateNormal];
    if (isGroup) {
        [remarkBtn addTarget:self action:@selector(changeGroupName:) forControlEvents:UIControlEventTouchUpInside];
    }
    [view addSubview:remarkBtn];
    
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, Main_Screen_Width-100-viewHeight - 10, viewHeight)];
//    label.textColor = [UIColor grayColor];
//    label.font = [UIFont systemFontOfSize:15];
//    label.textAlignment = NSTextAlignmentRight;
//    [view addSubview:label];
//    if (isGroup) {
//        _groupNameLabel = label;
//    }else{
//        _nikeNameLabel = label;
//    }
    return view;
}

- (void)setGroupName:(NSString *)groupName{
    _groupNameTF.text = groupName;
}

- (void)setGroupNikName:(NSString *)groupNikName{
    _nikeNameTF.text = groupNikName;
}

- (void)addMember{
    if ([_delegate respondsToSelector:@selector(FootView_addMember)]) {
        [_delegate FootView_addMember];
    }
}

- (void)deleteMember{
    if ([_delegate respondsToSelector:@selector(FootView_deleteMember)]) {
        [_delegate FootView_deleteMember];
    }
}

- (void)changeGroupName:(UIButton *)btn{
    if ([btn.titleLabel.text isEqualToString:@"修改"]) {
        [btn setTitle:@"完成" forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"remark_cancel"] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _groupNameTF.enabled = YES;
        if ([_delegate respondsToSelector:@selector(FootView_startEditing:)]) {
            [_delegate FootView_startEditing:MaxY(_groupNameView)];
        }

        [_groupNameTF becomeFirstResponder];
    }
    else{
        [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [btn setTitle:@"修改" forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"remark"] forState:UIControlStateNormal];
        _groupNameTF.enabled = NO;
        [_groupNameTF resignFirstResponder];
        if ([_delegate respondsToSelector:@selector(FootView_changeGroupName:)]) {
            [_delegate FootView_changeGroupName:_groupNameTF.text];
        }
    }
}

- (void)quitGroup{
    if ([_delegate respondsToSelector:@selector(FootView_quitGroup)]) {
        [_delegate FootView_quitGroup];
    }
}

- (void)hideKeyBoard{
    [_nikeNameTF resignFirstResponder];
    [_groupNameTF resignFirstResponder];
}


@end
