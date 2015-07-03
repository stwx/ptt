//
//  PTTInputView.m
//  PTT
//
//  Created by xihan on 15/6/23.
//  Copyright (c) 2015年 stwx. All rights reserved.
//


#import "PTTInputView.h"
#import "NSString+Extension.h"
#import "PttRecordHUD.h"
#import "UDManager.h"

typedef enum {
    Input_Type_Text,
    Input_Type_Record,
    Input_Type_Talk
}InputType;


@interface PTTInputView()<UITextViewDelegate>{
    
    UIButton *_leftBtn, *_rightBtn, *_middleBtn;
    UITextView *_textView;
    NSTimer *_enableTimer;
    NSTimeInterval _currTime, _timeout;
    BOOL _working;
    int _inputType;
}

@end

@implementation PTTInputView


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _inputType = Input_Type_Text;
        self.backgroundColor = [UIColor whiteColor];
        
        //分割线
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Main_Screen_Width, 1)];
        [self addSubview:line];
        line.backgroundColor = [UIColor groupTableViewBackgroundColor];
        
        //左边按钮
        _leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 5, 40, 40)];
        [_leftBtn setBackgroundImage:[UIImage imageNamed:@"chat_status_change"] forState:UIControlStateNormal];
        [_leftBtn addTarget:self action:@selector(leftBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_leftBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self addSubview:_leftBtn];
        
        //右边按钮
        _rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(Main_Screen_Width - 50, 5, 40, 40)];
        [_rightBtn setBackgroundImage:[UIImage imageNamed:@"chat_status_change"] forState:UIControlStateNormal];
        [_rightBtn addTarget:self action:@selector(rightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        _rightBtn.enabled = NO;
        [self addSubview:_rightBtn];
        
        //中间输入框
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_leftBtn.frame) + 10, 5, Main_Screen_Width - CGRectGetMaxX(_leftBtn.frame) - 10 - WIDTH(_rightBtn) - 20, 40)];
        _textView.delegate = self;
        ViewBorderRadius(_textView, 5, 1, [UIColor groupTableViewBackgroundColor]);
        _textView.font = [UIFont systemFontOfSize:18];
        _textView.delegate = self;
        [self addSubview:_textView];
        
        //留言 && 对讲按钮
        _middleBtn = [[UIButton alloc] initWithFrame:_textView.frame];
        [_middleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_middleBtn addTarget:self action:@selector(middleBtnPress:) forControlEvents:UIControlEventTouchDown];
        [_middleBtn addTarget:self action:@selector(middleBtnRelease:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        _middleBtn.hidden = YES;
        
        [self addSubview:_middleBtn];
        [self setupInputView];
    }
    return self;
}

/**
 布局变更
 **/
- (void)setupInputView{
    
    switch (_inputType) {
            
        case Input_Type_Text:
        {
            _middleBtn.hidden = YES;
            _textView.hidden = NO;
            [_leftBtn setTitle:@"语音" forState:UIControlStateNormal];
            [_rightBtn setTitle:@"发送" forState:UIControlStateNormal];
            _rightBtn.enabled = ![_textView.text isNull];
            UIColor *color = [_textView.text isNull] ? [UIColor grayColor]:[UIColor blackColor];
            [_rightBtn setTitleColor:color forState:UIControlStateNormal];
        }
            break;
        case Input_Type_Record:
        {
            _middleBtn.hidden = NO;
            _textView.hidden = YES;
            _rightBtn.enabled = YES;
            [_leftBtn setTitle:@"文字" forState:UIControlStateNormal];
            [_rightBtn setTitle:@"对讲" forState:UIControlStateNormal];
            [_rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_middleBtn setTitle:@"按住语音留言" forState:UIControlStateNormal];
            [_middleBtn setTitle:@"松开发送留言" forState:UIControlStateHighlighted];
            [_middleBtn setBackgroundImage:[UIImage imageNamed:@"chat_recording"] forState:UIControlStateNormal];
            [self hideKeyBoard];
        }
            break;
        case Input_Type_Talk:
        {
            _middleBtn.hidden = NO;
            _textView.hidden = YES;
            _rightBtn.enabled = YES;
            [_leftBtn setTitle:@"文字" forState:UIControlStateNormal];
            [_rightBtn setTitle:@"留言" forState:UIControlStateNormal];
            [_rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_middleBtn setTitle:@"按住开始对讲" forState:UIControlStateNormal];
            [_middleBtn setTitle:@"松开结束对讲" forState:UIControlStateHighlighted];
            [_middleBtn setBackgroundImage:[UIImage imageNamed:@"chat_talking"] forState:UIControlStateNormal];
            [self hideKeyBoard];
        }
            break;
    }
}

