//
//  MembersViewController.m
//  PTT
//
//  Created by xihan on 15/6/14.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import "MembersViewController.h"
#import "PttTopBar.h"
#import "MemberCell.h"
#import "MemberFootView.h"
#import "MemberSelViewController.h"

#import "DBManager.h"
#import "AppDelegate.h"

#import "Member.h"
#import "UserInfo.h"

@interface MembersViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    MemberFootViewDelegate,
    MemberCellDelegate,
    UIActionSheetDelegate,
    NSFetchedResultsControllerDelegate,
    NSFetchedResultsSectionInfo
>
{
    PttTopBar *_topBar;
    RightBtnType _cellBtnType;
    MemberFootView *_footView;
    NSManagedObjectContext *_managedObjectContext;
    NSFetchedResultsController *_fetchedResultsController;
    IBOutlet UITableView *_tableView;
}

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@end

@implementation MembersViewController

@synthesize name;
@synthesize indexTitle;
@synthesize numberOfObjects;
@synthesize objects;

- (void)viewDidLoad {
    [super viewDidLoad];

    
    [self setupTopBar];
    [self setupTableView];
    [self startFetched];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(tableViewScorllToBottom) name:UIKeyboardDidShowNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_footView hideKeyBoard];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    
    //adjust ChatTableView's height
    if (notification.name == UIKeyboardWillShowNotification) {
        
    }else{
        _bottomConstraint.constant = 0;
    }
    
    [self.view layoutIfNeeded];
    
    [UIView commitAnimations];
    
}

- (void)tableViewScorllToBottom{
    [_tableView setContentOffset:CGPointMake(0, _tableView.contentSize.height - _tableView.bounds.size.height) animated:YES];
}


- (void)setupTopBar{
    _topBar = [[PttTopBar alloc] initWithTitle:_gnm];
    WEAKSELF;
    _topBar.backBlock = ^{
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
    [self.view addSubview:_topBar];
}

- (void)setupTableView{
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    _footView = [[MemberFootView alloc] init];
    _footView.groupName = _gnm;
    _footView.delegate = self;
    [_tableView setTableFooterView:_footView];
}


- (void)startFetched{
    [NSFetchedResultsController deleteCacheWithName:@"Member"];
    _fetchedResultsController = nil;
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        DLog(@"NSFetchedResultsController error:%@" , error);
    }
}

- (NSFetchedResultsController *)fetchedResultsController{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    _managedObjectContext = [delegate mainThreadContext];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Member"];
    [fetchRequest setFetchBatchSize:20];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"gid == %@",_gid];
    [fetchRequest setPredicate:predicate];
    
    //排序对象
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]initWithKey:@"firstLetter.letter" ascending:YES];
    [fetchRequest setSortDescriptors:@[sort]];
    
    NSFetchedResultsController *fecthedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_managedObjectContext sectionNameKeyPath:@"firstLetter.letter" cacheName:@"Member"];
    _fetchedResultsController = fecthedResultsController;
    _fetchedResultsController.delegate = self;
    return _fetchedResultsController;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[_fetchedResultsController sections]count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [MemberCell cellHeight];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([[_fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
        
        return [sectionInfo numberOfObjects];
        
    } else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MemberCell *cell = [MemberCell dequeueReusableCellFromTableView:tableView];
    Member *member  = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.name = member.info.name;
    cell.btnType = _cellBtnType;
    cell.index = indexPath;
    cell.delegate = self;
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([[_fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo name];
    } else
        return nil;
}

//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
//    NSArray *array = [_fetchedResultsController sections];
//    NSMutableArray *arrays = [NSMutableArray arrayWithCapacity:42];
//    for(id <NSFetchedResultsSectionInfo> sectionInfo in array){
//        [arrays addObject:[sectionInfo name]];
//    }
//    return arrays;
//}

#pragma mark NSFetchedRequestDelegated的委托
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [_tableView beginUpdates];
}

#pragma mark 数据变化引起分区的变化时调用
- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [_tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                      withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [_tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                      withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        default:
            break;
    }
}

#pragma mark 增,删,改,移动 后执行
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = _tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationNone];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationNone];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationNone];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationNone];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationNone];
            break;
    }
}

#pragma mark 数据变化结束后调用
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [_tableView endUpdates];
}


#pragma mark - footView delegate
- (void)FootView_addMember{
    MemberSelViewController *memberSelViewController = [[MemberSelViewController alloc] init];
    memberSelViewController.groupName = _gnm;
    memberSelViewController.viewType = MSVT_ADD;
    memberSelViewController.gid = _gid;
    
    NSArray *memberArray = [DBManager getMembersByGroupId:_gid];
    NSMutableArray *array = [NSMutableArray array];
    [memberArray enumerateObjectsUsingBlock:^(Member *obj, NSUInteger idx, BOOL *stop) {
        [array addObject:obj.uid];
    }];
    memberSelViewController.memberArray = array;
    [self.navigationController presentViewController:memberSelViewController animated:YES completion:nil];
}

- (void)FootView_deleteMember{
    _cellBtnType = _cellBtnType ? RBT_REMARK : RBT_DELETE;
    [_tableView reloadData];
}

- (void)FootView_startEditing:(CGFloat)maxY{
    _bottomConstraint.constant = kChineseKeyboardHeight - maxY;
    DLog(@"FootView_startEditing :%.2f",maxY);
}

- (void)FootView_changeGroupName:(NSString *)gnm{
    
    PTT_StartLoadingAnimation();
    [HttpManager changeGroupNameByGroupId:_gid name:gnm handler:^(NSDictionary *dataDic) {
        PTT_StopLoadingAnimation();
        if (PttDicResult(dataDic)) {
            [_topBar changeTitle:gnm];
            if (self.changeNameBlock) {
                self.changeNameBlock(gnm);
            }
            NSDictionary *dic =
            @{
                @"gid":_gid,
                @"gnm":gnm
              };
            [DBManager saveNewGroupByDic:dic];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:PttDicMsg(dataDic) message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
    
}

- (void)FootView_quitGroup{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"退出群组" otherButtonTitles:nil, nil];
    [actionSheet showInView:self.view];
}

#pragma mark - actionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        PTT_StartLoadingAnimation();
        [HttpManager quitGroupByGroupId:_gid handler:^(NSDictionary *dataDic) {
            if (PttDicResult(dataDic)) {
                
                [DBManager deleteConversationByGroupId:_gid];
                [DBManager deleteGroupByGid:_gid];
                [DBManager deleteMessagesByGroupId:_gid];
                [DBManager deleteAllMembersInGroup:_gid];
                
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
            PTT_StopLoadingAnimation();
        }];
    }
}

#pragma mark - member cell delegate
- (void)deleteMemberByIndex:(NSIndexPath *)index{
    DLog(@"\n==================\ndel:%@\n==================\n",index);
}

- (void)remarkMemberByIndex:(NSIndexPath *)index{
    DLog(@"\n==================\nrem:%@\n==================\n",index);
}

- (void)dealloc{
    _fetchedResultsController = nil;
}
@end
