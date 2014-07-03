//
//  IBeaconSearchHandler.m
//  SecretHandshake
//
//  Created by Laura Skelton on 7/3/14.
//  Copyright (c) 2014 Laura Skelton. All rights reserved.
//

#import "IBeaconSearchHandler.h"
#import "SecretHandshake-Prefix.pch"

#import <CoreLocation/CoreLocation.h>

@interface IBeaconSearchHandler () <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (nonatomic, retain) NSNumber *lastUserID;
@property (nonatomic, retain) NSTimer *currentTimer;

- (void) intervalTimer;
- (void) resetBeacons:(NSTimer *)timer;

@end

@implementation IBeaconSearchHandler
@synthesize delegate;

+ (IBeaconSearchHandler *)shared
{
    static IBeaconSearchHandler *_sharedHandler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedHandler = [[IBeaconSearchHandler alloc] init];
        
        _sharedHandler.locationManager = [[CLLocationManager alloc] init];
        _sharedHandler.locationManager.delegate = _sharedHandler;
        
    });
    
    return _sharedHandler;
}

-(void)markCurrentUserID:(NSNumber *)userID
{
    [self.currentTimer invalidate];
    self.currentTimer = nil;
    self.lastUserID = userID;
    [self intervalTimer];
}

- (void)initRegion
{
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"3ee761a0-f737-11e3-a3ac-0800200c9a66"];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"region42"];
    self.beaconRegion.notifyEntryStateOnDisplay = YES;
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    
}

#pragma mark - Private

- (void) intervalTimer
{
    self.currentTimer = [NSTimer scheduledTimerWithTimeInterval:60
                                                         target:self
                                                       selector:@selector(resetBeacons:)
                                                       userInfo:nil
                                                        repeats:NO];
}

- (void) resetBeacons:(NSTimer *)timer
{
    self.lastUserID = nil;
}

#pragma mark - Location Manager Delegate Methods

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"location manager failed: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager
        didRangeBeacons:(NSArray *)beacons
               inRegion:(CLBeaconRegion *)region
{
    for (CLBeacon *beacon in beacons) {
        if ([beacon.minor integerValue] > 0) {
            if (([self.lastUserID integerValue] != [beacon.minor integerValue]) && ([beacon.minor integerValue] != [[[NSUserDefaults standardUserDefaults] objectForKey:kSHUserIDKey] integerValue]) && ([beacon.minor integerValue] > 0)) {
                
                [self.delegate iBeaconSearchHandlerFoundUserWithID:beacon.minor];
                
            }
        }
    }
}

@end
