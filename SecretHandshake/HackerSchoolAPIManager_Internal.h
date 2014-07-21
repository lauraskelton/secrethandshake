//
//  HackerSchoolAPIManager_Internal.h
//  SecretHandshake
//
//  Created by Laura Skelton on 7/15/14.
//  Copyright (c) 2014 Laura Skelton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HackerSchoolAPIManager ()

-(void)saveMyProfileWithInfo:(NSDictionary *)profileDict;
-(void)recordHackerSchoolerSightingWithProfile:(NSDictionary *)profile;
-(void)addEventWithHackerSchooler:(HackerSchooler *)hackerSchooler;
-(HackerSchooler *)addHackerSchoolerWithProfile:(NSDictionary *)profile;
-(void)setUserID:(NSInteger)userID;

-(NSURLRequest *)downloadUserProfileRequestWithID:(NSNumber *)userID isMe:(NSNumber *)isMe;
-(BOOL)handleResponseWithData:(NSData *)data andError:(NSError *)error isMe:(NSNumber *)isMe;

@end
