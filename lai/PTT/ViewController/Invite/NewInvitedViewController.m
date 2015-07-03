//
//  InviteController.m
//  PTT
//
//  Created by xihan on 15/6/5.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import "NewInvitedViewController.h"
#import "DBManager.h"

@interface NewInvitedViewController ()
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UITextView *noteView;
@property (strong, nonatomic) IBOutlet UIButton *agreeBtn;
@property (strong, nonatomic) IBOutlet UIButton *disagreeBtn;

@end

@implementation NewInvitedViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    ViewBorderRadius(_noteView, 5, 1, [UIColor groupTableViewBackgroundColor]);
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _noteView.text = _note;
    _nameLabel.text = _name;
}

- (IBAction)agreeTheInvite:(UIButton *)sender {
    PTT_StartLoadingAnimation();
    [HttpManager agreeInvitedForFriendId:_uid Handler:^(NSDictionary *dataDic) {
        PTT_StopLoadingAnimation();
        if (PttDicResult(dataDic) == ACK_OK) {
            NSDictionary *ackDic = PttDicMsg(dataDic);
            NSDictionary *dic = @{ @"fuid":_uid, @"name":_name, @"fgid":ackDic[@"fgid"] };
            [DBManager saveAgreeInvitedConversationByDic:dic];
            [DBManager saveNewFriendByDic:dic];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}
- (IBAction)disagreeTheInvite:(UIButton *)sender {
    PTT_StartLoadingAnimation();
    [HttpManager disagreeInvitedForFriendId:_uid Notes:@" " Handler:^(NSDictionary *dataDic) {
        PTT_StopLoadingAnimation();
        [DBManager deleteConversationByUserId:_uid];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}


- (IBAction)backToSuperView:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}



@end
