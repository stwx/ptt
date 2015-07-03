//
//  HomePageViewController.m
//  PTT
//
//  Created by xihan on 15/6/14.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import "HomePageViewController.h"
#import "Conversation.h"
#import "ConversationCell.h"
#import "AppDelegate.h"
#import "NewInvitedViewController.h"
#import "DBManager.h"
#import "ChatViewController.h"
#import "InviteInfoViewController.h"

@interface HomePageViewController ()<NSFetchedResultsControllerDelegate, NSFetchedResultsSectionInfo,UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableView;
    NSManagedObjectContext *_managedObjectContext;
    NSFetchedResultsController *_fetchedResultsController;
    AppDelegate *_delegate;
    BOOL _isFetched;
}
@end

@implementation HomePageViewController

@synthesize name;
@synthesize indexTitle;
@synthesize numberOfObjects;
@synthesize objects;

- (instancetype)init{
    self = [super init];
    if (self) {
        self.title = @"PTT";
        self.tabBarItem.image = [UIImage imageNamed:@"tab_main_nor"];
        self.tabBarItem.selectedImage = [UIImage imageNamed:@"tab_main_sel"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTableView];
    _delegate = ShareDelegate;
    _isFetched = NO;

    [[NSNotificationCenter defaultCenter] addObserverForName:@"login" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        DLog(@"home view reload !!!!");
        _isFetched = NO;
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ( !_isFetched ) {
        [self startFetched];
        MAIN(^{[_tableView reloadData];});
        _isFetched = YES;
    }
}


- (void)startFetched{
    [NSFetchedResultsController deleteCacheWithName:@"Conversation"];
    _fetchedResultsController = nil;
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        DLog(@"NSFetchedResultsController error:%@" , error);
    }
}
- (void)setupTableView{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, Main_Screen_Width, Main_Screen_Height - 64) style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView hideExtraSeparatorLine];
}

- (NSFetchedResultsController *)fetchedResultsController{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    _managedObjectContext = [_delegate mainThreadContext];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Conversation"];
    [fetchRequest setFetchBatchSize:20];
    
    //排序对象
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]initWithKey:@"date" ascending:NO];
    [fetchRequest setSortDescriptors:@[sort]];
    
    NSFetchedResultsController *fecthedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_managedObjectContext sectionNameKeyPath:nil cacheName:@"conversation"];
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
    return [ConversationCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ConversationCell *cell = [ConversationCell dequeueReusableCellFromTableView:tableView];
    Conversation *conversation  = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.conversation = conversation;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Conversation *conversation  = [_fetchedResultsController objectAtIndexPath:indexPath];
    int conversationType = [conversation.conversationType intValue];
    [DBManager clearConversationUnreadCout:conversation];
    
    if (conversationType == CT_NEW_INVITE) {
        NewInvitedViewController *newInvitedViewController = [[NewInvitedViewController alloc] initWithNibName:@"NewInvitedViewController" bundle:nil];
        newInvitedViewController.uid = conversation.uid;
        newInvitedViewController.name = conversation.name;
        newInvitedViewController.note = conversation.note;
        [self.navigationController pushViewController:newInvitedViewController animated:YES];
    }
    else if (conversationType == CT_INVITE_DISAGREE || conversationType == CT_INVITE_WAIT)
    {
        InviteInfoViewController *inviteInfoViewController = [[InviteInfoViewController alloc] init];
        inviteInfoViewController.name = conversation.name;
        inviteInfoViewController.note = conversation.note;
        inviteInfoViewController.invtiteType = conversationType == CT_INVITE_WAIT ? IT_WAIT : IT_DISAGREE;
        [self.navigationController pushViewController:inviteInfoViewController animated:YES];
        
    }
    else{
        ChatViewController *chatViewController = [[ChatViewController alloc] init];
        chatViewController.gid = conversation.gid;
        chatViewController.chatName = conversation.name;
        chatViewController.viewType = conversationType;
        [self.navigationController pushViewController:chatViewController animated:YES];
    }
    // DLog(@"uid:%@ name:%@ fgid:%@",friend.uid, friend.name, friend.fgid);
    [tableView deselect];
}

#pragma mark NSFetchedRequestDelegated的委托
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [_tableView beginUpdates];
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
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
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
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        Conversation *conversation = [_fetchedResultsController objectAtIndexPath:indexPath];
        [_managedObjectContext deleteObject:conversation];
        __autoreleasing NSError *error;
        [_managedObjectContext save:&error];
        if(error){
            DLog(@"删除失败:%@",error);
        }
        [_delegate saveContextWithWait:NO];
    }
}




@end
