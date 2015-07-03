//
//  AddContactViewController.m
//  PTT
//
//  Created by xihan on 15/6/22.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import "AddContactViewController.h"
#import "NewContactViewController.h"
#import "PhoneContactViewController.h"

@interface AddContactViewController ()<UITableViewDataSource, UITableViewDelegate>{
    UITableView *_tableView;
}

@end

@implementation AddContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTableView];
    [self setupTopBar];
    
}

- (void)setupTopBar{
    UIView *topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Main_Screen_Width, 64)];
    topBar.backgroundColor = [UIColor blackColor];
    [self.view addSubview:topBar];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, 80, 44)];
    [btn setTitle:@"取消" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:17];
    [btn addTarget:self action:@selector(backToSuperView) forControlEvents:UIControlEventTouchUpInside];
    [topBar addSubview:btn];
    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(Main_Screen_Width * 0.5 - 100, 20, 200, 44)];
    lab.textColor = [UIColor whiteColor];
    lab.textAlignment = NSTextAlignmentCenter;
    lab.font = [UIFont systemFontOfSize:17];
    lab.text = @"邀请好友";
    [topBar addSubview:lab];
}

- (void)setupTableView{    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, Main_Screen_Width, Main_Screen_Height - 64) style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView hideExtraSeparatorLine];
}

- (void)backToSuperView{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"invite"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"invite"];
        cell.imageView.image = [UIImage imageNamed:@"group"];
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = @"输入好友账号";
    }else{
        cell.textLabel.text = @"从通讯录导入好友";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        NewContactViewController *newContactViewController = [[NewContactViewController alloc] initWithNibName:@"NewContactViewController" bundle:nil];
        [self.navigationController pushViewController:newContactViewController animated:YES];
    }
    else{
        PhoneContactViewController *phoneContactViewController = [[PhoneContactViewController alloc] init];
        [self.navigationController pushViewController:phoneContactViewController animated:YES];
    }
    [tableView deselect];
}

@end
