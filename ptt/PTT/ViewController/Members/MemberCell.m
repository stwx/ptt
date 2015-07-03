//
//  MemberCell.m
//  PTT
//
//  Created by xihan on 15/6/9.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import "MemberCell.h"

#define kCellHeight 60

@implementation MemberCell{
    UIImageView *_headImgView;
    UITextField *_nameTF;
    UIButton *_remarkBtn;
}

+ (MemberCell *)dequeueReusableCellFromTableView:(UITableView *)tableView{
    MemberCell *cell = [tableView dequeueReusableCellWithIdentifier:@"member"];
    if (cell == nil) {
        cell = [[MemberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"member"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _headImgView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, kCellHeight - 10, kCellHeight -10)];
        _headImgView.image = [UIImage imageNamed:@"friend_online"];
        [self.contentView addSubview:_headImgView];
        
        _nameTF = [[UITextField alloc] initWithFrame:CGRectMake(MaxX(_headImgView)+3, 0, 200, kCellHeight)];
        _nameTF.borderStyle = UITextBorderStyleNone;
        _nameTF.textColor = [UIColor blackColor];
        _nameTF.font = [UIFont systemFontOfSize:18];
        _nameTF.enabled = NO;
        [self.contentView addSubview:_nameTF];
        
        _remarkBtn = [[UIButton alloc] initWithFrame:CGRectMake(Main_Screen_Width - kCellHeight, 0, kCellHeight, kCellHeight)];
        [_remarkBtn addTarget:self action:@selector(remarkBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_remarkBtn];
    }
    return self;
}

+ (CGFloat)cellHeight{
    return kCellHeight;
}

- (void)setBtnType:(RightBtnType)btnType{
    if (btnType == RBT_DELETE) {
        [_remarkBtn setTitle:@"删除" forState:UIControlStateNormal];
        [_remarkBtn setBackgroundImage:[UIImage imageNamed:@"remark_cancel"] forState:UIControlStateNormal];
        [_remarkBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }else{
        [_remarkBtn setTitle:@"备注" forState:UIControlStateNormal];
        [_remarkBtn setBackgroundImage:[UIImage imageNamed:@"remark"] forState:UIControlStateNormal];
        [_remarkBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
}

- (void)setTag:(NSInteger)tag{
    _remarkBtn.tag = tag;
}

- (void)setName:(NSString *)name{
    _nameTF.text = name;
}

- (void)remarkBtnClick:(UIButton *)btn{
    DLog(@"\n================\nremarkBtnClick\n===============\n");
    if ([btn.titleLabel.text isEqualToString:@"删除"]) {
        if ([_delegate respondsToSelector:@selector(deleteMemberByIndex:)]) {
            [_delegate deleteMemberByIndex:_index];
        }
    }else{
        if ([_delegate respondsToSelector:@selector(remarkMemberByIndex:)]) {
            [_delegate remarkMemberByIndex:_index];
        }
    }
}

@end
