//
//  ChatViewController.m
//  PTT
//
//  Created by xihan on 15/6/23.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import "ChatViewController.h"
#import "ChatCell.h"
#import "PTTInputView.h"
#import "MembersViewController.h"

#import "Message.h"
#import "ChatCellFrameModel.h"

#import "DBManager.h"
#import "UDManager.h"
#import "RecordManager.h"
#import "Appdelegate.h"
#import "PttSNotiHandler.h"
#import "PttService.h"

#import "NSDate+Extension.h"

#import "UpdateManager.h"


const int showTimeDur = 2;

@interface ChatViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    NSFetchedResultsControllerDelegate,
    NSFetchedResultsSectionInfo,
    PTTInputViewDelegate,
    ChatCellDelegate,
    PttSNotiDelegate,
    PttServiceDelegate
>
{
    PttTopBar *_topBar;
    PTTInputView *_inputView;
    UITableView *_tableView;
    
    NSDate *_lastShowDate;
    
    NSManagedObjectContext *_managedObjectContext;
    NSFetchedResultsController *_fetchedResultsController;

    PttSNotiHandler *_notiHandler;
    PttService *_service;

    BOOL _first;
}
@end

@implementation ChatViewController

@synthesize name;
@synthesize indexTitle;
@synthesize numberOfObjects;
@synthesize objects;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTopBar];
    [self setupTableView];
    [self setupInputView];
    [self startFetched];
    [self addBackgroundTap];
    
   // _notiHandler = [PttSNotiHandler sharePttsNotiHandler];
    _service = [PttService sharedInstance];
    
  //  _notiHandler.delegate = self;
    _service.delegate = self;
    
    [UDManager saveCurrentChatGroup:_gid];
    _first = YES;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self addNotificationObserver];
    
    if (_first) {
        _first = NO;
        if (_viewType == VT_GROUP) {
            [UpdateManager updateMemberListByGroupId:_gid];
        }
        [_tableView setContentOffset:CGPointMake(CGFLOAT_MAX, CGFLOAT_MAX) animated:YES];
    }
   
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self hideKeyBoard];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupTopBar{
    _topBar= [[PttTopBar alloc] initWithTitle:_chatName];
    WEAKSELF;
    _topBar.backBlock = ^(){
        [weakSelf hideKeyBoard];
        [UDManager saveCurrentChatGroup:nil];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
    if (_viewType == VT_GROUP) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(Main_Screen_Width - 40, 26, 30, 30)];
        [btn setImage:[UIImage imageNamed:@"group_info"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(groupMembers) forControlEvents:UIControlEventTouchUpInside];
        [_topBar addSubview:btn];
    }
    [self.view addSubview:_topBar];
}

- (void)groupMembers{
    MembersViewController *membersViewController = [[MembersViewController alloc] initWithNibName:@"MembersViewController" bundle:nil];
    membersViewController.gid = _gid;
    membersViewController.gnm = _chatName;
    membersViewController.changeNameBlock = ^(NSString *gnm){
        [_topBar changeTitle:gnm];
    };
    [self.navigationController pushViewController:membersViewController animated:YES];
}

- (void)setupInputView{
    _inputView = [[PTTInputView alloc] initWithFrame:CGRectMake(0, Main_Screen_Height - InputViewHeight, Main_Screen_Width, InputViewHeight)];
    if ([[UDManager getCurrentGroup] isEqualToString:_gid]) {
        [_inputView changeToTalkState];
        [HttpManager joinGroupTalkByGroupId:_gid Handler:nil];
    }
    _inputView.delegate = self;
    [self.view addSubview:_inputView];
}

- (void)setupTableView{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, Main_Screen_Width, Main_Screen_Height - 64 - InputViewHeight) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = RGBCOLOR(247, 247, 247);
    [self.view addSubview:_tableView];
}

- (void)addNotificationObserver{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(tableViewScrollToBottom) name:UIKeyboardWillShowNotification object:nil];
}

