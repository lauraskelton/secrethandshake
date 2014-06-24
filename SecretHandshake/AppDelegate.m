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

#import "GTMHTTPFetcher.h"
#import "GTMOAuth2ViewControllerTouch.h"

#import "OAuthHandler.h"

@import CoreLocation;

@interface AppDelegate () <CLLocationManagerDelegate, OAuthHandlerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (nonatomic, retain) NSNumber *lastUserID;
@property (nonatomic, retain) NSTimer *currentTimer;
@property (nonatomic, retain) MasterViewController *masterViewController;

@property (nonatomic, retain) OAuthHandler *oauthHandler;

- (void)getUserSignIn:(id)sender;
- (void)authorizeFromExternalURL:(NSURL *)url;

-(void)downloadMyProfile:(id)sender;

- (void)initRegion;

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
    
    [TestFlight setOptions:@{ TFOptionManualSessions : @YES }];
    
    [TestFlight takeOff:@"5b09de90-f520-4781-bb58-09076761115f"];
    
    [TestFlight manuallyStartSession];
    
    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    self.masterViewController = (MasterViewController *)navigationController.topViewController;
    self.masterViewController.managedObjectContext = self.managedObjectContext;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kSHAccessTokenKey] == nil) {
        //[self authorize:nil];
        [self getUserSignIn:nil];
    } else {
        [self downloadMyProfile:nil];
        [self initRegion];
        [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    }
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    // secrethandshake://oauth?access_token=324235253442
    
    NSLog(@"url recieved: %@", url);
    NSLog(@"query string: %@", [url query]);
    NSLog(@"host: %@", [url host]);
    NSLog(@"url path: %@", [url path]);
    
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
    NSLog(@"getting user sign in");
    
    //NSURL *authURL = [NSURL URLWithString:@"http://www.beerchooser.com/hackerschool/OAuth2/oauthios.php"];
    
    NSURL *authURL = [NSURL URLWithString:@"http://secrethandshakeapp.com/auth.php"];

    [[UIApplication sharedApplication] openURL:authURL];
}

- (void)authorizeFromExternalURL:(NSURL *)url
{
    
    self.oauthHandler = [[OAuthHandler alloc] init];
    
    self.oauthHandler.delegate = self;
    
    [self.oauthHandler handleAuthTokenURL:url];
    
}

/*

- (GTMOAuth2Authentication *)hackerSchoolAuth
{
    
    // Set the token URL to the Singly token endpoint.
    NSURL *tokenURL = [NSURL URLWithString:@"https://www.hackerschool.com/oauth/token"];
    
    // Set a bogus redirect URI. It won't actually be used as the redirect will
    // be intercepted by the OAuth library and handled in the app.
    NSString *redirectURI = @"secrethandshake://oauth";
    
    GTMOAuth2Authentication *auth;
    auth = [GTMOAuth2Authentication authenticationWithServiceProvider:@"Secret Handshake"
                                                             tokenURL:tokenURL
                                                          redirectURI:redirectURI
                                                             clientID:kMyClientID
                                                         clientSecret:kMyClientSecret];
    
    // The Singly API does not return a token type, therefore we set one here to
    // avoid a warning being thrown.
    [auth setTokenType:@"HackerSchoolToken"];
    
    return auth;
}

- (void)authorize:(NSString *)service
{
    GTMOAuth2Authentication *auth = [self hackerSchoolAuth];
    
    // Prepare the Authorization URL.
    NSURL *authURL = [NSURL URLWithString:@"https://www.hackerschool.com/oauth/authorize"];
    
    // Display the authentication view
    GTMOAuth2ViewControllerTouch *viewController;
    viewController = [ [GTMOAuth2ViewControllerTouch alloc] initWithAuthentication:auth
                                                                  authorizationURL:authURL
                                                                  keychainItemName:nil
                                                                          delegate:self
                                                                  finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    [viewController setBrowserCookiesURL:[NSURL URLWithString:@"https://www.hackerschool.com/"]];
    [viewController.navigationItem setHidesBackButton:YES];
    [viewController.navigationItem setTitle:@"Secret Handshake"];
    
    // Push the authentication view to our navigation controller instance
    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    [ navigationController pushViewController:viewController animated:YES];
}
 - (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
 finishedWithAuth:(GTMOAuth2Authentication *)auth
 error:(NSError *)error
 {
 if (error != nil)
 {
 // Authentication failed
 UIAlertView *alertView = [ [UIAlertView alloc] initWithTitle:@"Authorization Failed"
 message:[error localizedDescription]
 delegate:self
 cancelButtonTitle:@"Dismiss"
 otherButtonTitles:nil];
 [alertView show];
 }
 else
 {
 // Authentication succeeded
 
 // Save the access token
 
 [[NSUserDefaults standardUserDefaults] setObject:auth.accessToken forKey:kSHAccessTokenKey];
 
 [self downloadMyProfile:nil];
 }
 }

 */

