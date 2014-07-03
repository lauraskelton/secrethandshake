//
//  IBeaconTransmitHandler.m
//  SecretHandshake
//
//  Created by Laura Skelton on 7/3/14.
//  Copyright (c) 2014 Laura Skelton. All rights reserved.
//

#import "IBeaconTransmitHandler.h"
#import "SecretHandshake-Prefix.pch"
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>

@interface IBeaconTransmitHandler () <CBPeripheralManagerDelegate>

@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) NSDictionary *beaconPeripheralData;
@property (strong, nonatomic) CBPeripheralManager *peripheralManager;

- (void)initBeacon;
- (void)transmitBeacon;

@end

@implementation IBeaconTransmitHandler

+ (IBeaconTransmitHandler *)shared
{
    static IBeaconTransmitHandler *_sharedHandler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedHandler = [[IBeaconTransmitHandler alloc] init];
        
    });
    
    return _sharedHandler;
}

#pragma mark - iBeacons

-(void)startIBeacon
{
    [self initBeacon];
    [self transmitBeacon];
}

#pragma mark - Private

- (void)initBeacon
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kSHUserIDKey] != nil) {
        
        NSLog(@"my id int value: %d", [[[NSUserDefaults standardUserDefaults] objectForKey:kSHUserIDKey] intValue]);
        
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"3ee761a0-f737-11e3-a3ac-0800200c9a66"];
        self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                                                    major:1
                                                                    minor:[[[NSUserDefaults standardUserDefaults] objectForKey:kSHUserIDKey] intValue]
                                                               identifier:@"region42"];
    }
}

- (void)transmitBeacon
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kSHUserIDKey] != nil) {
        
        self.beaconPeripheralData = [self.beaconRegion peripheralDataWithMeasuredPower:nil];
        self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self
                                                                         queue:nil
                                                                       options:nil];
    }
}

#pragma mark - Peripheral Manager Delegate

-(void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
        NSLog(@"Powered On");
        [self.peripheralManager startAdvertising:self.beaconPeripheralData];
    } else if (peripheral.state == CBPeripheralManagerStatePoweredOff) {
        NSLog(@"Powered Off");
        [self.peripheralManager stopAdvertising];
    }
}

@end
