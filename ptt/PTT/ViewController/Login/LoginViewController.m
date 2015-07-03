//
//  LoginViewController.m
//  PTT
//
//  Created by RenHongwei on 15/5/14.
//  Copyright (c) 2015年 ShunTong. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "AppDelegate.h"
#import "PttService.h"
#import "UDManager.h"
#import "NSString+Extension.h"
#import "RecordManager.h"
#import "UpdateManager.h"

@interface LoginViewController ()<UITextFieldDelegate, PttServiceDelegate>
{
    PttService *pttService;
    NSString *_filePath;
}

@property (strong, nonatomic) IBOutlet UIButton *loginBtn;

@property (strong, nonatomic) IBOutlet UITextField *phoneTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation LoginViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self addBackgroundTap];
    
    _passwordTextField.delegate = self;
    _phoneTextField.delegate = self;
    
    NSString *uid = [UDManager getUserId];
    NSRange range = [uid rangeOfString:@"@"];
    NSString *uid2  = [uid substringToIndex:range.location];
    _phoneTextField.text = uid2;
    _passwordTextField.text = [UDManager getPassword];
    
    pttService = [PttService sharedInstance];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self hideKeyBoard];
    
    pttService.delegate = self;
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
        selector:@selector(textFieldDidChange:)
            name:UITextFieldTextDidChangeNotification
          object:nil
     ];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self hideKeyBoard];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    pttService.delegate = nil;
}


- (void)textFieldDidChange:(NSNotification *)noti{
    
    if ( _phoneTextField.text.length > 0 &&  _passwordTextField.text.length > 0 )
    {
        _loginBtn.enabled = YES;
        [_loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_loginBtn setTitleColor:[UIColor groupTableViewBackgroundColor] forState:UIControlStateHighlighted];
    }
    else
    {
        _loginBtn.enabled = NO;
        [_loginBtn setTitleColor:[UIColor groupTableViewBackgroundColor] forState:UIControlStateNormal];
    }
}


- (IBAction)loginBtnClick:(UIButton *)sender{
    [self hideKeyBoard];
    if (![_phoneTextField.text isMobileNumber]) {
        DLog(@"非电话号码!!!");
       // return;
    }
    
//    [RecordManager startRecord];
//    return;
    
     PTT_StartLoadingAnimation();
    [HttpManager loginWithUserId:_phoneTextField.text
                        password:_passwordTextField.text
                         handler:^(NSDictionary *dataDic){

        if (!PttDicResult(dataDic)) {
            PTT_StopLoadingAnimation();
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:PttDicMsg(dataDic) message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }

    }];
}

- (void)PttS_recvLoginResult:(NSDictionary *)dic{
    PTT_StopLoadingAnimation();
    if (PttDicResult(dic) == ACK_OK) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"login" object:self];
        
        [UpdateManager updateGroupList];
        [UpdateManager updateFriendList];
        
        MAIN(^{
            [self.navigationController popToRootViewControllerAnimated:NO];
        });    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:PttDicMsg(dic) message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}


- (IBAction)registerBtnClick:(UIButton *)sender {
//    [RecordManager stopRecord:^(BOOL flat,NSString *fileName, NSString *filePath, NSTimeInterval recordDur) {
//        DLog(@"\n==============\n    name:%@\n    path:%@\n    dur:%.2f\n==============\n",fileName, filePath, recordDur);
//        _filePath = filePath;
////        [HttpManager uploadFileByFilePath:filePath handler:^(NSDictionary *dataDic) {
////            DLog(@"\n==============\n%@\n==============\n",dataDic);
////        }];
//    }];
    [self hideKeyBoard];
    RegisterViewController *registerViewController = [[RegisterViewController alloc] initWithNibName:@"RegisterViewController" bundle:nil];
    [self.navigationController pushViewController:registerViewController animated:YES];
}



- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    switch (textField.tag) {
        case 0:
            [_passwordTextField becomeFirstResponder];
            break;
        case 1:
            [textField resignFirstResponder];
            break;
    }
    return YES;
}

- (void)addBackgroundTap{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)];
    tap.cancelsTouchesInView = NO;
    [tap setNumberOfTouchesRequired:1];
    [self.view addGestureRecognizer:tap];
}

- (void)hideKeyBoard{
    [_phoneTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (IBAction)forgetPwd:(id)sender {
//    NSString *ser = @"耗尽";
//    DLog(@"%@",[ser firstLetter]);
//    [RecordManager playWithFilePath:_filePath complete:^{
//        DLog(@"done");
//    }];

//    [HttpManager downloadFileByFileName:[_filePath lastPathComponent] handler:^(NSDictionary *dataDic) {
//        if (PttDicResult(dataDic) == ACK_OK) {
//            [RecordManager playWithFilePath:PttDicMsg(dataDic) complete:^{
//                DLog(@"done");
//            }];
//        }
//    }];
    
}

@end
