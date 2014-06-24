//
//  OAuthHandler.h
//  SecretHandshake
//
//  Created by Laura Skelton on 6/21/14.
//  Copyright (c) 2014 Laura Skelton. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GTMOAuth2Authentication;
@protocol OAuthHandlerDelegate <NSObject>
- (void)oauthHandlerDidAuthorize;
- (void)oauthHandlerDidFailWithError:(NSString *)errorMessage;
@end

@interface OAuthHandler : NSObject

@property (nonatomic, weak) id <OAuthHandlerDelegate> delegate;

@property (nonatomic, retain) NSURL *authURL;

- (id)init;

-(void)handleAuthTokenURL:(NSURL *)url;
-(void)refreshToken:(id)sender;

@end
