//
//  ChatTextView.m
//  PTT
//
//  Created by xihan on 15/6/10.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import "ChatTextView.h"

@implementation ChatTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        //语音
        _durLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 70, 30)];
        _durLabel.textAlignment = NSTextAlignmentCenter;
        _durLabel.font = [UIFont systemFontOfSize:15];
        _durLabel.textColor = [UIColor whiteColor];
        [self addSubview:_durLabel];
        
        _voice = [[UIImageView alloc]initWithFrame:CGRectMake(WIDTH(self) - 40, (HEIGHT(self) - 20 ) * 0.5, 20, 20)];
        [self addSubview:_voice];
        
        _voice.backgroundColor = [UIColor clearColor];
        _durLabel.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setFromSelf:(BOOL)fromSelf{
    NSArray *animationArray;
    CGRect voiceFrame, durFrame;
    if (fromSelf) {
       
        _voice.image = [UIImage imageNamed:@"chat_animation_me3"];
        animationArray =
        @[
          [UIImage imageNamed:@"chat_animation_me1"],
          [UIImage imageNamed:@"chat_animation_me2"],
          [UIImage imageNamed:@"chat_animation_me3"]
          ];
        voiceFrame = CGRectMake(WIDTH(self) - 40, (HEIGHT(self) - 20 ) * 0.5, 20, 20);
        durFrame = CGRectMake(CGRectGetMidX(voiceFrame) - 40, 0, 30, HEIGHT(self));
    }else{

        _voice.image = [UIImage imageNamed:@"chat_animation_other3"];
        animationArray =
        @[
          [UIImage imageNamed:@"chat_animation_other1"],
          [UIImage imageNamed:@"chat_animation_other2"],
          [UIImage imageNamed:@"chat_animation_other3"]
          ];
        voiceFrame = CGRectMake( 40, (HEIGHT(self) - 20 ) * 0.5, 20, 20);
        durFrame = CGRectMake(CGRectGetMaxX(voiceFrame) + 10, 0, 30, HEIGHT(self));
    }
    _voice.frame = voiceFrame;
    _durLabel.frame = durFrame;
    _voice.animationImages = animationArray;
    _voice.animationDuration = 1;
    _voice.animationRepeatCount = 0;
}

- (void)startPlayAnimating{
    [_voice startAnimating];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_dur * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [_voice stopAnimating];
    });
}

- (void)stopPlayAnimating{
    [_voice stopAnimating];
}
- (void)setDur:(float)dur{
    _dur = dur;
    _durLabel.text = [NSString stringWithFormat:@"%.1fs",dur];
}

//添加
- (BOOL)canBecomeFirstResponder{
    return YES;
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    return (action == @selector(copy:));
}

-(void)copy:(id)sender{
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = self.titleLabel.text;
}



@end
