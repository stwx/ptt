//
//  AppDelegate.h
//  PTT
//
//  Created by xihan on 15/6/14.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *mainThreadContext;
@property (readonly, strong, nonatomic) NSManagedObjectContext * backgroundContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)showLoginView;
- (void)saveContextWithWait:(BOOL)wait;
- (NSURL *)applicationDocumentsDirectory;
- (NSManagedObjectContext *)temporaryContext;

@end

