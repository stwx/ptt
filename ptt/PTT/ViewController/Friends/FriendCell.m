//
//  FriendCell.m
//  PTT
//
//  Created by xihan on 15/7/7.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import "FriendCell.h"

const CGFloat kCellHeight = 55;

@implementation FriendCell
{
    UIImageView *_headImgView;
    UILabel *_nameLabel, *_phoneLabel;
}

+ (FriendCell *)dequeueReusableCellFromTableView:(UITableView *)tableView{
    FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendCell"];
    if (cell == nil) {
        cell = [[FriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FriendCell"];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _headImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, kCellHeight - 10, kCellHeight - 10)];
        [self.contentView addSubview:_headImgView];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(MaxX(_headImgView) + 5, 5, Main_Screen_Width - 120, HEIGHT(_headImgView) * 0.5)];
        _nameLabel.textColor = [UIColor blackColor];
        _nameLabel.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:_nameLabel];
        
        _phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(X(_nameLabel), MaxY(_nameLabel), WIDTH(_nameLabel), HEIGHT(_nameLabel))];
        _phoneLabel.textColor = [UIColor grayColor];
        _phoneLabel.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:_phoneLabel];
    }
    return self;
}

+ (CGFloat)cellHeight{
    return kCellHeight;
}


- (void)setStatus:(int)status{
    NSString *imgName = status ? @"home_friend_online" : @"home_friend_offline";
    _headImgView.image = [UIImage imageNamed:imgName];
}

- (void)setName:(NSString *)name{
    _nameLabel.text = name;
}

- (void)setPhone:(NSString *)phone{
    NSRange range = [phone rangeOfString:@"@"];
    if (NSNotFound != range.location) {
        phone = [phone substringToIndex:range.location];
    }
    _phoneLabel.text = phone;
}

@end
