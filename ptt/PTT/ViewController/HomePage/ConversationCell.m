//
//  ConversationCell.m
//  PTT
//
//  Created by xihan on 15/6/1.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import "ConversationCell.h"
#import "Conversation.h"

#import "NSDate+Extension.h"

@implementation ConversationCell{
    UIImageView *_headImgView, *_unreadPoint;
    UILabel *_nameLabel, *_detailLabel, *_timeLabel, *_unreadCount;
}


+ (ConversationCell *)dequeueReusableCellFromTableView:(UITableView *)tableView{
    ConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"conversation"];
    if (cell == nil) {
        cell = [[ConversationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"conversation"];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _headImgView = [[UIImageView alloc] initWithFrame:CGRectMake(13, 10, 50, 50)];
        [self.contentView addSubview:_headImgView];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 15, Main_Screen_Width - 80, 21)];
        _nameLabel.textColor = [UIColor blackColor];
        _nameLabel.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:_nameLabel];
        
        _detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 37, Main_Screen_Width - 80, 21)];
        _detailLabel.textColor = [UIColor grayColor];
        _detailLabel.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:_detailLabel];
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(Main_Screen_Width - 100, 20, 90, 21)];
        _timeLabel.textColor = [UIColor grayColor];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _timeLabel.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:_timeLabel];
        
        _unreadPoint = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        _unreadPoint.center = CGPointMake(MaxX(_headImgView)-5, Y(_headImgView)+5);
        _unreadPoint.image = [UIImage imageNamed:@"chat_unread"];
        [self.contentView addSubview:_unreadPoint];
        
        _unreadCount = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        _unreadCount.center = _unreadPoint.center;
        _unreadCount.textColor = [UIColor whiteColor];
        _unreadCount.font = [UIFont systemFontOfSize:14];
        _unreadCount.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_unreadCount];
    }
    return self;
}

-(void)setConversation:(Conversation *)conversation{
    int conversationType = [conversation.conversationType intValue];
    
    NSString *imgName;
    if (conversationType == CT_GROUP_CHAT) {
        imgName = @"home_group";
    }
    else{
        imgName = @"home_friend_online";
    }
    _timeLabel.text = [conversation.date conversationDataString];
    _headImgView.image = [UIImage imageNamed:imgName];
    _nameLabel.text = conversation.title;
    _detailLabel.text = conversation.detail;
    
    int unreadCount = [conversation.unreadCount intValue];
    
    if (unreadCount == 0) {
        _unreadPoint.hidden = YES;
        _unreadCount.hidden = YES;
    }
    else{
        _unreadPoint.hidden = NO;
        _unreadCount.hidden = NO;
        _unreadCount.text = IntTranslateStr(unreadCount);
    }
}

+ (CGFloat)cellHeight{
    return 70;
}

@end
