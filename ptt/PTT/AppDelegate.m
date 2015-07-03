//
//  AppDelegate.m
//  PTT
//
//  Created by xihan on 15/6/14.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import "AppDelegate.h"
#import "LoadingView.h"
#import "SocketConnect.h"
#import "UdpPacket.h"
#import "UDManager.h"
#import "PttService.h"
#import "AudioManager.h"

#import "LoginViewController.h"
#import "HomePageViewController.h"
#import "FriendsViewController.h"
#import "GroupsViewController.h"
#import "SettingViewController.h"

#import "PttTabBarController.h"
#import "PttNavigationController.h"

#import <AVFoundation/AVFoundation.h>

@interface AppDelegate (){
    LoadingView *_loadingView;
    BOOL _first;
}

@property (strong, nonatomic) NSThread  *recvThread;
@property (strong, nonatomic) PttNavigationController *mPttNavigationController;
@property (strong, nonatomic) PttTabBarController *mPttTabBarController;
@property (assign, nonatomic) BOOL isRunning;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    //后台播放音频设置
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    //让app支持接受远程控制事件
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];

    
    HomePageViewController *homePageViewController = [[HomePageViewController alloc] init];
    FriendsViewController *friendsViewController = [[FriendsViewController alloc] initWithNibName:@"FriendsViewController" bundle:nil];
    GroupsViewController *groupsViewController = [[GroupsViewController alloc] initWithNibName:@"GroupsViewController" bundle:nil];
    SettingViewController *settingViewController = [[SettingViewController alloc] initWithNibName:@"SettingViewController" bundle:nil];
    
    _mPttTabBarController = [[PttTabBarController alloc] init];
    _mPttTabBarController.viewControllers =
    @[
      homePageViewController,
      friendsViewController,
      groupsViewController,
      settingViewController
      ];
    
    _mPttNavigationController = [[PttNavigationController alloc] initWithRootViewController:_mPttTabBarController];
    _mPttNavigationController.navigationBarHidden = YES;
    LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    [_mPttNavigationController pushViewController:loginViewController animated:NO];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _window.rootViewController = _mPttNavigationController;
    [_window makeKeyAndVisible];
    
    WEAKSELF;
    [[NSNotificationCenter defaultCenter] addObserverForName:@"logout" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [weakSelf dataBaseCleanUp];
    }];
    
//    [UDManager saveCurrentGroup:nil];
//    [UDManager saveTalkState:NO];
    
    [UDManager deleteCach];
    _first = YES;
    
 /*
  远程推送
  */
    if (FSystemVersion >= 8.0) {
        UIUserNotificationSettings *setting = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeSound | UIUserNotificationTypeAlert| UIUserNotificationTypeBadge categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:setting];
        [application registerForRemoteNotifications];
    }
    else{
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIUserNotificationTypeSound | UIUserNotificationTypeAlert| UIUserNotificationTypeBadge];
    }
    
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
 
    if (![UDManager isTalking]) {
        _isRunning = NO;
        Solgo_UDP_Close();
    }
    else{
        DLog(@"enter backgroud");
        Solgo_AudioManager_StartPlayProcess(BGM);
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if ( ![UDManager isTalking] || _first) {
        Solgo_UDP_Init();
        _isRunning = YES;
        _first = NO;
        if ( nil == _recvThread )
        {
            _recvThread = [[ NSThread alloc ]initWithTarget:self selector:@selector(recv) object:nil];
            [ _recvThread start ];
        }
    }
    Solgo_AudioManager_StopBGM();
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContextWithWait:YES];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
  
    DLog(@"%@",deviceToken);
}


- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error.localizedDescription message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//    [alert show];
    DLog(@"FailToRegisterForRemoteNotifications : %@",error.localizedDescription);
}

-(void)recv
{
    while (_isRunning)
    {
        UdpPacket *packet;
        packet=Solgo_UDP_Recv();
        if ( packet != nil )
        {
            dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [ [  PttService sharedInstance  ] PttRecvPacket:packet ];
            });
        }
    }
    _recvThread = nil;
    
}

#pragma  mark ----------loadingAnimate-----------
- (void)startLoadingAnimate{
    if (_loadingView == nil) {
        _loadingView = [[LoadingView alloc] initWithSuperVC:_mPttNavigationController];
    }
    [_loadingView startLoading];
}

void PTT_StartLoadingAnimation(){
    AppDelegate *delegate = ShareDelegate;
    [delegate startLoadingAnimate];
}

void PTT_StopLoadingAnimation(){
    AppDelegate *delegate = ShareDelegate;
    [delegate stopLoadingAnimate];
}

- (void)stopLoadingAnimate{
    [_loadingView stopLoading];
}

- (void)showLoginView{
    LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    _mPttTabBarController.selectedIndex = 0;
    [_mPttNavigationController pushViewController:loginViewController animated:NO];
}



#pragma mark - Core Data stack


@synthesize mainThreadContext = _mainThreadContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize backgroundContext = _backgroundContext;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.stwx.PTT" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"PTT" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {

    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSString *name = [NSString stringWithFormat:@"%@.sqlite",[UDManager getUserId]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:name];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    
    NSDictionary *options =
    @{
      NSMigratePersistentStoresAutomaticallyOption : @1,
            NSInferMappingModelAutomaticallyOption : @1
      };
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)mainThreadContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_mainThreadContext != nil) {
        return _mainThreadContext;
    }
    _mainThreadContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    _mainThreadContext.parentContext = [self backgroundContext];
    return _mainThreadContext;
}

- (NSManagedObjectContext *)backgroundContext{
    if (_backgroundContext != nil) {
        return _backgroundContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _backgroundContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_backgroundContext setPersistentStoreCoordinator:[self persistentStoreCoordinator]];
    return _backgroundContext;
}

- (NSManagedObjectContext *)temporaryContext{
    NSManagedObjectContext *temporaryContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    temporaryContext.parentContext = [self mainThreadContext];
    return temporaryContext;
}

#pragma mark - Core Data Saving support

- (void)saveContextWithWait:(BOOL)wait {
    NSManagedObjectContext *managedObjectContext = [self mainThreadContext];
    NSManagedObjectContext *backObjectContext = [self backgroundContext];
    
    if (managedObjectContext == nil) {
        return;
    }
    if ([managedObjectContext hasChanges]) {
        [managedObjectContext performBlockAndWait:^{
            NSError *error = nil;
            if (![managedObjectContext save:&error]) {
                DLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        }];
    }
    
    if (backObjectContext == nil) {
        return;
    }
    if ([backObjectContext hasChanges]) {
        if (wait) {
            [backObjectContext performBlockAndWait:^{
                NSError *error = nil;
                if (![backObjectContext save:&error]) {
                    DLog(@"Unresolved error %@, %@", error, [error userInfo]);
                    abort();
                }
            }];
        }
        else{
            [backObjectContext performBlock:^{
                NSError *error = nil;
                if (![backObjectContext save:&error]) {
                    DLog(@"Unresolved error %@, %@", error, [error userInfo]);
                    abort();
                }
            }];
        }
        
    }
}

- (void)dataBaseCleanUp{
    
    [_mainThreadContext reset];
    [_backgroundContext reset];
    
    _mainThreadContext = nil;
    _backgroundContext = nil;
    
    [_persistentStoreCoordinator removePersistentStore:_persistentStoreCoordinator.persistentStores[0] error:nil];
    
    _persistentStoreCoordinator = nil;
    _managedObjectModel = nil;

}
@end
