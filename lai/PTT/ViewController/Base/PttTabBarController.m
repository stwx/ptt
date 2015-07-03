//
//  PttTabBarController.m
//  PTT
//
//  Created by xihan on 15/5/29.
//  Copyright (c) 2015年 STWX. All rights reserved.
//

#import "PttTabBarController.h"
#import "AddContactViewController.h"
#import "CreateGroupViewController.h"
@interface PttTabBarController ()
{
    UIView *_popupMenu;
}
@end

@implementation PttTabBarController

- (instancetype)init{
    self = [super init];
    if (self) {
        self.edgesForExtendedLayout =UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.tabBar.tintColor = RGBCOLOR(82, 169, 44);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTopBar];
    [self setupPopupMenu];
    [self addBackgroundTap];
   // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createGroupNoti:) name:@"createGroup" object:nil];
}
/*
- (void)createGroupNoti:(NSNotification *)noti{
    NSDictionary *userInfo = noti.userInfo;
    NSDictionary *dataDic = userInfo[@"info"];
    ChatViewController *chatViewController = [[ChatViewController alloc] initWithNibName:@"ChatViewController" bundle:nil];
    chatViewController.gid = dataDic[@"gid"];
    chatViewController.name = dataDic[@"gnm"];
    chatViewController.viewType = CVT_GROUP;
    MAIN(^{
        PTT_StopLoadingAnimation();
        [self.navigationController pushViewController:chatViewController animated:NO];
    });
    
}
*/
- (void)setupTopBar{
    UIView *topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Main_Screen_Width, 64)];
    topBar.backgroundColor = [UIColor blackColor];
    [self.view addSubview:topBar];
    
    UIImageView *logo = [[UIImageView alloc] initWithFrame:CGRectMake(16, 26, 30, 30)];
    logo.image = [UIImage imageNamed:@"logo"];
    [topBar addSubview:logo];
    
    UIButton *addBtn = [[UIButton alloc] initWithFrame:CGRectMake(Main_Screen_Width - 50, 26, 30, 30)];
    [addBtn setImage:[UIImage imageNamed:@"add_nor"] forState:UIControlStateNormal];
    [addBtn setImage:[UIImage imageNamed:@"add_pre"] forState:UIControlStateHighlighted];
    [addBtn addTarget:self action:@selector(addBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [topBar addSubview:addBtn];
    
    UIButton *searchBtn = [[UIButton alloc] initWithFrame:CGRectMake(Main_Screen_Width - 100, 26, 30, 30)];
    [searchBtn setImage:[UIImage imageNamed:@"search_nor"] forState:UIControlStateNormal];
    [searchBtn setImage:[UIImage imageNamed:@"search_pre"] forState:UIControlStateHighlighted];
    [searchBtn addTarget:self action:@selector(searchBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [topBar addSubview:searchBtn];
    
}

- (void)setupPopupMenu{
    _popupMenu = [[UIView alloc] initWithFrame:CGRectMake(Main_Screen_Width - 125, 66, 120, 88)];
    _popupMenu.hidden = YES;
    _popupMenu.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_popupMenu];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 120, 44)];
    [btn setTitle:@"添加联系人" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(addContact) forControlEvents:UIControlEventTouchUpInside];
    [_popupMenu addSubview:btn];
    
    UIButton *btn2 = [[UIButton alloc] initWithFrame:CGRectMake(0, 44, 120, 44)];
    [btn2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn2 setTitle:@"创建群组" forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(addGroup) forControlEvents:UIControlEventTouchUpInside];
    [_popupMenu addSubview:btn2];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 44, 120, 1)];
    line.backgroundColor = [UIColor whiteColor];
    [_popupMenu addSubview:line];
    
    _popupMenu.hidden = YES;
}

- (void)addBtnClick{
    _popupMenu.hidden = !_popupMenu.hidden;
}

- (void)searchBtnClick{
    
}

- (void)addBackgroundTap{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTap)];
    [tap setNumberOfTouchesRequired:1];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
}

- (void)backgroundTap{
    _popupMenu.hidden = YES;
}

- (void)addContact{
    _popupMenu.hidden = YES;
    AddContactViewController *addContactController = [[AddContactViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:addContactController];
    navigationController.navigationBarHidden = YES;
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}


- (void)addGroup{
    _popupMenu.hidden = YES;
    CreateGroupViewController *createGroupViewController = [[CreateGroupViewController alloc] initWithNibName:@"CreateGroupViewController" bundle:nil];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:createGroupViewController];
    navigationController.navigationBarHidden = YES;
    
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

@end
