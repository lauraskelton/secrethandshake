//
//  OAuthHandler.m
//  SecretHandshake
//
//  Created by Laura Skelton on 6/21/14.
//  Copyright (c) 2014 Laura Skelton. All rights reserved.
//

#import "SecretHandshake-Prefix.pch"

#import "OAuthHandler.h"
#import "QueryParser.h"
#import "OAuthHandler_Internal.h"


@implementation OAuthHandler

@synthesize delegate, code;

- (id)init
{
    
    // designated initializer
    self = [super init];
    if (self) {
        
    }
    return self;
}

+ (OAuthHandler *)sharedHandler
{
    static OAuthHandler *_sharedHandler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedHandler = [[OAuthHandler alloc] init];

    });
    
    return _sharedHandler;
}

-(void)handleUserSignIn:(id)sender
{
    // first, try to refresh token. if fails, then launch external sign-in.
    
    if (self.code == nil && [[NSUserDefaults standardUserDefaults] objectForKey:kSHRefreshTokenKey] == nil) {
        [self launchExternalSignIn:nil];
    } else {
        [self requestAccessToken];
    }
}

-(void)launchExternalSignIn:(id)sender
{
    //NSURL *authURL = [NSURL URLWithString:@"http://secrethandshakeapp.com/auth.php"];
    NSLog(@"var: %@", kMyClientID);
    
    NSURL *authURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.hackerschool.com/oauth/authorize?response_type=code&client_id=%@&redirect_uri=%@", kMyClientID, kMyRedirectURI]];
    
    [[UIApplication sharedApplication] openURL:authURL];
}

-(NSURLRequest *)accessTokenRequest
{
    NSURL *tokenURL = [NSURL URLWithString:@"https://www.hackerschool.com/oauth/token"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:tokenURL];
    
    [request setHTTPMethod:@"POST"];
    NSString *postString;
    if (self.code != nil) {
        postString = [NSString stringWithFormat:@"grant_type=authorization_code&client_id=%@&client_secret=%@&redirect_uri=%@&code=%@", kMyClientID, kMyClientSecret, kMyRedirectURI, self.code];
    } else {
        NSLog(@"refreshing token");
        postString = [NSString stringWithFormat:@"grant_type=refresh_token&client_id=%@&client_secret=%@&refresh_token=%@", kMyClientID, kMyClientSecret, [[NSUserDefaults standardUserDefaults] objectForKey:kSHRefreshTokenKey]];
    }
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"request: %@ method: %@ httpBody: %@", request, request.HTTPMethod, [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]);
    return request;
}

-(BOOL)handleResponseWithData:(NSData *)data andError:(NSError *)error
{
    if (error == nil && data != nil) {
        NSString *responseBody = [ [NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        if (responseBody != nil) {

            NSLog(@"response: %@", responseBody);
            
            //NSData *jsonData = [responseBody dataUsingEncoding:NSUTF8StringEncoding];
            
            NSError *e;
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&e];
            
            NSLog(@"jsonDict: %@", jsonDict);
            
            if (e != nil) {
                NSLog(@"error creating json object from response: %@", e);
                if (self.code == nil) {
                    [self launchExternalSignIn:nil];
                }
                return false;
            } else if ([jsonDict objectForKey:@"error"] != nil){
                NSLog(@"error requesting access token: %@", [jsonDict objectForKey:@"error"]);
                if (self.code == nil) {
                    [self launchExternalSignIn:nil];
                }
                return false;
            } else {
                if ([jsonDict objectForKey:@"access_token"] != nil && [jsonDict objectForKey:@"refresh_token"] != nil) {
                    if ([[jsonDict objectForKey:@"access_token"] length] > 0 && [[jsonDict objectForKey:@"refresh_token"] length] > 0) {
                        [[NSUserDefaults standardUserDefaults] setObject:[jsonDict objectForKey:@"access_token"] forKey:kSHAccessTokenKey];
                        [[NSUserDefaults standardUserDefaults] setObject:[jsonDict objectForKey:@"refresh_token"] forKey:kSHRefreshTokenKey];
                        return true;
                    }
                }
            }
        }
    } else {
        NSLog(@"Error generating OAuth access token: %@", error);
    }
    return false;
}

-(void)requestAccessToken
{
    
    NSURLRequest *request = [self accessTokenRequest];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               if ([self handleResponseWithData:data andError:error]) {
                                   [self.delegate oauthHandlerDidAuthorize];
                               } else {
                                   // Should we do a popup to tell the user that login failed?
                                   NSLog(@"Error handling login response.");
                               }
                               
                           }];
}

-(void)handleAuthTokenURL:(NSURL *)url
{
    // handle query here
    NSDictionary *dict = [QueryParser parseQueryString:[url query]];
    
    if ([dict objectForKey:@"error"] != nil) {
        [self.delegate oauthHandlerDidFailWithError:[dict objectForKey:@"error"]];
    } else if ([dict objectForKey:@"code"] != nil) {
        // Use the Authorization Code to request an Access Token from the Hacker School API
        self.code = [dict objectForKey:@"code"];
        [self requestAccessToken];
    } else {
        [self.delegate oauthHandlerDidFailWithError:@"Authorization code not found. Failed to log in to Hacker School."];
    }
    
}

@end
