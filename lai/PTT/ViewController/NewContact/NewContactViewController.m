//
//  AddContactController.m
//  PTT
//
//  Created by xihan on 15/6/5.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import "NewContactViewController.h"
#import "NSString+Extension.h"
#import "DBManager.h"
#import "UDManager.h"
@interface NewContactViewController ()<UITextFieldDelegate>
{
    UITextField *_uidTF, *_notTF;
    UIButton *_confirmBtn;
}
@property (strong, nonatomic) IBOutlet UITextField *uid;
@property (strong, nonatomic) IBOutlet UITextField *note;
//@property (strong, nonatomic) IBOutlet UIButton *confirmBtn;

@end

@implementation NewContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _uid.delegate = self;
    _note.delegate = self;
    [self addBackgroundTap];
    [self setupTopBar];
    [self setConfirmBtnEnable:NO];
}



- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _note.text = [NSString stringWithFormat:@"我是%@",[UDManager getUserName]];
    [self hideKeyBoard];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self hideKeyBoard];
}

- (void)setupTopBar{
    PttTopBar *topBar = [[PttTopBar alloc] initWithTitle:@"添加好友"];
    WEAKSELF;
    topBar.backBlock = ^(){
        [weakSelf .navigationController popViewControllerAnimated:YES];
    };
    [self.view addSubview:topBar];
}



- (void)textFieldDidEndEditing:(UITextField *)textField{
    BOOL enable = ![_uid.text isNull] && ![_note.text isNull];
    [self setConfirmBtnEnable:enable];
}


- (void)setConfirmBtnEnable:(BOOL)enable{
    _confirmBtn.enabled = enable;
    [_confirmBtn setTitleColor:enable? [UIColor whiteColor]:[UIColor grayColor] forState:UIControlStateNormal];
}


- (IBAction)confirm:(UIButton *)sender {
    [self hideKeyBoard];
    
    NSString *uid = [NSString stringWithFormat:@"%@@a",_uid.text];
    if ([DBManager isFriendExistedByUid:uid]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"你们已经是好友了!" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    PTT_StartLoadingAnimation();
    [HttpManager inviteFriendByFriendId:uid notes:_note.text handler:^(NSDictionary *dataDic) {
         PTT_StopLoadingAnimation();
        if (PttDicResult(dataDic) == ACK_OK) {

            NSDictionary *dic =
            @{
              @"name" : _uid.text,
              @"state" : @0,
              @"notes" : _note.text,
              @"uid" : [NSString stringWithFormat:@"%@@a",_uid.text]
              };
            [DBManager saveInviteOtherConversationByDic:dic];
            [self dismissViewControllerAnimated:YES completion:nil];
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:PttDicMsg(dataDic) message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
}

- (void)addBackgroundTap{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)];
    tap.cancelsTouchesInView = NO;
    [tap setNumberOfTouchesRequired:1];
    [self.view addGestureRecognizer:tap];
}

- (void)hideKeyBoard{
    [_uid resignFirstResponder];
    [_note resignFirstResponder];
}

@end
