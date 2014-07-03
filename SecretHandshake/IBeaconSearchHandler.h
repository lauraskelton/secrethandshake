//
//  IBeaconSearchHandler.h
//  SecretHandshake
//
//  Created by Laura Skelton on 7/3/14.
//  Copyright (c) 2014 Laura Skelton. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IBeaconSearchHandlerDelegate <NSObject>
- (void)iBeaconSearchHandlerFoundUserWithID:(NSNumber *)userID;
@end

@interface IBeaconSearchHandler : NSObject

@property (nonatomic, weak) id <IBeaconSearchHandlerDelegate> delegate;

+ (IBeaconSearchHandler *)shared;
- (void)initRegion;
-(void)markCurrentUserID:(NSNumber *)userID;

@end
