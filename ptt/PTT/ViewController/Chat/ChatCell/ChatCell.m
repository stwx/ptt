//
//  ChatCell.m
//  PTT
//
//  Created by xihan on 15/6/4.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import "ChatCell.h"
#import "ChatTextView.h"
#import "ChatCellFrameModel.h"
#import "Message.h"
#import "NSDate+Extension.h"
#import "UIImage+ResizeImage.h"

@implementation ChatCell{
    UIButton *_icoBtn, *_failBtn;
    ChatTextView *_textView;
    UILabel *_nameLabel, *_timeLabel;
    UIImageView *_unreadPoint;
    BOOL _playing;
}

+ (ChatCell *)dequeueReusableCellFromTableView:(UITableView *)tableView{
    ChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chat"];
    if ( cell == nil ) {
        cell = [[ChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"chat"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.backgroundColor = [UIColor clearColor];
    if (self) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.textColor = [UIColor grayColor];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:_timeLabel];
        
        _icoBtn = [[UIButton alloc] init];
        [_icoBtn setImage: [UIImage imageNamed:@"chat_head"] forState:UIControlStateNormal];
        [self.contentView addSubview:_icoBtn];
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = [UIColor grayColor];
        _nameLabel.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:_nameLabel];
        
        _textView = [ChatTextView buttonWithType:UIButtonTypeCustom];
        _textView.titleLabel.numberOfLines = 0;
        _textView.titleLabel.font = [UIFont systemFontOfSize:16];
        _textView.contentEdgeInsets = UIEdgeInsetsMake(textPadding,1.5*textPadding, textPadding, 1.5*textPadding);
        [_textView addTarget:self action:@selector(textViewClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_textView];
        
        _failBtn = [UIButton buttonWithType:UIButtonTypeInfoLight];
        [_failBtn setTintColor:[UIColor redColor]];
        [self.contentView addSubview:_failBtn];
        
        _unreadPoint = [[UIImageView alloc] init];
        _unreadPoint.image = [UIImage imageNamed:@"chat_unread"];
        _unreadPoint.hidden = YES;
        [self.contentView addSubview:_unreadPoint];
    
    }
    return self;
}

- (void)setTag:(NSInteger)tag{
    _textView.tag = tag;
}

- (void)setCellFrame:(ChatCellFrameModel *)cellFrame{
    _cellFrame = cellFrame;
    
    _timeLabel.hidden = !cellFrame.showTime ;
    _timeLabel.frame = cellFrame.timeFrame;
    _textView.frame = cellFrame.textFrame;
    _nameLabel.frame = cellFrame.nameFrame;
    _icoBtn.frame = cellFrame.iconFrame;
    _unreadPoint.frame = cellFrame.pointFrame;
    _failBtn.frame = cellFrame.failBtnFrame;
    
    Message *message = cellFrame.message;
    
    BOOL fromSelf = [message.fromSelf boolValue];
    int msgType = [message.msgType intValue];
    
    _nameLabel.textAlignment = fromSelf ? NSTextAlignmentRight:NSTextAlignmentLeft;
    
    _failBtn.hidden = YES;
    
    UIColor *textColor;
    NSString *imageName, *text;
    
    if ( msgType == MSG_TEXT ) {
        textColor = [UIColor blackColor];
        imageName = fromSelf ? @"chat_text_right" : @"chat_text_left";
        _textView.voice.hidden = YES;
        _textView.durLabel.hidden = YES;
        _unreadPoint.hidden = YES;
        text = message.msg;
    }
    else if ( msgType == MSG_RECORD ){
        textColor = [UIColor whiteColor];
        imageName = fromSelf ? @"chat_record_right" : @"chat_record_left";
        text = nil;
       
        _textView.fromSelf = fromSelf;
        _textView.voice.hidden = NO;
        _textView.durLabel.hidden = NO;
        _textView.dur = [message.recordDur floatValue];
        _unreadPoint.hidden = ![message.unread boolValue];
    }

    else if ( msgType == MSG_TALK ){
        textColor = [UIColor whiteColor];
        imageName =  fromSelf ? @"chat_talk_right" : @"chat_talk_left";
        _textView.voice.hidden = YES;
        _textView.durLabel.hidden = YES;
        _failBtn.hidden = YES;
        _unreadPoint.hidden = YES;
        text = message.msg;
    }
    
    [_textView setTitle:text forState:UIControlStateNormal];
    [_textView setTitleColor:textColor forState:UIControlStateNormal];
    [_textView setBackgroundImage:[UIImage resizeImage:imageName] forState:UIControlStateNormal];
   
    _nameLabel.text = message.senderName;
    _timeLabel.text = [message.date msgDateString];
}

- (void)textViewClick:(UIButton *)btn{
    Message *message = _cellFrame.message;
    
    int msgType = [ message.msgType intValue ];
    
    if ( msgType == MSG_RECORD ) {
        if (_playing) {
            [self stopPlayAnimating];
        }
        else{
            [self startPlayAnimating];
        }
        if ([_delegate respondsToSelector:@selector(ChatCell_playRecordByIndex:play:)]) {
          
            [_delegate ChatCell_playRecordByIndex:btn.tag play:_playing ];
        }
    }
    else if ( msgType == MSG_TEXT){
        [_textView becomeFirstResponder];
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu setTargetRect:_textView.frame inView:_textView.superview];
        [menu setMenuVisible:YES animated:YES];
    }
}

- (void)startPlayAnimating{
    _playing = YES;
    [_textView startPlayAnimating];
}

- (void)stopPlayAnimating{
    _playing = NO;
    [_textView stopPlayAnimating];
}

@end

