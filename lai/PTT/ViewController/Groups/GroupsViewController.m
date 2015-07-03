//
//  GroupsViewController.m
//  PTT
//
//  Created by xihan on 15/6/14.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import "GroupsViewController.h"
#import "Letter.h"
#import "Group.h"
#import "InfoCell.h"
#import "HttpManager.h"
#import "AppDelegate.h"
#import "MembersViewController.h"
#import "DBManager.h"
#import "ChatViewController.h"

@interface GroupsViewController ()<NSFetchedResultsControllerDelegate, NSFetchedResultsSectionInfo,UITableViewDataSource,UITableViewDelegate>
{
    NSManagedObjectContext *_managedObjectContext;
    NSFetchedResultsController *_fetchedResultsController;
    IBOutlet UITableView *_tableView;
    BOOL _isFetched;
}
@end

@implementation GroupsViewController

@synthesize name;
@synthesize indexTitle;
@synthesize numberOfObjects;
@synthesize objects;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"群组";
        self.tabBarItem.image = [UIImage imageNamed:@"tab_group_nor"];
        self.tabBarItem.selectedImage = [UIImage imageNamed:@"tab_group_sel"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView hideExtraSeparatorLine];
    _tableView.sectionIndexColor = [UIColor grayColor];
    _tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    _isFetched = NO;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"login" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        DLog(@"groups view reload !!!!");
        _isFetched = NO;
    }];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ( !_isFetched ) {
        [self startFetched];
        
//        WEAKSELF;
//        [[NSNotificationCenter defaultCenter] addObserverForName:@"login" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
//            DLog(@"group view reload !!!!");
//            [weakSelf startFetched];
//            [_tableView reloadData];
//        }];
        MAIN(^{[_tableView reloadData];});
        _isFetched = YES;
    }
}

- (void)startFetched{
    [NSFetchedResultsController deleteCacheWithName:@"Group"];
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
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Group"];
    [fetchRequest setFetchBatchSize:20];
    
    //排序对象
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]initWithKey:@"firstLetter.letter" ascending:YES];
    [fetchRequest setSortDescriptors:@[sort]];
    
    NSFetchedResultsController *fecthedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_managedObjectContext sectionNameKeyPath:@"firstLetter.letter" cacheName:@"group"];
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
    return [InfoCell cellHeight];
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
    InfoCell *cell = [InfoCell dequeueReusableCellFromTableView:tableView];
    
    Group *group  = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.name = group.name;
    cell.headType = InfoCell_Group;
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
    Group *group  = [_fetchedResultsController objectAtIndexPath:indexPath];
//    [HttpManager getMembersForGroupId:group.gid page:0 handler:^(NSDictionary *dataDic) {
//        if (PttDicResult(dataDic)) {
//            MembersViewController *memberViewController = [[MembersViewController alloc] initWithNibName:@"MembersViewController" bundle:nil];
//            memberViewController.gid = group.gid;
//            memberViewController.gnm = group.name;
//            memberViewController.sourceArray = [group.member allObjects];
//            [self.navigationController pushViewController:memberViewController animated:YES];
//        }
//    }];
    
    ChatViewController *chatViewController = [[ChatViewController alloc] init];
    chatViewController.chatName = group.name;
    chatViewController.gid = group.gid;
    chatViewController.viewType = VT_GROUP;
    [self.navigationController pushViewController:chatViewController animated:YES];
    
    /*
    MembersViewController *memberViewController = [[MembersViewController alloc] initWithNibName:@"MembersViewController" bundle:nil];
    memberViewController.gid = group.gid;
    memberViewController.gnm = group.name;
    memberViewController.sourceArray = [group.member allObjects];
    [self.navigationController pushViewController:memberViewController animated:YES];
     */
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

@end
