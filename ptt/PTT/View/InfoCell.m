//
//  InfoCell.m
//  PTT
//
//  Created by xihan on 15/6/14.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import "InfoCell.h"

@implementation InfoCell

{
    UIImageView *_headImgView;
    UILabel *_nameLabel;
}

+ (InfoCell *)dequeueReusableCellFromTableView:(UITableView *)tableView{
    InfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"info"];
    if (cell == nil) {
        cell = [[InfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"info"];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _headImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 40, 40)];
        [self.contentView addSubview:_headImgView];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(56, 14, Main_Screen_Width - 120, 21)];
        _nameLabel.textColor = [UIColor blackColor];
        _nameLabel.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:_nameLabel];
    }
    return self;
}

+ (CGFloat)cellHeight{
    return 50;
}

- (void)setHeadType:(InfoCellHeadType)headType{
    NSString *imgName;
    switch (headType) {
        case InfoCell_FriendOnline:
            imgName = @"home_friend_online";
            break;
        case InfoCell_FriendOffline:
            imgName = @"home_friend_offline";
            break;
        case InfoCell_Group:
            imgName = @"home_group";
            break;
    }
    _headImgView.image = [UIImage imageNamed:imgName];
}

- (void)setName:(NSString *)name{
    _nameLabel.text = name;
}


@end
