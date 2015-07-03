//
//  PttTopBar.m
//  PTT
//
//  Created by xihan on 15/6/6.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import "PttTopBar.h"

@implementation PttTopBar{
    UILabel * _titleLabel;
    UIButton *_backButton;
    UIImageView *_backArrow;
}

- (instancetype)initWithTitle:(NSString *)title{
    self = [ super initWithFrame:CGRectMake(0, 0, Main_Screen_Width, 64) ];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        
        UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(Main_Screen_Width * 0.5 - 100, 31, 200, 21)];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont systemFontOfSize:17];
        titleLabel.text = title;
        _titleLabel = titleLabel;
        [self addSubview:titleLabel];
        
        
        UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(-10, 26, 80, 30)];
        [backBtn setImage:[UIImage imageNamed:@"arrow"] forState:UIControlStateNormal];
        [backBtn setTitle:@"返回" forState:UIControlStateNormal];
        [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(backToSuperView) forControlEvents:UIControlEventTouchUpInside];
        backBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        [self addSubview:backBtn];
    }
    return self;
}

- (void)changeTitle:(NSString *)title{
    _titleLabel.text = title;
}

- (void)backToSuperView{
    if ([_delegate respondsToSelector:@selector(backToSuperView)]) {
        [_delegate backToSuperView];
    }
    if (self.backBlock) {
        self.backBlock();
    }
}

@end
