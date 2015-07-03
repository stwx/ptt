//
//  ChatCellFrameModel.m
//  PTT
//
//  Created by xihan on 15/6/4.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import "ChatCellFrameModel.h"
#import "Message.h"
#import "NSString+Extension.h"

const CGFloat padding       =   10;
const CGFloat textPadding   =   10;
const CGFloat iconW         =   50;

@implementation ChatCellFrameModel


-(void)setMessage:(Message *)message{
    
    _message = message;
    
    BOOL fromSelf = [message.fromSelf boolValue];
    int msgType = [message.msgType intValue];
    
    //时间
    CGFloat timeH = _showTime ? 20 : 0;
    _timeFrame = CGRectMake(0, 5, Main_Screen_Width, timeH);
    
    //头像
    CGFloat iconX = !fromSelf ? padding: Main_Screen_Width - padding - iconW;
    CGFloat iconY = CGRectGetMaxY(_timeFrame);
    _iconFrame = CGRectMake(iconX, iconY, iconW, iconW);
    
    //昵称
    CGFloat nameX = fromSelf ? 9 : CGRectGetMaxX(_iconFrame) + 3;
    CGFloat nameY = iconY;
    CGFloat nameW = Main_Screen_Width - iconW - 2.5 * padding;
    CGFloat nameH = 21;
    _nameFrame = CGRectMake(nameX, nameY, nameW, nameH);
    
    //对话框
    CGFloat textFrameY = CGRectGetMaxY(_nameFrame);
    CGFloat textFrameX;
    
    if ( msgType == MSG_TEXT ) {
        /**
         文字
         **/
        CGSize textSize = [message.msg sizeWithFont:[UIFont systemFontOfSize:16] andWidth:Main_Screen_Width * 0.5];
        CGSize textRealSize = CGSizeMake(textSize.width + textPadding * 4, textSize.height );
        
        textFrameX = fromSelf ? (Main_Screen_Width - (padding * 2 + iconW + textRealSize.width)) : nameX ;
        
        _textFrame = (CGRect){textFrameX, textFrameY, textRealSize};
    }
    else if  ( msgType == MSG_RECORD ){
        /**
         录音
         **/
        textFrameX = fromSelf ? (Main_Screen_Width - (padding * 2 + iconW + Main_Screen_Width*0.4 )) : nameX;
        CGSize textSize = CGSizeMake(Main_Screen_Width*0.4, 40);
        _textFrame = (CGRect){textFrameX, textFrameY, textSize};
        //DLog(@"\n=============\nMessage_Type_Record:\n{   X:%f,\n    Y:%f\n    W:%f\n    H:%f\n}\n=============\n",textFrameX, textFrameY, textSize.width, textSize.height);
    }
    else if ( msgType == MSG_TALK ){
        CGSize textSize = [message.msg sizeWithFont:[UIFont systemFontOfSize:16] andWidth:Main_Screen_Width * 0.5];
        CGSize textRealSize = CGSizeMake(textSize.width + textPadding * 4, textSize.height + 5 );
        
        textFrameX = fromSelf ? (Main_Screen_Width - (padding * 2 + iconW + textRealSize.width)) : nameX ;
        
        _textFrame = (CGRect){textFrameX, CGRectGetMidY(_iconFrame) - (textRealSize.height * 0.5), textRealSize};
    }
    
    //未读红点
    if ( msgType && !fromSelf  ) {
        _pointFrame = CGRectMake(CGRectGetMaxX(_textFrame)+5, CGRectGetMinY(_textFrame) + 15, 10, 10);
    }
    
    //发送失败按钮
    if (fromSelf) {
        _failBtnFrame = CGRectMake(CGRectGetMinX(_textFrame) - 25,CGRectGetMidY(_textFrame)-10, 25, 25);
    }
    
    //4.cell的高度
    _cellHeght =  CGRectGetMaxY(_textFrame) + padding;
}


@end