/**
 *  键盘发生改变执行
 */
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
    
    CGRect frame = _tableView.frame;
    if (notification.name == UIKeyboardWillShowNotification) {
        frame.size.height = Main_Screen_Height - 64 -  keyboardEndFrame.size.height - InputViewHeight;
    }
    else{
        frame.size.height = Main_Screen_Height - 64 - InputViewHeight ;
    }
    _tableView.frame = frame;
    [self.view layoutIfNeeded];
    
    CGRect newFrame = _inputView.frame;
    newFrame.origin.y = keyboardEndFrame.origin.y - newFrame.size.height;
    _inputView.frame = newFrame;
    
    [UIView commitAnimations];
}

- (void)tableViewScrollToBottom{

    NSInteger numberOfRows = [_tableView numberOfRowsInSection:0];
    if (numberOfRows) {
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:numberOfRows-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }

}

- (void)addBackgroundTap{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)];
    tap.cancelsTouchesInView = NO;
    [tap setNumberOfTouchesRequired:1];
    [_tableView addGestureRecognizer:tap];
}

- (void)hideKeyBoard{
    [_inputView hideKeyBoard];
}

- (void)startFetched{
    [NSFetchedResultsController deleteCacheWithName:@"msg"];
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
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Message"];
    [fetchRequest setFetchBatchSize:20];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"gid == %@",_gid];
    fetchRequest.predicate = predicate;
    
    //排序对象
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]initWithKey:@"date" ascending:YES];
    [fetchRequest setSortDescriptors:@[sort]];
    
    NSFetchedResultsController *fecthedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_managedObjectContext sectionNameKeyPath:nil cacheName:@"msg"];
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
    ChatCellFrameModel *cellFrame = [[ChatCellFrameModel alloc] init];
    Message *message = [_fetchedResultsController objectAtIndexPath:indexPath];
    cellFrame.showTime = YES;
    cellFrame.message = message;
    return cellFrame.cellHeght;
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
    
    ChatCellFrameModel *cellFrame = [[ChatCellFrameModel alloc] init];
    Message *message = [_fetchedResultsController objectAtIndexPath:indexPath];
    cellFrame.showTime = YES;
    cellFrame.message = message;
    ChatCell *cell = [ChatCell dequeueReusableCellFromTableView:tableView];
    cell.cellFrame = cellFrame;
    cell.tag = indexPath.row;
    cell.delegate = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
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
            [self tableViewScrollToBottom];
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
    DLog(@"controllerDidChangeContent");
    [self tableViewScrollToBottom];
    [_tableView endUpdates];
   
}

#pragma mark ------- Input View Delegate ---------
- (void)IV_SendText:(NSString *)text{
    
    NSDictionary *msgDic =
    @{
            @"uid" : [UDManager getUserId],
            @"gid" : _gid,
            @"msg" : text,
        @"msgType" : [NSNumber numberWithInt:MSG_TEXT],
     @"sendResult" : [NSNumber numberWithInt:SR_Sending]
     };
    Message *message = [DBManager saveChatMessageByDic:msgDic];
    
    [HttpManager sendMsgToGroupId:_gid message:text msgType:MSG_TEXT voiceTime:0 handler:^(NSDictionary *dataDic) {
        int sendResult = PttDicResult(dataDic) == ACK_OK ? SR_OK : SR_Fail ;
        [DBManager updateMessageSendResult:message result:sendResult];
    }];
    
    NSDictionary *conversationDic =
    @{
            @"gid" : _gid,
           @"name" : _chatName,
        @"msgDate" : [NSDate dateString],
        @"msgType" : [NSNumber numberWithInt:MSG_TEXT],
            @"msg" : text
      };
    [DBManager saveChatConversationByDic:conversationDic isUnread:NO];
}

