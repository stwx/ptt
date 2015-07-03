//
//  AppInfoViewController.m
//  PTT
//
//  Created by xihan on 15/6/29.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import "AppInfoViewController.h"

@interface AppInfoViewController ()

@end

@implementation AppInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    PttTopBar *topBar = [[PttTopBar alloc] initWithTitle:@"PTT"];
    WEAKSELF
    topBar.backBlock = ^{
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
    [self.view addSubview:topBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
