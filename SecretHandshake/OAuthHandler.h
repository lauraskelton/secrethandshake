//
//  OAuthHandler.h
//  SecretHandshake
//
//  Created by Laura Skelton on 6/21/14.
//  Copyright (c) 2014 Laura Skelton. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GTMOAuth2Authentication;
@protocol OAuthHandlerDelegate <NSObject>
- (void)oauthHandlerDidAuthorize;
- (void)oauthHandlerDidFailWithError:(NSString *)errorMessage;
@end

@interface OAuthHandler : NSObject

@property (nonatomic, weak) id <OAuthHandlerDelegate> delegate;

+ (OAuthHandler *)sharedHandler;
-(void)handleUserSignIn:(id)sender;
-(void)handleAuthTokenURL:(NSURL *)url;

@end