- (void)IV_Record:(BOOL)start{
   
    if (start) {
        [RecordManager startRecord];
    }
    else{
        [RecordManager stopRecord:^(BOOL flag, NSString *fileName,NSString *filePath,  NSTimeInterval recordDur) {

            if (!flag) {
                return ;
            }
            if (recordDur < 2) {
                return;
            }
            
            NSDictionary *msgDic =
            @{
                    @"uid" : [UDManager getUserId],
                    @"gid" : _gid,
                    @"msg" : fileName,
                @"msgType" : [NSNumber numberWithInt:MSG_RECORD],
              @"voiceTime" : [NSNumber numberWithFloat:recordDur],
             @"sendResult" : [NSNumber numberWithInt:SR_Sending]
              };
            Message *message = [DBManager saveChatMessageByDic:msgDic];
            
            [HttpManager uploadFileByFilePath:filePath handler:^(NSDictionary *dataDic) {
                if (PttDicResult(dataDic)) {
                    
                    [HttpManager sendMsgToGroupId:_gid message:fileName msgType:MSG_RECORD voiceTime:recordDur handler:^(NSDictionary *dataDic) {
                        int sendResult = PttDicResult(dataDic) == ACK_OK ? SR_OK : SR_Fail;
                        [DBManager updateMessageSendResult:message result:sendResult];
                    }];
                }
                else{
                    [DBManager updateMessageSendResult:message result:SR_Fail];
                }
            }];
            
            NSDictionary *conversationDic =
            @{
                    @"gid" : _gid,
                   @"name" : _chatName,
                @"msgDate" : [NSDate dateString],
                @"msgType" : [NSNumber numberWithInt:MSG_RECORD]
              };
            [DBManager saveChatConversationByDic:conversationDic isUnread:NO];
        }];
    }
}

- (void)IV_Talk:(BOOL)start{
    if (start) {
        [[PttService sharedInstance] PTT_StartTalk];
    }
    else{
        [[PttService sharedInstance] PTT_StopTalk];
    }
}

- (void)IV_TalkState:(BOOL)join{
    PTT_StartLoadingAnimation();
    if (join) {
        [HttpManager joinGroupTalkByGroupId:_gid Handler:^(NSDictionary *dataDic) {
            if ( PttDicResult(dataDic) == ACK_OK ) {
                NSDictionary *msgDic =
                @{
                        @"uid" : [UDManager getUserId],
                        @"gid" : _gid,
                    @"message" : @"加入对讲",
                  };
                [DBManager saveTalkMessageByDic:msgDic];
                
                NSDictionary *dic =
                @{
                        @"gid" : _gid,
                    @"message" : @"加入对讲",
                  };
                [DBManager saveTalkConversationByDic:dic isUnread:NO];
                [UDManager saveCurrentGroup:_gid];
            }
            PTT_StopLoadingAnimation();
        }];
    }
    else{
        [HttpManager quitGroupTalkByGroupId:_gid Handler:^(NSDictionary *dataDic) {
            if ( PttDicResult(dataDic) == ACK_OK ) {
                NSDictionary *msgDic =
                @{
                        @"uid" : [UDManager getUserId],
                        @"gid" : _gid,
                    @"message" : @"退出对讲",
                  };
                [DBManager saveTalkMessageByDic:msgDic];
                
                NSDictionary *dic =
                @{
                        @"gid" : _gid,
                    @"message" : @"退出对讲",
                  };
                [DBManager saveTalkConversationByDic:dic isUnread:NO];
                [UDManager saveCurrentGroup:nil];
            }
            PTT_StopLoadingAnimation();
        }];
    }
}

#pragma mark ------- Chat Cell Delegate ---------
- (void)ChatCell_playRecordByIndex:(NSInteger)index
                              play:(BOOL)play{

    if (play) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        Message *message = [_fetchedResultsController objectAtIndexPath:indexPath];
        
        if ([message.unread  boolValue]) {
            [DBManager updateMessageUnread:message];
        }
        [RecordManager playWithFileName:message.msg complete:^{

        }];
    }
}

