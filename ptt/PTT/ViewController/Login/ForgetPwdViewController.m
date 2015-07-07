//
//  ForgetPwdViewController.m
//  PTT
//
//  Created by xihan on 15/7/7.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import "ForgetPwdViewController.h"
#import "NSString+Extension.h"

@interface ForgetPwdViewController ()<UITextFieldDelegate, UIAlertViewDelegate>
{
    BOOL _getResult;
}
@property (strong, nonatomic) IBOutlet UILabel *errorLabel;
@property (strong, nonatomic) IBOutlet UITextField *phoneTF;
@property (strong, nonatomic) IBOutlet UIButton *btn;

@end

@implementation ForgetPwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTopBar];
    [self addBackgroundTap];
    _phoneTF.delegate = self;
    _errorLabel.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChange) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)setupTopBar{
   PttTopBar *topBar= [[PttTopBar alloc] initWithTitle:@"忘记密码"];
    WEAKSELF;
    topBar.backBlock = ^(){
        [weakSelf hideKeyBoard];
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    };
    [self.view addSubview:topBar];
}

- (void)textFieldChange{
    if (![_phoneTF.text isMobileNumber]){
        _errorLabel.text = @"❌请输入正确的手机号码";
        _errorLabel.hidden = NO;
        _btn.enabled = NO;
    }
    else{
        _errorLabel.hidden = YES;
        _btn.enabled = YES;
    }
}

- (IBAction)getPwd:(id)sender {
    [self hideKeyBoard];
    PTT_StartLoadingAnimation();
  
    [HttpManager getPwdForPhoneNum:_phoneTF.text handler:^(NSDictionary *dataDic) {
        _getResult = PttDicResult(dataDic);
        PTT_StopLoadingAnimation();
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:PttDicMsg(dataDic) message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        alert.delegate = self;
        [alert show];
    }];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (_getResult) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)addBackgroundTap{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)];
    tap.cancelsTouchesInView = NO;
    [tap setNumberOfTouchesRequired:1];
    [self.view addGestureRecognizer:tap];
}


- (void)hideKeyBoard{
    [_phoneTF resignFirstResponder];
}

@end
