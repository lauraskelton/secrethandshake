//
//  OAuthHandler.m
//  SecretHandshake
//
//  Created by Laura Skelton on 6/21/14.
//  Copyright (c) 2014 Laura Skelton. All rights reserved.
//

#import "SecretHandshake-Prefix.pch"

#import "OAuthHandler.h"
#import "GTMOAuth2SignIn.h"
#import "GTMOAuth2Authentication.h"

@interface OAuthHandler ()

@property (nonatomic, retain) GTMOAuth2SignIn *signInClass;

- (GTMOAuth2Authentication *)hackerSchoolAuth;

- (void)signIn:(GTMOAuth2SignIn *)signIn displayRequest:(NSURLRequest *)request;

- (void)signIn:(GTMOAuth2SignIn *)signIn
finishedWithAuth:(GTMOAuth2Authentication *)auth
         error:(NSError *)error;

@end

@implementation OAuthHandler

@synthesize delegate, authURL;

- (id)init
{
    
    // designated initializer
    self = [super init];
    if (self) {
        
        GTMOAuth2Authentication *auth = [self hackerSchoolAuth];
        
        // Prepare the Authorization URL.
        authURL = [NSURL URLWithString:@"https://www.hackerschool.com/oauth/authorize"];
        
        self.signInClass = [[GTMOAuth2SignIn alloc] initWithAuthentication:auth
                                                          authorizationURL:authURL
                                                                  delegate:self
                                                        webRequestSelector:@selector(signIn:displayRequest:)
                                                          finishedSelector:@selector(signIn:finishedWithAuth:error:)];

    }
    return self;
}

-(void)handleAuthTokenURL:(NSURL *)url
{
    // handle query here
    [self.signInClass handleExternalTokenQueryString:url];
    
    NSDictionary *dict = [self parseQueryString:[url query]];
    
    if ([dict objectForKey:@"error"] != nil) {
        [self.delegate oauthHandlerDidFailWithError:[dict objectForKey:@"error"]];
    } else {
        [self.delegate oauthHandlerDidAuthorizeWithAuth:self.signInClass.authentication];
    }
    
}

- (NSDictionary *)parseQueryString:(NSString *)query
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:6];
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    
    for (NSString *pair in pairs) {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        NSString *key = [[elements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *val = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [dict setObject:val forKey:key];
        elements = nil;
        key = nil;
        val = nil;
    }
    pairs = nil;
    return dict;
}

- (GTMOAuth2Authentication *)hackerSchoolAuth
{
    
    // Set the token URL to the Singly token endpoint.
    NSURL *tokenURL = [NSURL URLWithString:@"https://www.hackerschool.com/oauth/token"];
    
    // Set a bogus redirect URI. It won't actually be used as the redirect will
    // be intercepted by the OAuth library and handled in the app.
    NSString *redirectURI = @"secrethandshake://oauth";
    
    GTMOAuth2Authentication *auth;
    auth = [GTMOAuth2Authentication authenticationWithServiceProvider:@"Secret Handshake"
                                                             tokenURL:tokenURL
                                                          redirectURI:redirectURI
                                                             clientID:kMyClientID
                                                         clientSecret:kMyClientSecret];
    
    // The Singly API does not return a token type, therefore we set one here to
    // avoid a warning being thrown.
    [auth setTokenType:@"HackerSchoolToken"];
    
    return auth;
}

#pragma mark SignIn callbacks

- (void)signIn:(GTMOAuth2SignIn *)signIn displayRequest:(NSURLRequest *)request
{
    // This is the signIn object's webRequest method, telling the controller
    // to either display the request in the webview, or if the request is nil,
    // to close the window.
    //
    
    NSLog(@"display request method called");
}

- (void)signIn:(GTMOAuth2SignIn *)signIn
finishedWithAuth:(GTMOAuth2Authentication *)auth
         error:(NSError *)error
{
    
    NSLog(@"sign in finished method called");
    
    if (error != nil) {
       // [self.delegate oauthHandlerDidFailWithError:error];
    } else {
        //[self.delegate oauthHandlerDidAuthorizeWithAuth:auth];
    }
    
    /*
    if (!hasCalledFinished_) {
        hasCalledFinished_ = YES;
        
        if (delegate_ && finishedSelector_) {
            SEL sel = finishedSelector_;
            NSMethodSignature *sig = [delegate_ methodSignatureForSelector:sel];
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
            [invocation setSelector:sel];
            [invocation setTarget:delegate_];
            [invocation setArgument:&self atIndex:2];
            [invocation setArgument:&auth atIndex:3];
            [invocation setArgument:&error atIndex:4];
            [invocation invoke];
        }
        
        [delegate_ autorelease];
        delegate_ = nil;
        
#if NS_BLOCKS_AVAILABLE
        if (completionBlock_) {
            completionBlock_(self, auth, error);
            
            // release the block here to avoid a retain loop on the controller
            [completionBlock_ autorelease];
            completionBlock_ = nil;
        }
#endif
    }
     */

}



@end