/*
#pragma mark ------- Ptts Noti Delegate ---------
- (void)PttsNoti_messageByDic:(NSDictionary *)dic{
//    NSString *gid = dic[@"gid"];
//    if (![gid isEqualToString:_gid]) {
//        return;
//    }
//    //1.获得时间
//    NSString *locationString=[NSDate dateString];
//    
//    int type = [dic[@"msgType"] intValue];
//    
//    //2.创建一个MessageModel类
//    MessageModel *message = [[MessageModel alloc] init];
//    message.msgType = type;
//    message.dateString = locationString;
//    message.msg = dic[@"msg"];
//    message.fromSelf = NO;
//    message.showTime = YES;
//    message.senderName = dic[@"name"];
//    message.recordDur = [dic[@"voiceTime"] floatValue];
//    message.date = [NSDate date];
//    message.isUnread = YES;
//    //3.创建一个CellFrameModel类
//    ChatCellFrameModel *cellFrame = [[ChatCellFrameModel alloc] init];
//    //    ChatCellFrameModel *lastCellFrame = [_cellFrameDatas lastObject];
//    //    message.showTime = ![lastCellFrame.message.time isEqualToString:message.time];
//    cellFrame.message = message;
//    
//    //4.添加进去，并且刷新数据
//    [_messageArray addObject:cellFrame];
//    [_tableView reloadData];
//    
//    //5.自动滚到最后一行
//    [self tableViewScrollToBottom];
//    
//    [DBManager saveMessageByMessageModle:message groupId:_gid];
}

- (void)PttsNoti_friendJoinTalkToGroupId:(NSString *)gid
                                     msg:(NSString *)msg{
//    if (![gid isEqualToString:_gid]) {
//        return;
//    }
//    
//    //1.获得时间
//    NSString *locationString=[NSDate dateString];
//    
//    int type = MSG_TALK;
//    
//    //2.创建一个MessageModel类
//    MessageModel *message = [[MessageModel alloc] init];
//    message.msgType = type;
//    message.dateString = locationString;
//    message.msg = msg;
//    message.fromSelf = NO;
//    message.showTime = YES;
//    message.date = [NSDate date];
//    message.isUnread = NO;
//    //3.创建一个CellFrameModel类
//    ChatCellFrameModel *cellFrame = [[ChatCellFrameModel alloc] init];
//    //    ChatCellFrameModel *lastCellFrame = [_cellFrameDatas lastObject];
//    //    message.showTime = ![lastCellFrame.message.time isEqualToString:message.time];
//    cellFrame.message = message;
//    
//    //4.添加进去，并且刷新数据
//    [_messageArray addObject:cellFrame];
//    [_tableView reloadData];
//    
//    //5.自动滚到最后一行
//    [self tableViewScrollToBottom];
//    
}
//
- (void)PttsNoti_friendQuitTalkFromGroupId:(NSString *)gid
                                       msg:(NSString *)msg{
//    if (![gid isEqualToString:_gid]) {
//        return;
//    }
//    
//    //1.获得时间
//    NSString *locationString=[NSDate dateString];
//    
//    int type = MSG_TALK;
//    
//    //2.创建一个MessageModel类
//    MessageModel *message = [[MessageModel alloc] init];
//    message.msgType = type;
//    message.dateString = locationString;
//    message.msg = msg;
//    message.fromSelf = NO;
//    message.showTime = YES;
//    message.date = [NSDate date];
//    message.isUnread = NO;
//    //3.创建一个CellFrameModel类
//    ChatCellFrameModel *cellFrame = [[ChatCellFrameModel alloc] init];
//    //    ChatCellFrameModel *lastCellFrame = [_cellFrameDatas lastObject];
//    //    message.showTime = ![lastCellFrame.message.time isEqualToString:message.time];
//    cellFrame.message = message;
//    
//    //4.添加进去，并且刷新数据
//    [_messageArray addObject:cellFrame];
//    [_tableView reloadData];
//    
//    //5.自动滚到最后一行
//    [self tableViewScrollToBottom];
}
*/

#pragma mark ------- Ptt Service Delegate ---------
-(void)PttS_recvStartListernNoti:(NSString *)talkerName{
    DLog(@"PttS_recvStartListernNoti");
    [_inputView setMiddleBtnEnable:NO];
}

- (void)PttS_recvStopListernNoti{
     DLog(@"PttS_recvStopListernNoti");
    [_inputView setMiddleBtnEnable:YES];
}


- (void)dealloc{
    _fetchedResultsController = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end

