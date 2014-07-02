//
//  OAuthHandler_Private.h
//  SecretHandshake
//
//  Created by Laura Skelton on 7/2/14.
//  Copyright (c) 2014 Laura Skelton. All rights reserved.
//

@interface OAuthHandler ()

@property (nonatomic, retain) NSString *code;

-(void)launchExternalSignIn:(id)sender;
-(void)requestAccessToken;
-(NSURLRequest *)accessTokenRequest;
-(BOOL)handleResponseWithData:(NSData *)data andError:(NSError *)error;

@end
