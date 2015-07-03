//
//  FriendSelCell.m
//  PTT
//
//  Created by xihan on 15/6/9.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import "MemberSelCell.h"

@implementation MemberSelCell{
    UIImageView *_headImgView, *_selectImgView;
    UILabel *_nameLabel;
}

+ (MemberSelCell *)dequeueReusableCellFromTableView:(UITableView *)tableView{
    MemberSelCell *cell = [tableView dequeueReusableCellWithIdentifier:@"common"];
    if (cell == nil) {
        cell = [[MemberSelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"common"];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _selectImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 7, 30, 30)];
        _selectImgView.image = [UIImage imageNamed:@"sel_friend_nor"];
        [self.contentView addSubview:_selectImgView];
        
        _headImgView = [[UIImageView alloc] initWithFrame:CGRectMake(MaxX(_selectImgView) + 10, 5, 40, 40)];
        _headImgView.image = [UIImage imageNamed:@"home_friend_online"];
        [self.contentView addSubview:_headImgView];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(MaxX(_headImgView) + 10, 14, 100, 21)];
        _nameLabel.textColor = [UIColor blackColor];
        _nameLabel.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:_nameLabel];
    }
    return self;
}

+ (CGFloat)cellHeight{
    return 50;
}

- (void)setSelType:(MemberSelType)selType{
    NSString *imageName;
    switch (selType) {
        case MST_Normoal:
            imageName = @"sel_friend_nor";
            break;
        case MST_NotSelect:
            imageName = @"sel_frined_seled";
            break;
        case MST_Selected:
            imageName = @"sel_friend_sel";
            break;
    }
    _selectImgView.image = [UIImage imageNamed:imageName];
}

- (void)setName:(NSString *)name{
    _nameLabel.text = name;
}


@end
