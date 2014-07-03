//
//  HackerSchoolAPIManager.h
//  SecretHandshake
//
//  Created by Laura Skelton on 7/2/14.
//  Copyright (c) 2014 Laura Skelton. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HackerSchooler, NSManagedObjectContext;

@protocol HackerSchoolAPIManagerDelegate <NSObject>
- (void)hackerSchoolAPIUnauthorized;
- (void)hackerSchoolAPIError;
- (void)hackerSchoolAPIGotMyProfile;
- (void)hackerSchoolAPIAddedEvent;
- (void)hackerSchoolAPIMarkCurrentUser:(NSNumber *)userID;
@end

@interface HackerSchoolAPIManager : NSObject

@property (nonatomic, weak) id <HackerSchoolAPIManagerDelegate> delegate;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

+ (HackerSchoolAPIManager *)sharedWithContext:(NSManagedObjectContext *)context;
-(void)downloadUserProfileWithID:(NSNumber *)userID isMe:(NSNumber *)isMe;

@end
