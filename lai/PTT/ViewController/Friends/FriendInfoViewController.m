//
//  FriendInfoViewController.m
//  PTT
//
//  Created by xihan on 15/6/6.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import "FriendInfoViewController.h"
#import "ChatViewController.h"
#import "DBManager.h"

@interface FriendInfoViewController ()<UIActionSheetDelegate>
@property (strong, nonatomic) IBOutlet UIButton *joinTalkBtn;
@property (strong, nonatomic) IBOutlet UIButton *deleteFriendBtn;

@property (strong, nonatomic) IBOutlet UITextField *nameTF;

@end

@implementation FriendInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _nameTF.placeholder = _name;
}

- (IBAction)joinTalk:(UIButton *)sender {
    ChatViewController *chatViewController = [[ChatViewController alloc] init];
    chatViewController.chatName = _name;
    chatViewController.gid = _gid;
    chatViewController.viewType = VT_FRIEND;
    [self.navigationController pushViewController:chatViewController animated:YES];
}

- (IBAction)deleteFriend:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除好友" otherButtonTitles:nil, nil];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 0) {
        PTT_StartLoadingAnimation();
        [HttpManager deleteFriendByFriendGroupId:_gid Handler:^(NSDictionary *dataDic) {
            if (PttDicResult(dataDic)) {
                [DBManager deleteMessagesByGroupId:_gid];
                [DBManager deleteConversationByGroupId:_gid];
                [DBManager deleteFriendByGid:_gid];
            }
            PTT_StopLoadingAnimation();
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
}

- (IBAction)backToSuperView:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)remark:(UIButton *)sender {
    if ([sender.titleLabel.text isEqualToString:@"备注"]) {
        _nameTF.enabled = YES;
        [_nameTF becomeFirstResponder];
        [sender setTitle:@"确定" forState:UIControlStateNormal];
        [sender setBackgroundImage:[UIImage imageNamed:@"remark_cancel"] forState:UIControlStateNormal];
        [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }else{
        _nameTF.enabled = NO;
        _nameTF.placeholder = _nameTF.text;
        [_nameTF resignFirstResponder];
        [sender setTitle:@"备注" forState:UIControlStateNormal];
        [sender setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [sender setBackgroundImage:[UIImage imageNamed:@"remark"] forState:UIControlStateNormal];
    }
}

@end
