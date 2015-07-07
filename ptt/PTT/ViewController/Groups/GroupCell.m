//
//  GroupCell.m
//  PTT
//
//  Created by xihan on 15/7/7.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import "GroupCell.h"

const CGFloat kCellHeight = 55;

@implementation GroupCell

{
    UIImageView *_headImgView;
    UILabel *_nameLabel;
}

+ (GroupCell *)dequeueReusableCellFromTableView:(UITableView *)tableView{
    GroupCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GroupCell"];
    if (cell == nil) {
        cell = [[GroupCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GroupCell"];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _headImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, kCellHeight - 10, kCellHeight - 10)];
        _headImgView.image = [UIImage imageNamed:@"home_group"];
        [self.contentView addSubview:_headImgView];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(MaxX(_headImgView)+5, 0, Main_Screen_Width - 120, kCellHeight)];
        _nameLabel.textColor = [UIColor blackColor];
        _nameLabel.font = [UIFont systemFontOfSize:18];
        [self.contentView addSubview:_nameLabel];
    }
    return self;
}

+ (CGFloat)cellHeight{
    return kCellHeight;
}


- (void)setName:(NSString *)name{
    _nameLabel.text = name;
}




@end