- (void)oauthHandlerDidAuthorizeWithAuth:(GTMOAuth2Authentication *)auth
{
    // Authentication succeeded
    
    // Save the access token
    
    [[NSUserDefaults standardUserDefaults] setObject:auth.accessToken forKey:kSHAccessTokenKey];
    
    [self downloadMyProfile:nil];
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

-(void)downloadMyProfile:(id)sender
{
    
    NSURL *profilesURL = [NSURL URLWithString:[@"https://www.hackerschool.com/api/v1/people/me?access_token=" stringByAppendingString:[[NSUserDefaults standardUserDefaults] objectForKey:kSHAccessTokenKey]]];
    NSURLRequest *request = [NSURLRequest requestWithURL:profilesURL];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               NSString *responseBody = [ [NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                               //NSLog(@"Received Response: %@", responseBody);
                               
                               
                               NSData *jsonData = [responseBody dataUsingEncoding:NSUTF8StringEncoding];
                               NSError *e;
                               NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&e];
                               
                               if (e != nil) {
                                   NSLog(@"error: %@", e);
                               } else {
                                   NSLog(@"JSON Response My Profile: %@", jsonDict);
                                   if ([jsonDict objectForKey:@"message"] != nil) {
                                       if ([[jsonDict objectForKey:@"message"] isEqualToString:@"unauthorized"]) {
                                           //[self authorize:nil];
                                           [self getUserSignIn:nil];
                                       } else {
                                           NSLog(@"error message from HS api: %@", [jsonDict objectForKey:@"message"]);
                                       }
                                       [TestFlight passCheckpoint:@"LOGIN_ERROR"];
                                   } else {
                                   
                                       [TestFlight passCheckpoint:@"LOGIN_SUCCESS"];

                                       HackerSchooler *thisHackerSchooler = [HackerSchooler hackerSchoolerWithUniqueUserID:@((NSInteger)[jsonDict valueForKey:@"id"]) andFirstName:[jsonDict objectForKey:@"first_name"] andLastName:[jsonDict objectForKey:@"last_name"] andBatch:[[jsonDict objectForKey:@"batch"] objectForKey:@"name"] inManagedObjectContext:self.managedObjectContext];
                                       
#warning testing pick random user
                                       if ([[jsonDict valueForKey:@"id"] intValue] == 759) {
                                           // pick a random user id for testing
                                           NSArray *userIDs = @[@"36", @"94", @"53", @"34", @"29", @"35", @"96", @"759"];
                                           NSString *randUser = [userIDs objectAtIndex: arc4random() % [userIDs count]];
                                           [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:[randUser integerValue]] forKey:kSHUserIDKey];
                                           randUser = nil;
                                           userIDs = nil;
                                       } else {
                                           [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:[[jsonDict valueForKey:@"id"] integerValue]] forKey:kSHUserIDKey];
                                       }
                                       
                                       NSLog(@"my user id: %@", [jsonDict objectForKey:@"id"]);
                                       
                                       [self.masterViewController startIBeacon:nil];
                                       
                                       UIAlertView *alertView = [ [UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Hello %@", thisHackerSchooler.first_name]
                                                                                            message:[NSString stringWithFormat:@"Batch %@", thisHackerSchooler.batch]
                                                                                           delegate:self
                                                                                  cancelButtonTitle:@"Dismiss"
                                                                                  otherButtonTitles:nil];
                                       [alertView show];
                                       
                                       [self initRegion];
                                       [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
                                   }
                               }
                               
                           }];
}

#pragma mark - iBeacon methods

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        NSLog(@"did exit region: %@", region);
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        NSLog(@"did enter region: %@", region);
    }
}

