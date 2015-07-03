//
//  SettingViewController.m
//  PTT
//
//  Created by RenHongwei on 15/5/18.
//  Copyright (c) 2015年 ShunTong. All rights reserved.
//

#import "SettingViewController.h"
#import "AppDelegate.h"
#import "UserInfoViewController.h"
#import "PttService.h"
#import "AppInfoViewController.h"

@interface SettingViewController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"设置";
        self.tabBarItem.image = [UIImage imageNamed:@"tab_setting_nor"];
        self.tabBarItem.selectedImage = [UIImage imageNamed:@"tab_setting_sel"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.scrollEnabled = NO;
    [_tableView hideExtraSeparatorLine];
    _tableView.backgroundColor = RGBCOLOR(247, 247, 247);
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = NO;
}

#pragma mark - tableView delegate & datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return  @" ";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"setting"];
    if ( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"setting"];
    }
    switch (indexPath.section) {
        case 0:
        {
            cell.textLabel.text = @"勿扰模式";
            UISwitch *switchBtn  = [[UISwitch alloc] initWithFrame:CGRectMake(Main_Screen_Width - 100, 7, 49, 31)];
            [cell.contentView addSubview:switchBtn];
        }
            break;
        case 1:
        {
            cell.textLabel.text = @"修改用户信息";
        }
            break;
        case 2:
        {
            cell.textLabel.text = @"关于";
        }
            break;
        case 3:
        {
            cell.textLabel.text = @"退出当前帐户";
        }
            break;
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 1:
        {
            UserInfoViewController *userInfoViewController = [[UserInfoViewController alloc] initWithNibName:@"UserInfoViewController" bundle:nil];
            [self.navigationController pushViewController:userInfoViewController animated:YES];
        }
            break;
        case 3:
        {
            NSString *actionSheetTitle = @"退出后不会删除任何历史数据，下次登录依然可以使用本账号";
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:actionSheetTitle delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"退出登录" otherButtonTitles:nil, nil];
            [actionSheet showInView:self.view];
            
        }
            break;
        case 2:
        {
            AppInfoViewController *appInfoViewController = [[AppInfoViewController alloc] initWithNibName:@"AppInfoViewController" bundle:nil];
            [self.navigationController pushViewController:appInfoViewController animated:YES];
        }
            break;
            
        default:
            break;
    }
    [_tableView deselect];
}

#pragma mark - actiongSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    DLog(@"clickedButtonAtIndex");
    if (buttonIndex == 0) {
        DLog(@"clickedButtonAtIndex");
        PTT_StartLoadingAnimation();
        [[PttService sharedInstance] PTT_Logout];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"logout" object:self];
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            PTT_StopLoadingAnimation();
            AppDelegate *delegate = ShareDelegate;
            [delegate showLoginView];
        });
    }
}
@end
