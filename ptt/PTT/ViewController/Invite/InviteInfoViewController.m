//
//  InviteInfoViewController.m
//  PTT
//
//  Created by xihan on 15/6/24.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import "InviteInfoViewController.h"

@interface InviteInfoViewController ()
{
    UILabel *_nameLabel, *_stateLabel;
    UITextView *_textView;
}
@end

@implementation InviteInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTopBar];
    [self setupBaseView];
}

- (void)setupTopBar{
    PttTopBar *topBar = [[PttTopBar alloc] initWithTitle:@"邀请信息"];
    [self.view addSubview:topBar];
    WEAKSELF;
    topBar.backBlock = ^(){
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
     _textView.text = _note;
    _nameLabel.text = _name;
    if (_invtiteType == IT_DISAGREE) {
        _stateLabel.text = @"状态:拒绝了你的请求";
    }
    else{
        _stateLabel.text = @"状态:等待对方同意";
    }
}

- (void)setupBaseView{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(25, 83, 60, 60)];
    imageView.image = [UIImage imageNamed:@"friend_online"];
    [self.view addSubview:imageView];
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(MaxX(imageView) + 5, Y(imageView), 200, 30)];
    _nameLabel.textColor = [UIColor blackColor];
    _nameLabel.font = [UIFont systemFontOfSize:20];
    [self.view addSubview:_nameLabel];
    
    _stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(X(_nameLabel), MaxY(_nameLabel), WIDTH(_nameLabel), HEIGHT(_nameLabel))];
    _stateLabel.textColor = [UIColor grayColor];
    _stateLabel.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:_stateLabel];
    
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(20, 157, Main_Screen_Width - 40, 79)];
    _textView.scrollEnabled = NO;
    _textView.userInteractionEnabled = NO;
    _textView.font = [UIFont systemFontOfSize:17];
    _textView.textColor = [UIColor blackColor];
    ViewBorderRadius(_textView, 5, 1, [UIColor groupTableViewBackgroundColor]);
    [self.view addSubview:_textView];
}


@end
