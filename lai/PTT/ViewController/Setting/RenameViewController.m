//
//  RenameViewController.m
//  PTT
//
//  Created by xihan on 15/6/11.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import "RenameViewController.h"
#import "UDManager.h"

@interface RenameViewController ()
@property (strong, nonatomic) IBOutlet UITextField *textField;

@end

@implementation RenameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _textField.placeholder = [UDManager getUserName];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [_textField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_textField resignFirstResponder];
}

- (IBAction)save:(id)sender {
     [_textField resignFirstResponder];
    if (_textField.text == nil || _textField.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"昵称不能为空" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    [HttpManager changeToNewNikename:_textField.text handler:^(NSDictionary *dataDic) {
        if (PttDicResult(dataDic)) {
            [UDManager saveUserName:_textField.text];
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
    [self.navigationController popViewControllerAnimated:YES];
}

@end
