//
//  OAuthHandler.m
//  SecretHandshake
//
//  Created by Laura Skelton on 6/21/14.
//  Copyright (c) 2014 Laura Skelton. All rights reserved.
//

#import "SecretHandshake-Prefix.pch"

#import "OAuthHandler.h"

@interface OAuthHandler ()

-(void)launchExternalSignIn:(id)sender;
-(void)refreshToken:(id)sender;

@end

@implementation OAuthHandler

@synthesize delegate;

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
    
    [self refreshToken:nil];
}

-(void)launchExternalSignIn:(id)sender
{
    NSURL *authURL = [NSURL URLWithString:@"http://secrethandshakeapp.com/auth.php"];
    
    [[UIApplication sharedApplication] openURL:authURL];
}

-(void)refreshToken:(id)sender
{
    NSURL *tokenURL = [NSURL URLWithString:@"https://www.hackerschool.com/oauth/token"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:tokenURL];
    
    [request setHTTPMethod:@"POST"];
    NSString *postString = [NSString stringWithFormat:@"grant_type=refresh_token&client_id=%@&client_secret=%@&refresh_token=%@", kMyClientID, kMyClientSecret, [[NSUserDefaults standardUserDefaults] objectForKey:kSHRefreshTokenKey]];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               NSString *responseBody = [ [NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                               
                               NSLog(@"response: %@", responseBody);
                               
                               NSData *jsonData = [responseBody dataUsingEncoding:NSUTF8StringEncoding];
                               NSError *e;
                               NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&e];
                               
                               if (e != nil) {
                                   NSLog(@"error: %@", e);
                                   [self launchExternalSignIn:nil];
                               } else if ([jsonDict objectForKey:@"error"] != nil){
                                   NSLog(@"error refreshing token: %@", [jsonDict objectForKey:@"error"]);
                                   [self launchExternalSignIn:nil];
                               } else {
                                   [[NSUserDefaults standardUserDefaults] setObject:[jsonDict objectForKey:@"access_token"] forKey:kSHAccessTokenKey];
                                   [[NSUserDefaults standardUserDefaults] setObject:[jsonDict objectForKey:@"refresh_token"] forKey:kSHRefreshTokenKey];
                                   [self.delegate oauthHandlerDidAuthorize];
                               }
                               
                           }];

}

-(void)handleAuthTokenURL:(NSURL *)url
{
    // handle query here
    NSDictionary *dict = [self parseQueryString:[url query]];
    
    if ([dict objectForKey:@"error"] != nil) {
        [self.delegate oauthHandlerDidFailWithError:[dict objectForKey:@"error"]];
    } else if ([dict objectForKey:@"access_token"] != nil && [dict objectForKey:@"refresh_token"] != nil) {
        // Save the access token and refresh token
        [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"access_token"] forKey:kSHAccessTokenKey];
        [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"refresh_token"] forKey:kSHRefreshTokenKey];
        
        [self.delegate oauthHandlerDidAuthorize];
    } else {
        [self.delegate oauthHandlerDidFailWithError:@"Access token not found. Failed to log in to Hacker School."];
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

@end