/**
 左边按钮
 **/
- (void)leftBtnClick:(UIButton *)btn{
   
    if (_inputType == Input_Type_Talk) {
        if ([_delegate respondsToSelector:@selector(IV_TalkState:)]) {
            [_delegate IV_TalkState:NO];
        }
    }
    
    if (_inputType == Input_Type_Text) {
        _inputType = Input_Type_Record;
    }
    else{
        _inputType = Input_Type_Text;
    }
    
    [self setupInputView];
}

/**
 右边按钮
 **/
- (void)rightBtnClick:(UIButton *)btn{
    //发送
    if (_inputType == Input_Type_Text) {
        if ([_delegate respondsToSelector:@selector(IV_SendText:)]) {
            [_delegate IV_SendText:_textView.text];
            _textView.text = @"";
        }
    }
    //留言
    else if (_inputType == Input_Type_Record){
        _inputType = Input_Type_Talk;
        if ([_delegate respondsToSelector:@selector(IV_TalkState:)]) {
            [_delegate IV_TalkState:YES];
        }
    }else{
        _inputType = Input_Type_Record;
        if ([_delegate respondsToSelector:@selector(IV_TalkState:)]) {
            [_delegate IV_TalkState:NO];
        }
    }
    [self setupInputView];
}

/**
 录音/留言 按钮
 **/
- (void)middleBtnPress:(UIButton *)btn{
    _working = NO;
    if ( _inputType == Input_Type_Record ) {
        
        [self startEnableTimerWithTime:800];
    }
    else if (_inputType == Input_Type_Talk){
        
        [self startEnableTimerWithTime:500];
    }
}


- (void)middleBtnRelease:(UIButton *)btn{
    [self stopEnableTimer];
    if (!_working) {
        return;
    }
    if ( _inputType == Input_Type_Record ) {
        if ([_delegate respondsToSelector:@selector(IV_Record:)]) {
            [_delegate IV_Record:NO];
            DLog(@"Record cancel!!!");
            [PttRecordHUD dismissWithSuccess:nil];
        }
    }
    else if ( _inputType == Input_Type_Talk ){
        if ([_delegate respondsToSelector:@selector(IV_Talk:)]) {
            [_delegate IV_Talk:NO];
        }
    }
}

- (void)setMiddleBtnEnable:(BOOL)enable{
    _middleBtn.enabled = enable;
    [_middleBtn setTitleColor:enable?[UIColor whiteColor]:[UIColor grayColor] forState:UIControlStateNormal];
}

- (void)changeToTalkState{
    _inputType = Input_Type_Talk;
    [self setupInputView];
}

#pragma mark ----------- TextView Delegate -------------
- (void)textViewDidChange:(UITextView *)textView{
    _rightBtn.enabled = ![_textView.text isNull];
    UIColor *color = [_textView.text isNull] ? [UIColor grayColor]:[UIColor blackColor];
    [_rightBtn setTitleColor:color forState:UIControlStateNormal];
}

- (void)hideKeyBoard{
    [_textView resignFirstResponder];
}

#pragma mark ----------- Timer -------------
- (void)startEnableTimerWithTime:(NSTimeInterval)timeout{
    [self stopEnableTimer];
     _timeout = timeout;
    BACK(^{
        _currTime = 0;
       
        NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
        _enableTimer = [NSTimer timerWithTimeInterval:0.001 target:self selector:@selector(timerRun) userInfo:nil repeats:YES];
        [runLoop addTimer:_enableTimer forMode:NSDefaultRunLoopMode];
        [runLoop run];
    });
}

- (void)stopEnableTimer{
    _currTime = 0;
    [_enableTimer invalidate];
    _enableTimer = nil;
}

- (void)timerRun{
  //  DLog(@"timerRun:%.2f",_currTime);
    _currTime = _currTime + 1;
    if (_currTime == _timeout) {
        [self enableTimerTimeout];
    }
}

- (void)enableTimerTimeout{
    [self stopEnableTimer];
    MAIN(^{
        _working = YES;
        if ( _inputType == Input_Type_Record ) {
            
            if ([_delegate respondsToSelector:@selector(IV_Record:)]) {
                [_delegate IV_Record:YES];
                [PttRecordHUD showWithTimeoutBlock:^{
                    [_delegate IV_Record:NO];
                }];
            }
        }
        else if (_inputType == Input_Type_Talk){
            if ([_delegate respondsToSelector:@selector(IV_Talk:)]) {
                [_delegate IV_Talk:YES];
            }
        }
    });

}

@end
