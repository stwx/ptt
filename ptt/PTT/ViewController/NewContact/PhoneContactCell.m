//
//  ContactCell.m
//  PTT
//
//  Created by xihan on 15/6/15.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import "PhoneContactCell.h"

@implementation PhoneContactCell{
    UIButton *_btn;
    
}

+ (PhoneContactCell *)dequeueReusableCellFromTableView:(UITableView *)tableView{
    PhoneContactCell *cell = [tableView dequeueReusableCellWithIdentifier:@"common"];
    if (cell == nil) {
        cell = [[PhoneContactCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"contact"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    _btn = [[UIButton alloc] initWithFrame:CGRectMake(Main_Screen_Width - 100, 10, 80, 30)];
    
    [_btn setBackgroundImage:[UIImage imageNamed:@"green_btn_pre"] forState:UIControlStateNormal];
    [_btn addTarget:self action:@selector(inviteBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_btn];
    self.imageView.image = [UIImage imageNamed:@"friend_online"];
    return self;
}

- (void)setBtnTag:(NSInteger)btnTag{
    _btn.tag = btnTag;
}

- (void)setBtnType:(NSInteger)btnType{
    if (btnType == 0) {
        [_btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btn setTitle:@"邀请" forState:UIControlStateNormal];
        _btn.userInteractionEnabled = YES;
        
    }else{
        [_btn setTitle:@"已邀请" forState:UIControlStateNormal];
        [_btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
         _btn.userInteractionEnabled = NO;

    }
}

- (void)inviteBtn:(UIButton *)btn{
    [_btn setTitle:@"已邀请" forState:UIControlStateNormal];
    [_btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    _btn.userInteractionEnabled = NO;
    if (self.inviteBlock) {
        self.inviteBlock(btn.tag);
    }
    if ([_delegate respondsToSelector:@selector(invitedFriend:)]) {
        [_delegate invitedFriend:btn.tag];
    }
}
@end
