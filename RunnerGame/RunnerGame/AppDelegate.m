//
//  AppDelegate.m
//  RunnerGame
//
//  Created by Ivan Borsa on 03/04/14.
//  Copyright (c) 2014 Weloux. All rights reserved.
//
@import AVFoundation;
#import "AppDelegate.h"
#import "HighScoreManager.h"
#import "GameScene.h"
#import "GameOverScene.h"
#import "NetworkManager.h"
#import "CommonTools.h"

@interface AppDelegate()

@property (nonatomic) UINavigationController *navigationController;

@end

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        //GameScene *gs = [[GameScene alloc] initWithSize:CGSizeZero];
        GameOverScene *gos = [[GameOverScene alloc] initWithSize:CGSizeZero];
    });
    
    __block NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *dirtyScore = [defaults objectForKey:kDirtyScoreKey];
    if (dirtyScore) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [[HighScoreManager sharedManager] uploadHighscore:dirtyScore.intValue];
        });
    }
    //[[HighScoreManager sharedManager] getSurroundings];
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
    SKView* view = [self getSKViewSubview];
    
    if (view) {
        view.paused = YES;
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    SKView* view = [self getSKViewSubview];
    
    if (view) {
        view.paused = NO;
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(SKView *)getSKViewSubview
{
    for (UIView* s in self.window.rootViewController.view.subviews) {
        if ([s isKindOfClass:[SKView class]]) {
            return (SKView*)s;
        }
    }
    return nil;
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            [_managedObjectContext setPersistentStoreCoordinator:coordinator];
        });
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"RunnerDataModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"RunnerDataModel.sqlite"];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        //NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (void) copyDatabaseIfNeeded {
    
    //Using NSFileManager we can perform many file system operations.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSString *dbPath = [self getDBPath];
    BOOL success = [fileManager fileExistsAtPath:dbPath];
    
    if(success) {
        
        NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"RunnerDataModel.sqlite"];
        success = [fileManager copyItemAtPath:defaultDBPath toPath:dbPath error:&error];
        
        if (!success)
            NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
}

- (NSString *) getDBPath {
    //Search for standard documents using NSSearchPathForDirectoriesInDomains
    //First Param = Searching the documents directory
    //Second Param = Searching the Users directory and not the System
    //Expand any tildes and identify home directories.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    return [documentsDir stringByAppendingPathComponent:@"RunnerDataModel.sqlite"];
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
