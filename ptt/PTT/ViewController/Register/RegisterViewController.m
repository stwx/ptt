//
//  RegisterViewController.m
//  PTT
//
//  Created by xihan on 15/5/20.
//  Copyright (c) 2015年 ShunTong. All rights reserved.
//

#import "RegisterViewController.h"
#import "AnimationUtil.h"
#import "HttpManager.h"
#import "UDManager.h"
#import "PttService.h"
#import "NSString+Extension.h"
#import "EstimateUtil.h"

@interface RegisterViewController ()<UITextFieldDelegate, UIAlertViewDelegate, PttServiceDelegate>{
    PttService *pttService;
}
@property (strong, nonatomic) IBOutlet UIView *inputView;
@property (strong, nonatomic) IBOutlet UITextField *phoneTextField;
@property (strong, nonatomic) IBOutlet UITextField *pwd;
@property (strong, nonatomic) IBOutlet UITextField *confirmPwd;
@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (strong, nonatomic) IBOutlet UILabel *nameErrorLabel;
@property (strong, nonatomic) IBOutlet UILabel *phoneNumErrorLabel;
@property (strong, nonatomic) IBOutlet UILabel *pwdErrorLable;
@property (strong, nonatomic) IBOutlet UILabel *cPwdErrorLabel;
@property (strong, nonatomic) IBOutlet UIButton *nameErrorBtn;
@property (strong, nonatomic) IBOutlet UIButton *phoneNumErrorBtn;
@property (strong, nonatomic) IBOutlet UIButton *pwdErrorBtn;
@property (strong, nonatomic) IBOutlet UIButton *cPwdErrorBtn;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackgroundTap];
    
    _phoneTextField.delegate = self;
    _pwd.delegate = self;
    _confirmPwd.delegate = self;
    _nameTextField.delegate = self;
    
    _nameErrorBtn.hidden = YES;
    _nameErrorLabel.hidden = YES;
    
    _pwdErrorBtn.hidden = YES;
    _pwdErrorLable.hidden = YES;
    
    _phoneNumErrorBtn.hidden = YES;
    _phoneNumErrorLabel.hidden = YES;
    
    _cPwdErrorBtn.hidden = YES;
    _cPwdErrorLabel.hidden = YES;
    
    pttService = [PttService sharedInstance];
   
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self hideKeyBoard];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillHideNotification object:nil];
    pttService.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self hideKeyBoard];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    pttService.delegate = nil;
}


-(void)keyboardChange:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardEndFrame;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];

    _topConstraint.constant = 0;
    _bottomConstraint.constant = 0;
    
    [self.view layoutIfNeeded];
    
    [UIView commitAnimations];
    
}



- (IBAction)back:(UIButton *)sender {
    [AnimationUtil addPopAnimationToNavitonController:self.navigationController Type:kCATransitionReveal subType:kCATransitionFromBottom];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)registerBtnClick:(UIButton *)sender {
    [self hideKeyBoard];
    if ([_pwd.text isEqualToString:_confirmPwd.text]) {
    
        PTT_StartLoadingAnimation();
        
        [HttpManager registerWithUserId:_phoneTextField.text password:_pwd.text handler:^(NSDictionary *dataDic) {
            PTT_StopLoadingAnimation();
            if (PttDicResult(dataDic)) {
                
                NSString *alertTitle = PttDicMsg(dataDic);
                DLog(@"%@",dataDic);
                [HttpManager changeToNewNikename:_nameTextField.text handler:^(NSDictionary *dataDic) {
                     DLog(@"%@",dataDic);
                    
                    [HttpManager loginWithUserId:_phoneTextField.text password:_pwd.text handler:^(NSDictionary *dataDic) {
                    }];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alert show];
                }];
                
            }else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:PttDicMsg(dataDic)  message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
            }
        }];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"两次输入的密码不一致" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (IBAction)inputFormatError:(UIButton *)sender {
    switch (sender.tag) {
        case 0:
            _nameErrorLabel.hidden = !_nameErrorLabel.hidden;
            break;
        case 1:
            _phoneNumErrorLabel.hidden = ! _phoneNumErrorLabel.hidden;
            break;
        case 2:
            _pwdErrorLable.hidden = !_pwdErrorLable.hidden;
            break;
        case 3:
            _cPwdErrorLabel.hidden = !_cPwdErrorLabel.hidden;
            break;
            
        default:
            break;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    NSString *str = textField.text;
    switch (textField.tag) {
        case 0:
        {
            if (textField.text.length > 10 ) {
                _nameErrorBtn.hidden = NO;
                _nameErrorLabel.text = @"长度不能超过10位";
            }
            else if (textField.text == nil){
                _nameErrorBtn.hidden = NO;
                _nameErrorLabel.text = @"不能为空";
            }
            else if ([EstimateUtil haveIllegalChar:str]){
                _nameErrorBtn.hidden = NO;
                _nameErrorLabel.text = @"含有非法字符";
            }
            else{
                _nameErrorBtn.hidden = YES;
            }
        }
            break;
            
        case 1:
        {
            if ([textField.text isMobileNumber]) {
                _phoneNumErrorBtn.hidden = YES;
            }
            else{
                _phoneNumErrorBtn.hidden = NO;
            }
        }
            break;
        case 2:
        {
            int errorType = [EstimateUtil pwdErrorTypeWithPwd:textField.text];
            if (errorType == 0) {
                _pwdErrorBtn.hidden = YES;
            }
            else if (errorType == 1){
                _pwdErrorBtn.hidden = NO;
                _pwdErrorLable.text = @"密码长度为6~8位";

            }
            else if (errorType == 2){
                _pwdErrorBtn.hidden = NO;
                _pwdErrorLable.text = @"密码只能由数字或字母组成";
            }
        }
            break;
        case 3:
        {
            if ([_pwd.text isEqualToString:_confirmPwd.text]) {
                _cPwdErrorBtn.hidden = YES;
            }
            else{
                _cPwdErrorBtn.hidden = NO;
            }
        }
            break;
        default:
            break;
    }
}

- (void)addBackgroundTap{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)];
    tap.cancelsTouchesInView = NO;
    [tap setNumberOfTouchesRequired:1];
    [self.inputView addGestureRecognizer:tap];
}

- (void)hideKeyBoard{
    [_phoneTextField resignFirstResponder];
    [_confirmPwd resignFirstResponder];
    [_pwd resignFirstResponder];
    [_nameTextField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    switch (textField.tag) {
        case 0:
            [_phoneTextField becomeFirstResponder];
            break;
        case 1:
            [_pwd becomeFirstResponder];

            break;
        case 2:
            [_confirmPwd becomeFirstResponder];

            break;
        case 3:
            [textField resignFirstResponder];
            break;
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    CGFloat constant = kChineseKeyboardHeight- MaxY(textField) - 10;
    if (constant <= 0 )
    {
        [UIView animateWithDuration:1 animations:^{
            _topConstraint.constant = constant;
            _bottomConstraint.constant = -constant;
        }];
    }
    return YES;
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    //PTT_StartLoadingAnimation();
    
}

- (void)PttS_recvLoginResult:(NSDictionary *)dic{
    if (PttDicResult(dic) == ACK_OK) {
        MAIN(^{
             PTT_StopLoadingAnimation();
            [self.navigationController popToRootViewControllerAnimated:YES];
        });
    }
    PTT_StopLoadingAnimation();
}

@end
