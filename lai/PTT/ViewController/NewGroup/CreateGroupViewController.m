//
//  CreateGroupViewController.m
//  PTT
//
//  Created by xihan on 15/6/9.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import "CreateGroupViewController.h"
#import "NSString+Extension.h"
#import "MemberSelViewController.h"

@interface CreateGroupViewController ()
@property (strong, nonatomic) IBOutlet UIButton *nextBtn;
@property (strong, nonatomic) IBOutlet UITextField *groupName;

@end

@implementation CreateGroupViewController

- (void)viewDidLoad {
    _nextBtn.enabled = NO;
    [super viewDidLoad];

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_groupName resignFirstResponder];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFileDidChange) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_groupName resignFirstResponder];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)textFileDidChange{
    _nextBtn.enabled = ![_groupName.text isNull];
    [_nextBtn setTitleColor:[_groupName.text isNull] ? [UIColor grayColor] : [UIColor whiteColor] forState:UIControlStateNormal];
}

- (IBAction)backToSuperView:(id)sender {
    [_groupName resignFirstResponder];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)next:(id)sender {
    [_groupName resignFirstResponder];
    MemberSelViewController *memberSelViewController = [[MemberSelViewController alloc] init];
    memberSelViewController.groupName = _groupName.text;
    memberSelViewController.viewType = MSVT_NEW;
    [self.navigationController pushViewController:memberSelViewController animated:YES];
}


@end