- (void)locationManager:(CLLocationManager *)manager
        didRangeBeacons:(NSArray *)beacons
               inRegion:(CLBeaconRegion *)region
{
    for (CLBeacon *beacon in beacons) {
        
        if ([beacon.minor integerValue] > 0) {
            NSLog(@"beacon: %@", beacon);
#warning alter here for same-person pings

            if (([self.lastUserID integerValue] != [beacon.minor integerValue]) && ([beacon.minor integerValue] != [[[NSUserDefaults standardUserDefaults] objectForKey:kSHUserIDKey] integerValue]) && ([beacon.minor integerValue] > 0)) {

                NSLog(@"did range beacon: %@", beacon);
                
                NSURL *profilesURL = [NSURL URLWithString:[NSString stringWithFormat: @"https://www.hackerschool.com/api/v1/people/%@?access_token=%@", beacon.minor,[[NSUserDefaults standardUserDefaults] objectForKey:kSHAccessTokenKey]]];
                NSURLRequest *request = [NSURLRequest requestWithURL:profilesURL];
                
                [NSURLConnection sendAsynchronousRequest:request
                                                   queue:[NSOperationQueue mainQueue]
                                       completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                           
                   NSString *responseBody = [ [NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                           
                                           NSLog(@"response: %@", responseBody);
                   
                   NSData *jsonData = [responseBody dataUsingEncoding:NSUTF8StringEncoding];
                   NSError *e;
                   NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&e];
                   
                   if (e != nil) {
                       NSLog(@"error: %@", e);
                   } else {
                       if ([jsonDict objectForKey:@"message"] != nil) {
                           if ([[jsonDict objectForKey:@"message"] isEqualToString:@"unauthorized"]) {
                               //[self authorize:nil];
                               [self getUserSignIn:nil];
                           } else {
                               NSLog(@"error message from HS api: %@", [jsonDict objectForKey:@"message"]);
                           }
                       }
                        else {
                            [TestFlight passCheckpoint:@"FOUND_HACKER_SCHOOLER"];

                           // add new hacker schooler to core data
                           HackerSchooler *thisHackerSchooler = [HackerSchooler hackerSchoolerWithUniqueUserID:[jsonDict objectForKey:@"id"] andFirstName:[jsonDict objectForKey:@"first_name"] andLastName:[jsonDict objectForKey:@"last_name"] andBatch:[[jsonDict objectForKey:@"batch"] objectForKey:@"name"] inManagedObjectContext:self.managedObjectContext];
                           
                           thisHackerSchooler.photoURL = [jsonDict objectForKey:@"image"];
                           
                           // add this event to core data
                           if (thisHackerSchooler.lastEventTime != nil) {
                               NSTimeInterval distanceBetweenDates = [[NSDate date] timeIntervalSinceDate:thisHackerSchooler.lastEventTime];
                               double secondsInAnHour = 3600.0;
                               CGFloat hoursBetweenDates = distanceBetweenDates / secondsInAnHour;
#warning alter here for more frequent alerts
                               if (hoursBetweenDates > 1.0) {
                                   // record this as a new event
                                   [self addEventWithHackerSchooler:thisHackerSchooler andBeacon:beacon];
                               }
                           } else {
                               // record this as a new event
                               [self addEventWithHackerSchooler:thisHackerSchooler andBeacon:beacon];
                           }
                           thisHackerSchooler = nil;
                           [self saveContext];
                       }
                   }
                   
               }];
                [self markCurrentUserID:beacon.minor];
  
            }
        }
    }
}

-(void)addEventWithHackerSchooler:(HackerSchooler *)hackerSchooler andBeacon:(CLBeacon *)beacon
{
    Event *newEvent = [Event createEventWithHackerSchooler:hackerSchooler inManagedObjectContext:self.managedObjectContext];
    [hackerSchooler addEventsObject:newEvent];
    newEvent = nil;
    
    NSString *distanceString = @"";
    if (beacon.proximity == CLProximityUnknown) {
        distanceString = @"Unknown Proximity";
    } else if (beacon.proximity == CLProximityImmediate) {
        distanceString = @"Immediate";
    } else if (beacon.proximity == CLProximityNear) {
        distanceString = @"Near";
    } else if (beacon.proximity == CLProximityFar) {
        distanceString = @"Far";
    }
    
    NSLog(@"hacker schooler distance: %@", distanceString);
    
    // notify user of new event
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = @"Found Hacker Schooler!";
    notification.soundName = @"Default";
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

-(void)markCurrentUserID:(NSNumber *)userID
{
    NSLog(@"marking id: %@", userID);
    [self.currentTimer invalidate];
    self.currentTimer = nil;
    self.lastUserID = userID;
    [self intervalTimer];
}

- (void) intervalTimer {
    self.currentTimer = [NSTimer scheduledTimerWithTimeInterval:60
                                     target:self
                                   selector:@selector(resetBeacons:)
                                   userInfo:nil
                                    repeats:NO];
}

- (void) resetBeacons:(NSTimer *) timer {
    //do something here..
    self.lastUserID = nil;
}

/*
 -(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
 CLBeacon *beacon = [[CLBeacon alloc] init];
 beacon = [beacons lastObject];
 
 NSString *distanceString = @"";
 if (beacon.proximity == CLProximityUnknown) {
 distanceString = @"Unknown Proximity";
 } else if (beacon.proximity == CLProximityImmediate) {
 distanceString = @"Immediate";
 } else if (beacon.proximity == CLProximityNear) {
 distanceString = @"Near";
 } else if (beacon.proximity == CLProximityFar) {
 distanceString = @"Far";
 }
 
 UILocalNotification *notification = [[UILocalNotification alloc] init];
 notification.alertBody = [NSString stringWithFormat: @"Found Hacker Schooler! %@ %@", beacon.minor, distanceString];
 notification.soundName = @"Default";
 [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
 
 }
 */

- (void)initRegion
{
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"3ee761a0-f737-11e3-a3ac-0800200c9a66"];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"region42"];
    self.beaconRegion.notifyEntryStateOnDisplay = YES;
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
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
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
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
