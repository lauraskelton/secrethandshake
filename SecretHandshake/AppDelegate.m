//
//  AppDelegate.m
//  SecretHandshake
//
//  Created by Laura Skelton on 6/18/14.
//  Copyright (c) 2014 Laura Skelton. All rights reserved.
//

#import "SecretHandshake-Prefix.pch"

#import "AppDelegate.h"
#import "MasterViewController.h"
#import "HackerSchooler.h"
#import "Event.h"
#import "MasterViewController.h"

#import "TestFlight.h"
#import "TestFlight+ManualSessions.h"

#import "OAuthHandler.h"
#import "HackerSchoolAPIManager.h"
#import "IBeaconSearchHandler.h"
#import "IBeaconTransmitHandler.h"

@interface AppDelegate () <OAuthHandlerDelegate, HackerSchoolAPIManagerDelegate, IBeaconSearchHandlerDelegate>

@property (nonatomic, retain) MasterViewController *masterViewController;

- (void)getUserSignIn:(id)sender;
- (void)authorizeFromExternalURL:(NSURL *)url;

@end


@implementation AppDelegate
            
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kSHUserIDKey] != nil) {
        [TestFlight addCustomEnvironmentInformation:[[NSUserDefaults standardUserDefaults] objectForKey:kSHUserIDKey] forKey:@"userid"];
    }
    
    // Use Manual Sessions because we want to keep the session going when the app is backgrounded during OAuth login process
    [TestFlight setOptions:@{ TFOptionManualSessions : @YES }];
    [TestFlight takeOff:kTestFlightAppID];
    [TestFlight manuallyStartSession];
    
    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    self.masterViewController = (MasterViewController *)navigationController.topViewController;
    self.masterViewController.managedObjectContext = self.managedObjectContext;

    if ([[NSUserDefaults standardUserDefaults] objectForKey:kSHAccessTokenKey] == nil) {
        [self getUserSignIn:nil];
    } else {
        [[HackerSchoolAPIManager sharedWithContext:self.managedObjectContext] downloadUserProfileWithID:nil isMe:@YES];
    }
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    // secrethandshake://oauth?access_token=324235253442
    
    NSLog(@"url recieved: %@", url);
    
    if ([[url host] isEqualToString:@"oauth"]) {
        // parse the authentication code query
        [self authorizeFromExternalURL:url];
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
    [TestFlight passCheckpoint:@"ENTERED_BACKGROUND"];

}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [TestFlight passCheckpoint:@"ENTERED_FOREGROUND"];

}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
    [TestFlight manuallyEndSession];
}

#pragma mark - OAuth methods

- (void)getUserSignIn:(id)sender
{
    [OAuthHandler sharedHandler].delegate = self;
    [[OAuthHandler sharedHandler] handleUserSignIn:nil];
}

- (void)authorizeFromExternalURL:(NSURL *)url
{
    [OAuthHandler sharedHandler].delegate = self;
    [[OAuthHandler sharedHandler] handleAuthTokenURL:url];
}

- (void)oauthHandlerDidAuthorize
{
    [[HackerSchoolAPIManager sharedWithContext:self.managedObjectContext] downloadUserProfileWithID:nil isMe:@YES];
}

- (void)oauthHandlerDidFailWithError:(NSString *)errorMessage
{
    // Authentication failed
    UIAlertView *alertView = [ [UIAlertView alloc] initWithTitle:@"Authorization Failed"
                                                         message:errorMessage
                                                        delegate:self
                                               cancelButtonTitle:@"Dismiss"
                                               otherButtonTitles:nil];
    [alertView show];

}

#pragma mark - IBeaconSearchHandler Delegate

- (void)iBeaconSearchHandlerFoundUserWithID:(NSNumber *)userID
{
    [[HackerSchoolAPIManager sharedWithContext:self.managedObjectContext] downloadUserProfileWithID:userID isMe:@NO];
}

#pragma mark - Hacker School API Manager Delegate

- (void)hackerSchoolAPIUnauthorized
{
    [self getUserSignIn:nil];
}

- (void)hackerSchoolAPIError
{
    NSLog(@"error connecting to Hacker School API");
}

- (void)hackerSchoolAPIGotMyProfile
{
    [self saveContext];
    
    // Start transmitting our iBeacon
    [[IBeaconTransmitHandler shared] startIBeacon];
    
    // Start searching for nearby iBeacons
    [[IBeaconSearchHandler shared] initRegion];
}

- (void)hackerSchoolAPIAddedEvent
{
    [self saveContext];
}

- (void)hackerSchoolAPIMarkCurrentUser:(NSNumber *)userID
{
    [[IBeaconSearchHandler shared] markCurrentUserID:userID];
}

#pragma mark - Core Data stack

- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"SecretHandshake" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"SecretHandshake.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {

        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
