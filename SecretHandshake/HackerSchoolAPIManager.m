//
//  HackerSchoolAPIManager.m
//  SecretHandshake
//
//  Created by Laura Skelton on 7/2/14.
//  Copyright (c) 2014 Laura Skelton. All rights reserved.
//

#import "HackerSchoolAPIManager.h"
#import "SecretHandshake-Prefix.pch"
#import "HackerSchooler.h"
#import "Event.h"
#import <CoreData/CoreData.h>
#import "HackerSchoolAPIManager_Internal.h"

@implementation HackerSchoolAPIManager
@synthesize delegate, managedObjectContext;

- (id)init
{
    
    // designated initializer
    self = [super init];
    if (self) {
        
    }
    return self;
}

+ (HackerSchoolAPIManager *)sharedWithContext:(NSManagedObjectContext *)context
{
    static HackerSchoolAPIManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[HackerSchoolAPIManager alloc] init];
        _sharedManager.managedObjectContext = context;
        
    });
    
    return _sharedManager;
}

-(void)downloadUserProfileWithID:(NSNumber *)userID isMe:(NSNumber *)isMe
{
    NSURLRequest *request = [self downloadUserProfileRequestWithID:userID isMe:isMe];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               [self handleResponseWithData:data andError:error isMe:isMe];
                               
                           }];
}

-(NSURLRequest *)downloadUserProfileRequestWithID:(NSNumber *)userID isMe:(NSNumber *)isMe
{
    NSURL *profilesURL;
    if ([isMe boolValue]) {
        profilesURL = [NSURL URLWithString:@"https://www.hackerschool.com/api/v1/people/me"];
    } else {
        profilesURL = [NSURL URLWithString:[NSString stringWithFormat: @"https://www.hackerschool.com/api/v1/people/%@", userID]];
        [self.delegate hackerSchoolAPIMarkCurrentUser:userID];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:profilesURL];
    [request setValue:[NSString stringWithFormat:@"Bearer %@", [[NSUserDefaults standardUserDefaults] objectForKey:kSHAccessTokenKey]] forHTTPHeaderField:@"Authorization"];
    
    return request;
}

-(BOOL)handleResponseWithData:(NSData *)data andError:(NSError *)error isMe:(NSNumber *)isMe
{
    if (error == nil && data != nil) {
        NSString *responseBody = [ [NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        if (responseBody != nil) {
            
            NSLog(@"response: %@", responseBody);
            
            //NSData *jsonData = [responseBody dataUsingEncoding:NSUTF8StringEncoding];
            
            NSError *e;
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&e];
            
            NSLog(@"jsonDict: %@", jsonDict);
            
            if (e != nil) {
                NSLog(@"error creating json object from response: %@", e);
                [self.delegate hackerSchoolAPIError];
                return false;
            } else if ([jsonDict objectForKey:@"message"] != nil) {
                if ([[jsonDict objectForKey:@"message"] isEqualToString:@"unauthorized"]) {
                    [self.delegate hackerSchoolAPIUnauthorized];
                } else {
                    NSLog(@"error message from HS api: %@", [jsonDict objectForKey:@"message"]);
                    [self.delegate hackerSchoolAPIError];
                }
            } else {
                if ([isMe boolValue]) {
                    [self saveMyProfileWithInfo:jsonDict];
                }
                else {
                    [self recordHackerSchoolerSightingWithProfile:jsonDict];
                }
            }
        }
    } else {
        NSLog(@"Error connecting to Hacker School API: %@", error);
    }
    return false;
}

-(void)setUserID:(NSInteger)userID
{
#warning testing pick random user
    if (userID == 759) {
        // pick a random user id for testing
        NSArray *userIDs = @[@"36", @"94", @"53", @"34", @"29", @"35", @"96", @"759"];
        NSString *randUser = [userIDs objectAtIndex: arc4random() % [userIDs count]];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:[randUser integerValue]] forKey:kSHUserIDKey];
        randUser = nil;
        userIDs = nil;
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:userID] forKey:kSHUserIDKey];
    }
    
}

-(void)saveMyProfileWithInfo:(NSDictionary *)profileDict
{
    [TestFlight passCheckpoint:@"LOGIN_SUCCESS"];
    
    HackerSchooler *thisHackerSchooler = [self addHackerSchoolerWithProfile:profileDict];
    
    [self setUserID:[[profileDict objectForKey:@"id"] integerValue]];
    
    UIAlertView *alertView = [ [UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Hello %@", thisHackerSchooler.first_name]
                                                         message:[NSString stringWithFormat:@"Batch %@", thisHackerSchooler.batch]
                                                        delegate:self
                                               cancelButtonTitle:@"Dismiss"
                                               otherButtonTitles:nil];
    [alertView show];
    
    [self.delegate hackerSchoolAPIGotMyProfile];
}

-(HackerSchooler *)addHackerSchoolerWithProfile:(NSDictionary *)profile
{
    // add new hacker schooler to core data
    HackerSchooler *thisHackerSchooler = [HackerSchooler hackerSchoolerWithUniqueUserID:[profile objectForKey:@"id"] andFirstName:[profile objectForKey:@"first_name"] andLastName:[profile objectForKey:@"last_name"] andBatch:[[profile objectForKey:@"batch"] objectForKey:@"name"] inManagedObjectContext:self.managedObjectContext];
    
    thisHackerSchooler.photoURL = [profile objectForKey:@"image"];
    return thisHackerSchooler;
}


-(void)recordHackerSchoolerSightingWithProfile:(NSDictionary *)profile
{
    [TestFlight passCheckpoint:@"FOUND_HACKER_SCHOOLER"];
    
    HackerSchooler *thisHackerSchooler = [self addHackerSchoolerWithProfile:profile];
    
    // add this event to core data
    if (thisHackerSchooler.lastEventTime != nil) {
        NSTimeInterval distanceBetweenDates = [[NSDate date] timeIntervalSinceDate:thisHackerSchooler.lastEventTime];
        double secondsInAnHour = 3600.0;
        CGFloat hoursBetweenDates = distanceBetweenDates / secondsInAnHour;
#warning testing alter here for more frequent alerts
        if (hoursBetweenDates > 1.0) {
            // record this as a new event
            [self addEventWithHackerSchooler:thisHackerSchooler];
        }
    } else {
        // record this as a new event
        [self addEventWithHackerSchooler:thisHackerSchooler];
    }
    thisHackerSchooler = nil;
    [self.delegate hackerSchoolAPIAddedEvent];
}

-(void)addEventWithHackerSchooler:(HackerSchooler *)hackerSchooler
{
    Event *newEvent = [Event createEventWithHackerSchooler:hackerSchooler inManagedObjectContext:self.managedObjectContext];
    [hackerSchooler addEventsObject:newEvent];
    newEvent = nil;
    
    // notify user of new event
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = [NSString stringWithFormat:@"Found Hacker Schooler: %@ %@", hackerSchooler.first_name, hackerSchooler.last_name];
    notification.soundName = @"Default";
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    NSLog(@"hacker schooler found: %@", hackerSchooler.first_name);
}



@end
