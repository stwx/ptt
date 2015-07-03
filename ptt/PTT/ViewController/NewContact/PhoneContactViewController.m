//
//  PhoneContactViewController.m
//  PTT
//
//  Created by xihan on 15/6/22.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import "PhoneContactViewController.h"
#import "PhoneContactCell.h"
#import "ContactUtil.h"
#import "UDManager.h"

@interface PhoneContactViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    UITableView *_tableView;
    NSArray *_contactArray;
    NSMutableArray *_selectedArray;
}
@end

@implementation PhoneContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTopBar];
    [self setupTableView];
    [self loadDataSource];
}

- (void)setupTopBar{
    PttTopBar *topBar = [[PttTopBar alloc] initWithTitle:@"通讯录"];
    [self.view addSubview:topBar];
    WEAKSELF;
    topBar.backBlock = ^(){
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
}

- (void)setupTableView{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, Main_Screen_Width, Main_Screen_Height - 64) style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView hideExtraSeparatorLine];
}

- (void)loadDataSource{
    
    _contactArray = [ContactUtil getContacts];
    _selectedArray = [NSMutableArray arrayWithCapacity:_contactArray.count];
    
    for (int i = 0; i<_contactArray.count; i++) {
        _selectedArray[i] = @0;
    }
    MAIN(^{[_tableView reloadData];});
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _contactArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PhoneContactCell *cell = [PhoneContactCell dequeueReusableCellFromTableView:tableView];
    NSDictionary *dic = _contactArray[indexPath.row];
    cell.textLabel.text = dic[@"name"];
    cell.detailTextLabel.text = dic[@"num"];
    cell.btnTag = indexPath.row;
    cell.inviteBlock = ^(NSInteger index){
        _selectedArray[index] = @1;
        NSDictionary *dic = _contactArray[index];
        
        NSString *uid = [NSString stringWithFormat:@"%@@a",dic[@"num"]];
        NSString *note = [NSString stringWithFormat:@"我是%@",[UDManager getUserName]];
        [HttpManager inviteFriendByFriendId:uid notes:note handler:^(NSDictionary *dataDic) {
            if (PttDicResult(dataDic) != ACK_OK ) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:PttDicMsg(dataDic) message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
            }
        }];
    };
    cell.btnType = [_selectedArray[indexPath.row] intValue];
    return cell;
}


@end
