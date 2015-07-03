//
//  MemberSelViewController.m
//  PTT
//
//  Created by xihan on 15/6/22.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import "MemberSelViewController.h"
#import "FriendInfo.h"
#import "UserInfo.h"
#import "MemberSelCell.h"
#import "AppDelegate.h"
#import "DBManager.h"

@interface MemberSelViewController ()<NSFetchedResultsControllerDelegate, NSFetchedResultsSectionInfo,UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableView;
    NSManagedObjectContext *_managedObjectContext;
    NSFetchedResultsController *_fetchedResultsController;
    NSMutableArray *_selectArray;
}
@end

@implementation MemberSelViewController

@synthesize name;
@synthesize indexTitle;
@synthesize numberOfObjects;
@synthesize objects;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTopBar];
    [self setupTableView];
    [self startFetched];
    _selectArray = [NSMutableArray array];
}

- (void)setupTopBar{
    PttTopBar *topBar = [[PttTopBar alloc] initWithTitle:@"选择好友"];
    [self.view addSubview:topBar];
    topBar.backBlock = ^(){
        if (_viewType == MSVT_ADD) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }       
    };
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(Main_Screen_Width - 90, 20, 90, 44)];
    [btn setTitle:@"确定" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(createGroup) forControlEvents:UIControlEventTouchUpInside];
    [topBar addSubview:btn];
}

- (void)setupTableView{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, Main_Screen_Width, Main_Screen_Height - 64) style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView hideExtraSeparatorLine];
    _tableView.sectionIndexColor = [UIColor grayColor];
    _tableView.sectionIndexBackgroundColor = [UIColor clearColor];
}

- (void)createGroup{
    NSMutableString *uids = [NSMutableString string];
    [_selectArray enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
        FriendInfo *friend  = [_fetchedResultsController objectAtIndexPath:indexPath];
        [uids appendFormat:@"%@;",friend.uid];
    }];
    if (uids == nil && uids.length == 0) {
        ASSERT;
        return;
    }
    [uids deleteCharactersInRange:NSMakeRange(uids.length - 1, 1)];
    PTT_StartLoadingAnimation();
    if (_viewType == MSVT_ADD) {
        [HttpManager addMembersByUserIds:uids toGroupId:_gid handler:^(NSDictionary *dataDic) {
            PTT_StopLoadingAnimation();
            if ( PttDicResult(dataDic) == ACK_OK ) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:PttDicMsg(dataDic) message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
            }
        }];
        return;
    }
    
    [HttpManager createGroupWithGroupName:_groupName uids:uids handler:^(NSDictionary *dataDic) {
        PTT_StopLoadingAnimation();
        if ( PttDicResult(dataDic) == ACK_OK ) {
            NSDictionary *ackDic = PttDicMsg(dataDic);
            [DBManager saveNewGroupByDic:ackDic];
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:PttDicMsg(dataDic) message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
}


- (void)startFetched{
    //[NSFetchedResultsController deleteCacheWithName:@"friend"];
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
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"FriendInfo"];
    [fetchRequest setFetchBatchSize:20];
    
    //排序对象
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]initWithKey:@"firstLetter.letter" ascending:YES];
    [fetchRequest setSortDescriptors:@[sort]];
    
    NSFetchedResultsController *fecthedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_managedObjectContext sectionNameKeyPath:@"firstLetter.letter" cacheName:@"friend"];
    
    _fetchedResultsController = fecthedResultsController;
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[_fetchedResultsController sections]count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([[_fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
        
    } else
        return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [MemberSelCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MemberSelCell *cell = [MemberSelCell dequeueReusableCellFromTableView:tableView];
    
    FriendInfo *friend  = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.name = friend.info.name;
    cell.selType = [_selectArray containsObject:indexPath]? MST_Selected:MST_Normoal;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    if (_viewType == MSVT_ADD && [_memberArray containsObject:friend.uid]) {
        cell.selType = MST_NotSelect;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([[_fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo name];
    } else
        return nil;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    NSArray *array = [_fetchedResultsController sections];
    NSMutableArray *arrays = [NSMutableArray arrayWithCapacity:42];
    for(id <NSFetchedResultsSectionInfo> sectionInfo in array){
        [arrays addObject:[sectionInfo name]];
    }
    return arrays;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([_selectArray containsObject:indexPath]) {
        [_selectArray removeObject:indexPath];
    }else{
        [_selectArray addObject:indexPath];
    }
    
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [tableView deselect];
}

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
        case NSFetchedResultsChangeUpdate:
            [_tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
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

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleNone;
}
@end
