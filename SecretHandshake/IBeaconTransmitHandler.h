//
//  IBeaconTransmitHandler.h
//  SecretHandshake
//
//  Created by Laura Skelton on 7/3/14.
//  Copyright (c) 2014 Laura Skelton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IBeaconTransmitHandler : NSObject

+ (IBeaconTransmitHandler *)shared;
-(void)startIBeacon;

@end
