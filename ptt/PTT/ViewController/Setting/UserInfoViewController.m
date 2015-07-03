//
//  UserInfoViewController.m
//  PTT
//
//  Created by xihan on 15/6/11.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import "UserInfoViewController.h"
#import "ChangePwdViewController.h"
#import "RenameViewController.h"
#import "PttTopBar.h"
@interface UserInfoViewController ()<UITableViewDataSource, UITableViewDelegate, PttTopBarDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation UserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView.delegate = self;
    _tableView.dataSource =self;
    [_tableView hideExtraSeparatorLine];
    
    PttTopBar *topBar = [[PttTopBar alloc] initWithTitle:@"用户信息"];
    topBar.delegate =self;
    [self.view addSubview:topBar];
}

- (void)backToSuperView{
    [self.navigationController popViewControllerAnimated:YES];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"info"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"info"];
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = @"修改昵称";
    }
    else if (indexPath.row == 1){
        cell.textLabel.text = @"修改密码";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        RenameViewController *renameViewController = [[RenameViewController alloc] initWithNibName:@"RenameViewController" bundle:nil];
        [self.navigationController pushViewController:renameViewController animated:YES];
    }else{
        ChangePwdViewController *changPwdViewController = [[ChangePwdViewController alloc] initWithNibName:@"ChangePwdViewController" bundle:nil];
        [self.navigationController pushViewController:changPwdViewController animated:YES];
    }
    [_tableView deselect];
}

@end
