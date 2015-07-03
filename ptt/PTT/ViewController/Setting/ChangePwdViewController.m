//
//  ChangePwdViewController.m
//  PTT
//
//  Created by xihan on 15/6/11.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import "ChangePwdViewController.h"
#import "UDManager.h"
#import "NSString+Extension.h"
#import "EstimateUtil.h"

@interface ChangePwdViewController ()
@property (strong, nonatomic) IBOutlet UITextField *oldPwd;
@property (strong, nonatomic) IBOutlet UITextField *mNewPwd;
@property (strong, nonatomic) IBOutlet UITextField *cNewPwd;

@end

@implementation ChangePwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}
- (IBAction)change:(id)sender {
    
    [_oldPwd resignFirstResponder];
    [_mNewPwd resignFirstResponder];
    [_cNewPwd resignFirstResponder];
    
    if ( [_oldPwd.text isNull] || [_mNewPwd.text isNull] || [_cNewPwd.text isNull]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"密码不能为空" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    if (![_oldPwd.text isEqualToString:[UDManager getPassword]]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"原始密码错误" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    if (![_cNewPwd.text isEqualToString:_mNewPwd.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"两次输入密码不一致" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    if (1 == [EstimateUtil pwdErrorTypeWithPwd:_cNewPwd.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"密码长度为6～10位" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    if (2 == [EstimateUtil pwdErrorTypeWithPwd:_cNewPwd.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"密码只能由数字或字母组成" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    [HttpManager changeOldPwd:_oldPwd.text toNewPwd:_mNewPwd.text handler:^(NSDictionary *dataDic) {
        if (PttDicResult(dataDic)) {
            [UDManager savePassword:_mNewPwd.text];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"修改成功" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:PttDicMsg(dataDic) message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
}
- (IBAction)back:(id)sender {
    [_oldPwd resignFirstResponder];
    [_mNewPwd resignFirstResponder];
    [_cNewPwd resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}



@end
