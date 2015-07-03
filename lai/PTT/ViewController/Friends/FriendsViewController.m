//
//  FriendsViewController.m
//  PTT
//
//  Created by xihan on 15/6/14.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import "FriendsViewController.h"
#import "InfoCell.h"
#import "FriendInfoViewController.h"

#import "DBManager.h"
#import "AppDelegate.h"

#import "UserInfo.h"
#import "FriendInfo.h"

@interface FriendsViewController ()<NSFetchedResultsControllerDelegate, NSFetchedResultsSectionInfo,UITableViewDataSource,UITableViewDelegate>
{
    IBOutlet UITableView *_tableView;
    BOOL _isFetched;
    NSManagedObjectContext *_managedObjectContext;
    NSFetchedResultsController *_fetchedResultsController;
}
@end

@implementation FriendsViewController

@synthesize name;
@synthesize indexTitle;
@synthesize numberOfObjects;
@synthesize objects;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"好友";
        self.tabBarItem.image = [UIImage imageNamed:@"tab_friend_nor"];
        self.tabBarItem.selectedImage = [UIImage imageNamed:@"tab_friend_sel"];
        //右上角数字
        //self.tabBarItem.badgeValue =@"99";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.sectionIndexColor = [UIColor grayColor];
    _tableView.sectionIndexBackgroundColor = [UIColor clearColor];

    [_tableView hideExtraSeparatorLine];
    _isFetched = NO;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"login" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        DLog(@"friend view reload !!!!");
        _isFetched = NO;
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ( !_isFetched ) {
        [self startFetched];
        
//        WEAKSELF;
//        [[NSNotificationCenter defaultCenter] addObserverForName:@"login" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
//            DLog(@"friend view reload !!!!");
//            [weakSelf startFetched];
//            [_tableView reloadData];
//        }];
        
        _isFetched = YES;
        MAIN(^{[_tableView reloadData];});
    }
}

- (void)startFetched{
    [NSFetchedResultsController deleteCacheWithName:@"friend"];
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
     NSSortDescriptor *sort2 = [[NSSortDescriptor alloc] initWithKey:@"info.name" ascending:YES];
    [fetchRequest setSortDescriptors:@[sort, sort2]];
    
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
    return [InfoCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    InfoCell *cell = [InfoCell dequeueReusableCellFromTableView:tableView];
    
    FriendInfo *friend  = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.name = friend.info.name;
    cell.headType = InfoCell_FriendOnline;
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
    FriendInfo *friend  = [_fetchedResultsController objectAtIndexPath:indexPath];

    FriendInfoViewController *friendInfoViewController = [[FriendInfoViewController alloc] initWithNibName:@"FriendInfoViewController" bundle:nil];
    friendInfoViewController.gid = friend.fgid;
    friendInfoViewController.name = friend.info.name;
    [self.navigationController pushViewController:friendInfoViewController animated:YES];
    
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
